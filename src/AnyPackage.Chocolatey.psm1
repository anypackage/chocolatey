using module AnyPackage
using namespace AnyPackage.Provider

# Current script path
[string]$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Definition -Parent

# Dot sourcing private script files
Get-ChildItem $ScriptPath/private -Recurse -Filter '*.ps1' -File | ForEach-Object {
	. $_.FullName
}

class InstallPackageDynamicParameters {
	[Parameter()]
	[switch]
	$ParamsGlobal

	[Parameter()]
	[string]
	$Parameters
}

class UninstallPackageDynamicParameters {
	[Parameter()]
	[switch]
	$RemoveDependencies
}

[PackageProvider("Chocolatey")]
class ChocolateyProvider : PackageProvider, IGetSource, ISetSource, IGetPackage, IFindPackage, IInstallPackage, IUninstallPackage {
	[object] GetDynamicParameters([string] $commandName) {
		return $(switch ($commandName) {
			'Install-Package' {[InstallPackageDynamicParameters]::new()}
			'Uninstall-Package' {[UninstallPackageDynamicParameters]::new()}
			Default {$null}
		})
	}

	[void] GetSource([SourceRequest] $Request) {
		Foil\Get-ChocoSource | Where-Object {$_.Disabled -eq 'False'} | Where-Object {$_.Name -Like $Request.Name} | ForEach-Object {
			$source = [PackageSourceInfo]::new($_.Name, $_.Location, $true, $this.ProviderInfo)
			$Request.WriteSource($source)
		}
	}

	[void] RegisterSource([SourceRequest] $Request) {
		Foil\Register-ChocoSource -Name $Request.Name -Location $Request.Location
		# Choco doesn't return anything after source operations, so we make up our own output object
		$source = [PackageSourceInfo]::new($Request.Name, $Request.Location.TrimEnd("\"), $Request.Trusted, $this.ProviderInfo)
		$Request.WriteSource($source)
	}

	[void] UnregisterSource([SourceRequest] $Request) {
		$source = Foil\Get-ChocoSource | Where-Object Name -like $Request.Name
		Foil\Unregister-ChocoSource -Name $Request.Name
		# Choco doesn't return anything after source operations, so we make up our own output object
		$Request.WriteSource($source)
	}

	[void] SetSource([SourceRequest] $Request) {
		$this.RegisterSource($Request)
	}

	[void] GetPackage([PackageRequest] $Request) {
		Get-ChocoPackage | Write-Package
	}

	[void] FindPackage([PackageRequest] $Request) {
		Find-ChocoPackage | Write-Package
	}

	[void] InstallPackage([PackageRequest] $Request) {
		$chocoParams = @{
			ParamsGlobal = $Request.DynamicParameters.ParamsGlobal
			Parameters = $Request.DynamicParameters.Parameters
		}

		# Run the package request first through Find-ChocoPackage to determine which source to use, and filter by any version requirements
		Find-ChocoPackage | Foil\Install-ChocoPackage @chocoParams | Write-Package
	}

	[void] UninstallPackage([PackageRequest] $Request) {
		$chocoParams = @{
			RemoveDependencies = $Request.DynamicParameters.RemoveDependencies
		}

		# Run the package request first through Get-ChocoPackage to filter by any version requirements
		Get-ChocoPackage | Foil\Uninstall-ChocoPackage @chocoParams | Write-Package
	}
}

[guid] $id = '070f2b8f-c7db-4566-9296-2f7cc9146bf0'
[PackageProviderManager]::RegisterProvider($id, [ChocolateyProvider], $MyInvocation.MyCommand.ScriptBlock.Module)
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { [PackageProviderManager]::UnregisterProvider($id) }
