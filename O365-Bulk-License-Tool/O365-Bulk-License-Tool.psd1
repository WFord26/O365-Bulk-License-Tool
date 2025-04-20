@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'O365-Bulk-License-Tool.psm1'
    
    # Version number of this module.
    ModuleVersion = '0.1.0'
    
    # Supported PSEditions
    # CompatiblePSEditions = @('Desktop', 'Core')
    
    # ID used to uniquely identify this module
    GUID = '00000000-0000-0000-0000-000000000000'  # Generate a new GUID for your module
    
    # Author of this module
    Author = 'Your Name'
    
    # Company or vendor of this module
    CompanyName = 'Your Company'
    
    # Copyright statement for this module
    Copyright = '(c) 2025 Your Name. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'A tool for managing Office 365 licenses in bulk'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @()
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = '*'
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Office365', 'Licensing', 'Administration')
            
            # A URL to the license for this module.
            # LicenseUri = ''
            
            # A URL to the main website for this project.
            # ProjectUri = ''
            
            # A URL to an icon representing this module.
            # IconUri = ''
            
            # ReleaseNotes of this module
            # ReleaseNotes = ''
        }
    }
}