function Write-Package {
	param (
		[Parameter(ValueFromPipeline)]
		[object[]]
		$InputObject,

		[Parameter()]
		[PackageRequest]
		$Request = $Request,

		[Parameter()]
		[PackageProviderInfo]
		$Provider = $this.PackageInfo
	)

	begin {
		$sources = Foil\Get-ChocoSource
	}

	process {
		foreach ($package in $InputObject) {
			if ($package.Source) {
				# If source information is provided (usually from Find-ChocoPackage), construct a source object for inclusion in the results
				$location = $sources | Where-Object Name -EQ $package.Source | Select-Object -ExpandProperty Location
				$source = [PackageSourceInfo]::new($package.Source, $location, $true, $Provider)
				$package = [PackageInfo]::new($package.Name, $package.Version, $source, $Provider)
			} else {
				$package = [PackageInfo]::new($package.Name, $package.Version, $Provider)
			}

			$Request.WritePackage($package)
		}
	}
}