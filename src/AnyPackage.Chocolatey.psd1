@{
	RootModule = 'AnyPackage.Chocolatey.psm1'
	ModuleVersion = '0.1.0'
	CompatiblePSEditions = @('Desktop', 'Core')
	GUID = '070f2b8f-c7db-4566-9296-2f7cc9146bf0'
	Author = 'Ethan Bergstrom'
	Copyright = '(c) 2023 Ethan Bergstrom. All rights reserved.'
	Description = 'AnyPackage provider that facilitates installing Chocolatey packages from any NuGet repository.'
	PowerShellVersion = '5.1'
	FunctionsToExport = @()
	CmdletsToExport = @()
	AliasesToExport = @()
	RequiredModules = @(
		@{
			ModuleName = 'AnyPackage'
			ModuleVersion = '0.1.0'
		},
		@{
			ModuleName = 'Foil'
			ModuleVersion = '0.3.0'
		}
	)
	PrivateData = @{
		AnyPackage = @{
			Providers = 'Chocolatey'
		}
		PSData = @{
			Tags = @('AnyPackage','Provider','Chocolatey','Windows')
			LicenseUri = 'https://github.com/AnyPackage/AnyPackage.Chocolatey/blob/main/LICENSE'
			ProjectUri = 'https://github.com/AnyPackage/AnyPackage.Chocolatey'
			ReleaseNotes = 'This is a PowerShell AnyPackage provider. It is a wrapper on top of Choco.
			It discovers Chocolatey packages from https://www.chocolatey.org and other NuGet repos.'
		}
	}
}
