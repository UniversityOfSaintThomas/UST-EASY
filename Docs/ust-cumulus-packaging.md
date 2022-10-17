# UST CumulusCI Unlocked Org Dependant package release

## Set up (done once)

1. Add to the cumulus.yml file has steps to inform that the release package is unlocked and
org dependent:

    ```yaml
      release_unlocked_beta:
        steps:
          1:
            options:
              org_dependent: True
              package_type: Unlocked
    ```

2. Create a package with cumulus. The package name is taken from
the cumulus.yml file and needs to be unique.

    ```
    cci task run create_package_version --package_type Unlocked --org_dependent True
    ```

## Create a release

```
cci flow run release_unlocked_beta
```

## Promote a release

```
cci flow run release_2gp_production
```

