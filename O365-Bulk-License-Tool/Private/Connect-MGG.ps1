function Connect-MGG {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$TenantId,
        [Parameter(Mandatory = $false)]
        [string]$ClientId,
        [Parameter(Mandatory = $false)]
        [string]$ClientSecret,
        [Parameter(Mandatory = $false)]
        [switch]$Interactive,
        [Parameter(Mandatory = $false)]
        [string[]]$Scopes = @('Https://graph.microsoft.com/.default')
    )
    # Check if the Microsoft Graph module is installed
    if (-not (Get-Module -Name Microsoft.Graph -ListAvailable)) {
        Write-Error "Microsoft Graph module is not installed. Please install it first."
        # Install-Module -Name Microsoft.Graph -Scope CurrentUser
        Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
        Import-Module -Name Microsoft.Graph
        Write-Host "Microsoft Graph module installed and imported."
    } else {
        Write-Host "Microsoft Graph module is already installed."
        Import-Module -Name Microsoft.Graph
    }
    # Check if the user is already connected
    if (Get-MgContext) {
        Write-Host "Already connected to Microsoft Graph."
        return $true 
    }
    
    if ($Interactive) {
        # Connect interactively
        try {
            Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All", "Directory.AccessAsUser.All"
            Write-Host "Connected to Microsoft Graph interactively."
            return $true
        } catch {
            Write-Error "Failed to connect to Microsoft Graph interactively: $_"
            return $false
        }
    } elseif ($TenantId -and $ClientId -and $ClientSecret) {
        # Connect using client credentials
        try {
            $appSecret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential($ClientId, $appSecret)
            Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -Credential $credential
            Write-Host "Connected to Microsoft Graph using client credentials."
            return $true
        } catch {
            Write-Error "Failed to connect to Microsoft Graph using client credentials: $_"
            return $false
        }
    } else {
        Write-Error "Please provide either TenantId, ClientId, and ClientSecret or use the Interactive switch."
        return $false
    }
}