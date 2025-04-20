#Requires -Version 5.1
#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="1.9.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="1.9.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users.Actions"; ModuleVersion="1.9.0" }

# Get public and private function definition files
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Export Public functions
Export-ModuleMember -Function $Public.BaseName

# Variables that should be exported
# Export-ModuleMember -Variable SomeVariable

# Aliases that should be exported
# Export-ModuleMember -Alias SomeAlias

# Initialize module
# Add any initialization code here
function Initialize-O365BulkLicenseTool {
    [CmdletBinding()]
    param()
    
    Write-Verbose "Initializing O365-Bulk-License-Tool module"
    
    # Check if already connected to Microsoft Graph
    try {
        $context = Get-MgContext -ErrorAction Stop
        if ($null -ne $context) {
            Write-Verbose "Already connected to Microsoft Graph as $($context.Account)"
        }
    }
    catch {
        Write-Warning "Not connected to Microsoft Graph. Use Connect-MgGraph to connect before using this module."
    }
}

# Run initialization
Initialize-O365BulkLicenseTool