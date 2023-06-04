[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification='PSSA does not understand Pester scopes well')]
param()

BeforeAll {
	$AnyPackageProvider = 'AnyPackage.Chocolatey'
	Import-Module $AnyPackageProvider -Force
}

Describe 'Chocolatey V2 test validity' {
	BeforeAll {
		$package = 'chocolatey'
		$version = '2.0.0'
		# Upgrade to Chocolatey v2 to test the API changes
		choco upgrade $package --yes
	}
	It 'confirms version of Chocolatey is at least 2.0.0' {
		Get-Package | Where-Object {$_.Name -eq $package -And $_.Version -ge $version} | Should -Not -BeNullOrEmpty
	}
}

Describe 'Chocolatey V2 basic package search operations' {
	Context 'without additional arguments' {
		BeforeAll {
			$package = 'cpu-z'
		}

		It 'gets a list of latest installed packages' {
			Get-Package | Where-Object {$_.Name -contains 'chocolatey'} | Should -Not -BeNullOrEmpty
		}
		It 'searches for the latest version of a package' {
			Find-Package -Name $package | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'searches for all versions of a package' {
			Find-Package -Name $package -Version '[0,]' | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'searches for the latest version of a package with a wildcard pattern' {
			Find-Package -Name "$package*" | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'Chocolatey V2 pipeline-based package installation and uninstallation' {
	Context 'without additional arguments' {
		BeforeAll {
			$package = 'cpu-z'
		}

		It 'searches for and silently installs the latest version of a package' {
			Find-Package -Name $package | Install-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls the locally installed package just installed' {
			Get-Package -Name $package | Uninstall-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}

	Context 'with dependencies' {
		BeforeAll {
			$package = 'notepadplusplus'
		}

		It 'searches for and silently installs the latest version of a package' {
			Find-Package -Name $package | Install-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls the locally installed package just installed, along with its dependencies' {
			Get-Package -Name $package | Uninstall-Package -Provider Chocolatey -RemoveDependencies -PassThru | Should -HaveCount 2
		}
	}

	Context 'with package parameters' {
		BeforeAll {
			$package = 'sysinternals'
			$installDir = Join-Path -Path $env:ProgramFiles -ChildPath $package
			$parameters = "/InstallDir:$installDir /QuickLaunchShortcut:false"
			Remove-Item -Force -Recurse -Path $installDir -ErrorAction SilentlyContinue
		}

		It 'silently installs the latest version of a package with explicit parameters' {
			Find-Package -Name $package | Install-Package -PassThru -Provider Chocolatey -ParamsGlobal -Parameters $parameters | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
		It 'correctly passed parameters to the package' {
			Get-ChildItem -Path $installDir -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
		}
		It 'silently uninstalls the locally installed package just installed' {
			Get-Package -Name $package | Uninstall-Package -Provider Chocolatey -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe 'Chocolatey V2 multi-source support' {
	BeforeAll {
		$altSource = 'LocalChocoSource'
		$altLocation = $PSScriptRoot
		$package = 'cpu-z'

		PackageManagement\Save-Package $package -Source 'http://chocolatey.org/api/v2' -Path $altLocation
		Remove-Module PackageManagement
		Unregister-PackageSource -Name $altSource -ErrorAction SilentlyContinue
	}
	AfterAll {
		Remove-Item "$altLocation\*.nupkg" -Force -ErrorAction SilentlyContinue
		Unregister-PackageSource -Name $altSource -ErrorAction SilentlyContinue
	}

	It 'registers an alternative package source' {
		Register-PackageSource -Name $altSource -Location $altLocation -Provider Chocolatey -PassThru | Where-Object {$_.Name -eq $altSource} | Should -Not -BeNullOrEmpty
		Get-PackageSource | Where-Object {$_.Name -eq $altSource} | Should -Not -BeNullOrEmpty
	}
	It 'searches for and installs the latest version of a package from an alternate source' {
		Find-Package -Name $package -source $altSource | Install-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
	}
	It 'finds and uninstalls a package installed from an alternate source' {
		Get-Package -Name $package | Uninstall-Package -PassThru | Where-Object {$_.Name -contains $package} | Should -Not -BeNullOrEmpty
	}
	It 'unregisters an alternative package source' {
		Unregister-PackageSource -Name $altSource -PassThru | Where-Object {$_.Name -eq $altSource} | Should -Not -BeNullOrEmpty
		Get-PackageSource | Where-Object {$_.Name -eq $altSource} | Should -BeNullOrEmpty
	}
}

Describe 'Chocolatey V2 version filters' {
	BeforeAll {
		$package = 'ninja'
		# Keep at least one version back, to test the 'latest' feature
		$version = '1.10.1'
	}
	AfterAll {
		Uninstall-Package -Name $package -ErrorAction SilentlyContinue
	}

	Context 'required version' {
		It 'searches for and silently installs a specific package version' {
			Find-Package -Name $package -Version "[$version]" | Install-Package -PassThru | Where-Object {$_.Name -contains $package -And $_.Version -eq $version} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls a specific package version' {
			Get-Package -Name $package -Version "[$version]" | UnInstall-Package -PassThru | Where-Object {$_.Name -contains $package -And $_.Version -eq $version} | Should -Not -BeNullOrEmpty
		}
	}

	Context 'minimum version' {
		It 'searches for and silently installs a minimum package version' {
			Find-Package -Name $package -Version $version | Install-Package -PassThru | Where-Object {$_.Name -contains $package -And $_.Version -ge $version} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls a minimum package version' {
			Get-Package -Name $package -Version $version | UnInstall-Package -PassThru | Where-Object {$_.Name -contains $package -And $_.Version -ge $version} | Should -Not -BeNullOrEmpty
		}
	}

	Context 'maximum version' {
		It 'searches for and silently installs a maximum package version' {
			Find-Package -Name $package -Version "[,$version]" | Install-Package -PassThru | Where-Object {$_.Name -contains $package -And $_.Version -le $version} | Should -Not -BeNullOrEmpty
		}
		It 'finds and silently uninstalls a maximum package version' {
			Get-Package -Name $package -Version "[,$version]" | UnInstall-Package -PassThru | Where-Object {$_.Name -contains $package -And $_.Version -le $version} | Should -Not -BeNullOrEmpty
		}
	}
}

Describe "error handling" {
	# Context 'package installation' {
	# 	BeforeAll {
	# 		$package = 'googlechrome'
	# 		# This version is known to be broken, per https://github.com/chocolatey-community/chocolatey-coreteampackages/issues/1608
	# 		$version = '87.0.4280.141'
	# 	}
	# 	AfterAll {
	# 		Uninstall-Package -Name $package -ErrorAction SilentlyContinue
	# 	}

	# 	It 'fails to silently install a package that cannot be installed' {
	# 		{Install-Package -Name $package -Version "[$version]" -ErrorAction Stop -WarningAction SilentlyContinue} | Should -Throw
	# 	}
	# }

	Context 'package uninstallation' {
		BeforeAll {
			$package = 'chromium'
			# This version is known to be broken, per https://github.com/chocolatey-community/chocolatey-coreteampackages/issues/341
			$version = '56.0.2897.0'
			Install-Package -Name $package -Version "[$version]"
		}

		It 'fails to silently uninstall a package that cannot be uninstalled' {
			{Uninstall-Package -Name $package -ErrorAction Stop -WarningAction SilentlyContinue} | Should -Throw
		}
	}

	Context 'ambiguous sources' {
		BeforeAll {
			$package = 'cpu-z'
			$defaultSource = 'chocolatey'
			$chocoSource = Get-PackageSource -name $defaultSource | Select-Object -ExpandProperty Location
			Get-PackageSource | Unregister-PackageSource
			@('test1','test2') | Register-PackageSource -Location $chocoSource -Provider Chocolatey
		}

		It 'refuses to find packages when the specified source does not exist' {
			{Find-Package -Name $package -Source $defaultSource -ErrorAction Stop} | Should -Throw 'The specified source is not registered with the package provider.'
		}

		It 'refuses to install packages when the specified source does not exist' {
			{Install-Package -Name $package -Source $defaultSource -ErrorAction Stop} | Should -Throw 'The specified source is not registered with the package provider.'
		}

		It 'refuses to find packages when multiple custom sources are defined and no source specified' {
			{Find-Package -Name $package -ErrorAction Stop} | Should -Throw 'Multiple non-default sources are defined, but no source was specified. Source could not be determined.'
		}

		It 'refuses to install packages when multiple custom sources are defined and no source specified' {
			{Install-Package -Name $package -ErrorAction Stop} | Should -Throw 'Multiple non-default sources are defined, but no source was specified. Source could not be determined.'
		}

		AfterAll {
			Get-PackageSource | Unregister-PackageSource
			Register-PackageSource -Name $defaultSource -Location $chocoSource -Provider Chocolatey
		}
	}
}
