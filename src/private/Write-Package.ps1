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
				$source = $Request.NewSourceInfo($package.Source,($sources | Where-Object Name -EQ $package.Source | Select-Object -ExpandProperty Location),$true)
				$Request.WritePackage($package.Name, $package.Version, '', $source)
			} else {
				$Request.WritePackage($package.Name, $package.Version)
			}
		}
	}
}