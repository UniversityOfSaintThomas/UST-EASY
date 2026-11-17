<aura:application extends="ltng:outApp" access="GLOBAL" implements="ltng:allowGuestAccess">
    <!-- Lightning Out caches component bundles until this app changes. When an LWC change is not showing up on an
         embedded page, change this note (a real text change, not a re-deploy of the same bytes) and deploy this app. -->
    <!-- Embeds: rfiForm accepts the legacy rfi_controller attribute as well as rfiControllerName. After a submit it
         clears itself and shows its own message (toasts do not exist in Lightning Out). -->
    <!-- Lightning Out cache stamp: 2026-11-05d -->
    <aura:dependency resource="c:requestForInformationForm" />
    <aura:dependency resource="c:rfiForm" />
</aura:application>