function Group-TenantLicenses {
    $tenantLicenses = Get-MgSubscribedSku -All
    $skuFriendlyNames = Import-LicenseSkuIds
    $friendlyLicenses = @()
    foreach ($license in $tenantLicenses) {
        # Get the friendly name for the SKU
        $skuFriendlyName = if ($skuFriendlyNames.ContainsKey($license.SkuPartNumber)) {
            $skuFriendlyNames[$license.SkuPartNumber]
        } else {
            $license.SkuPartNumber  # Use part number as fallback if no friendly name exists
        }
        # Create a custom object to hold the license information
        $licenseInfo = [PSCustomObject]@{
            SkuId          = $license.SkuId
            SkuPartNumber  = $license.SkuPartNumber
            SkuFriendlyName = $skuFriendlyName
            PrepaidUnits   = $license.PrepaidUnits.Enabled
            ConsumedUnits  = $license.ConsumedUnits
        }
        # Add the license information to the array
        $friendlyLicenses += $licenseInfo
    }
    return $friendlyLicenses
}