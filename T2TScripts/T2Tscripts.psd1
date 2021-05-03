@{
	# Script module or binary module file associated with this manifest
	RootModule = 'T2Tscripts.psm1'
	
	# Version number of this module.
	ModuleVersion = '2.0.2'
	
	# ID used to uniquely identify this module
	GUID = '2725e92d-30e7-475f-b4d7-edd47e81f9b3'
	
	# Author of this module
	Author = 'Denis Vilaca Signorelli'
	
	# Company or vendor of this module
	CompanyName = 'Designor'
	
	# Copyright statement for this module
	Copyright = 'Copyright (c) 2021 Denis Vilaca Signorelli'
	
	# Description of the functionality provided by this module
	Description = 'Tenant to Tenant migration scripts'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.1'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.5.172' }
		@{ ModuleName='ExchangeOnlineManagement'; ModuleVersion='2.0.4' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\T2Tscripts.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\T2Tscripts.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	# FormatsToProcess = @('xml\T2Tscripts.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Export-T2TAttributes'
		'Import-T2TAttributes'
		'Update-T2TPostMigration'
		'Export-T2TLogs'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport = ''
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport = ''
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			# Tags = @()
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			# ProjectUri = ''
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}