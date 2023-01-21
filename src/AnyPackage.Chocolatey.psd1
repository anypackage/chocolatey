@{
	RootModule = 'AnyPackage.Chocolatey.psm1'
	ModuleVersion = '0.0.1'
	GUID = '070f2b8f-c7db-4566-9296-2f7cc9146bf0'
	Author = 'Ethan Bergstrom'
	Copyright = '2023'
	Description = 'AnyPackage provider that facilitates installing Chocolatey packages from any NuGet repository.'
	PowerShellVersion = '5.1'
	RequiredModules = @(
		@{
			ModuleName = 'AnyPackage'
			ModuleVersion = '0.1.0'
		},
		@{
			ModuleName = 'Foil'
			ModuleVersion = '0.1.0'
		}
	)
	PrivateData = @{
		AnyPackageProviders = 'AnyPackage.Chocolatey.psm1'
		PSData = @{
			# Tags applied to this module to indicate this is a AnyPackage Provider.
			Tags = @('AnyPackage','Provider','Chocolatey','PSEdition_Desktop','PSEdition_Core','Windows')

			# A URL to the license for this module.
			LicenseUri = 'https://github.com/PowerShell/PowerShell/blob/master/LICENSE.txt'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/AnyPackage/AnyPackage.Chocolatey'

			# ReleaseNotes of this module
			ReleaseNotes = 'This is a PowerShell AnyPackage provider. It is a wrapper on top of Choco.
			It discovers Chocolatey packages from https://www.chocolatey.org and other NuGet repos.'
		}
	}
}
