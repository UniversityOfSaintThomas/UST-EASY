# SOAP API login() Retirement — Impact Assessment & Migration Plan

**Salesforce retirement date:** Summer '27 (mandatory)
**Summer '26 change:** New `Use API Auth` user permission enforcement begins for newly created orgs; existing orgs can opt in
**Date assessed:** May 2026

---

## TL;DR

The UST-EASY **codebase itself is not affected.** The `Site.login()` calls in `ApplicationLoginController.cls` and `ApplicationRegistration.cls` are Salesforce's Experience Cloud community Apex API — they are completely unrelated to SOAP API login() and will continue to work unchanged.

However, Salesforce's email reported SOAP API login() activity against the org in April, so something external *is* using SOAP-based auth. This plan covers what to investigate and how to migrate each likely source.

---

## What Is and Is Not Affected

### ✅ Safe — No Changes Needed

| Component | Why safe |
|-----------|----------|
| `ApplicationLoginController.cls` — `Site.login()` | Server-side Apex Experience Cloud method. Not a SOAP call. |
| `ApplicationRegistration.cls` — `Site.login()` | Same as above. |
| Salesforce CLI (`sf`) | Authenticates via OAuth (JWT Bearer or Web Server flow). Not SOAP. |
| CumulusCI (`cci`) | Authenticates via OAuth (JWT or SFDX auth). Not SOAP in current versions. |

### ⚠️ Needs Investigation — Likely Sources of SOAP API Logins

These are the most likely sources of the April SOAP login activity. Each one must be confirmed and migrated.

---

## Investigation: Identify the Source

Before remediating, confirm which tool is generating the logins. In Setup, navigate to:

**Setup → Login History**

Filter by:
- **Login Type = "Application"** or **"Remote Access 2.0"** or look for any entries where the `Login Type` value is **"Soap"** or **"Api"**
- Date range: April 2026
- Look at the **Client column** and **User** column to identify the source

---

## Likely Source #1: Salesforce Data Loader

**Risk level:** High — Data Loader traditionally defaults to SOAP API login.

The project makes heavy use of data loading (see `datasets/` directory and `cumulusci.yml` load tasks such as `load_latest_data`, `load_scholarship_test_data`, etc.). If admins are running Data Loader manually outside of CumulusCI, it uses SOAP login by default.

### Investigation
- Check Login History for entries where the **Client** column contains "Data Loader" or where the user is an admin performing data operations.

### Remediation options (choose one)
1. **Switch to Salesforce CLI bulk data commands** — `sf data import tree` or `sf data upsert bulk` use OAuth.
2. **Upgrade Data Loader to v60+** and configure it to use OAuth 2.0:
   - In Data Loader Settings: enable **Use Bulk API v2** and configure an **OAuth Connected App**.
   - Salesforce has a guide: [Configure Data Loader to Use OAuth](https://developer.salesforce.com/docs/atlas.en-us.dataLoader.meta/dataLoader/loader_oauth.htm)
3. **Route all data loads through CumulusCI** (`cci task run load_latest_data --org dev`) which uses OAuth under the hood.

---

## Likely Source #2: TouchNet Amazon Proxy (Payment Callback)

**Risk level:** Medium-High — third-party or custom integration that POSTs payment results back to Salesforce.

Per `Docs/touchnet-integration.md`, TouchNet payments flow through an Amazon proxy that communicates with Salesforce after payment completion. If this proxy authenticates to Salesforce using the SOAP API (username + password via the SOAP login endpoint), it will break in Summer '27.

### Investigation
- Check Login History for the username used by the TouchNet integration (likely a dedicated integration user or the admin user).
- Check AWS Lambda / Amazon API Gateway logs for the proxy to see what endpoint it calls to authenticate (`https://login.salesforce.com/services/Soap/...` vs `https://login.salesforce.com/services/oauth2/token`).

### Remediation options
1. **OAuth Client Credentials Flow (recommended for server-to-server):**
   - Create a Connected App in Salesforce with the Client Credentials flow enabled.
   - Update the Amazon proxy to POST to `/services/oauth2/token` with `grant_type=client_credentials`, `client_id`, and `client_secret`.
   - No user password required — uses app credential only.
2. **OAuth JWT Bearer Flow (alternative):**
   - Good if the proxy already manages a certificate.
   - Connected App configured with a digital certificate; the proxy signs a JWT assertion and POSTs to `/services/oauth2/token`.
3. **Contact the TouchNet vendor** if the Amazon proxy is managed by them or a separate team to confirm which auth method they use and when they plan to upgrade.

---

## Likely Source #3: CumulusCI with Username/Password Auth

**Risk level:** Low — recent CCI versions use OAuth by default, but older setups or developer machines may have been authenticated with `cci org connect` using username/password which can trigger SOAP.

### Investigation
- Run `cci org list` and check which orgs are configured.
- Run `cci org info --org dev` and look at the `access_token` source — JWT/OAuth orgs show a token, not a session ID derived from SOAP.
- Check Login History for CCI-sourced logins: look for the CCI client identifier or the developer's username.

### Remediation
- Re-authenticate using `sf org login jwt` or `sf org login web` to ensure OAuth-based tokens are in use.
- Avoid `sf org login soapapi` or any username/password flows in scripts.

---

## Likely Source #4: Other Admin Scripts or Tooling

**Risk level:** Unknown — scripts in `scripts/setup.cls` run via CumulusCI's `AnonymousApexTask` (safe — server-side). But if any local PowerShell, Python, or Node.js scripts authenticate to the org using a username/password SOAP call, they are affected.

### Investigation
- Search local dev machines and any CI/CD pipelines for Salesforce SOAP WSDL usage, `JSforce` with `login()` calls, `simple_salesforce` with `username` + `password` + `security_token` parameters, or any script that calls `https://login.salesforce.com/services/Soap/`.

### Remediation
- **JSforce:** Switch to `conn.oauth2.requestToken()` with a Connected App.
- **simple_salesforce (Python):** Switch from `username`/`password`/`security_token` auth to `session_id` from OAuth or use the `connected_app_key`/`connected_app_secret` OAuth flow.
- **PowerShell scripts:** Use `sf` CLI commands (which use OAuth) instead of direct SOAP calls.

---

## Timeline & Action Priority

| Milestone | Date | Action Required |
|-----------|------|-----------------|
| Summer '26 release | ~Aug 2026 | New `Use API Auth` user perm activated in newly created orgs; existing orgs can opt in. **Recommend:** Assign `Use API Auth` perm to any users/integration users flagged in Login History. |
| Summer '27 release | ~Aug 2027 | SOAP API login() retired in versions 31.0–64.0. **All SOAP auth must be migrated by this date.** |

### Recommended work order
1. **Immediate (now):** Run Login History audit to confirm which tool/user is the source.
2. **Before Summer '26 (~3 months):** Migrate identified sources to OAuth. Test in scratch org.
3. **Summer '26:** Enable `Use API Auth` perm enforcement in the org as an early validation that no SOAP logins remain.
4. **Before Summer '27:** Final verification; remove any remaining SOAP login configurations.

---

## Useful Salesforce References

- [SOAP API login() Retirement article](https://help.salesforce.com/s/articleView?id=release-notes.rn_security_soap_api_login_retirement.htm)
- [OAuth Client Credentials Flow](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_client_credentials_flow.htm)
- [OAuth JWT Bearer Flow](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_jwt_flow.htm)
- [Connected Apps overview](https://help.salesforce.com/s/articleView?id=sf.connected_app_overview.htm)
- [Data Loader OAuth configuration](https://developer.salesforce.com/docs/atlas.en-us.dataLoader.meta/dataLoader/loader_oauth.htm)

