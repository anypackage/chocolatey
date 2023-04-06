function Write-Package {
	param (
		[Parameter(ValueFromPipeline)]
		[object[]]
		$InputObject,

		[Parameter()]
		[PackageRequest]
		$Request = $Request
	)

	begin {
		$sources = Foil\Get-ChocoSource
	}

	process {
		foreach ($package in $InputObject) {
			if ($package.Source) {
				# If source information is provided (usually from Find-ChocoPackage), construct a source object for inclusion in the results
				$location = $sources | Where-Object Name -EQ $package.Source | Select-Object -ExpandProperty Location
				$source = [PackageSourceInfo]::new($package.Source, $location, $true, $Request.ProviderInfo)
				$package = [PackageInfo]::new($package.Name, $package.Version, $source, $Request.ProviderInfo)
			} else {
				$package = [PackageInfo]::new($package.Name, $package.Version, $Request.ProviderInfo)
			}

			$Request.WritePackage($package)
		}
	}
}