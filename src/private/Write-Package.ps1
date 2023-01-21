function Write-Package {
	param (
		[Parameter(ValueFromPipeline)]
		[object[]]
		$InputObject,

		[Parameter()]
		[PackageRequest]
		$Request = $Request
	)

	process {
		foreach ($package in $InputObject) {
			if ($package.Source) {
				# If source information is provided (usually from Find-ChocoPackage), construct a source object for inclusion in the results
				$source = $Request.NewSourceInfo($package.Source,(Foil\Get-ChocoSource | Where-Object Name -EQ $package.Source | Select-Object -ExpandProperty Location),$true)
				$Request.WritePackage($package.Name, $package.Version, '', $source)
			} else {
				$Request.WritePackage($package.Name, $package.Version)
			}
		}
	}
}