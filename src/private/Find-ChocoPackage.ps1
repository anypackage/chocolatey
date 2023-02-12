function Find-ChocoPackage {
	param (
		[Parameter()]
		[PackageRequest]
		$Request = $Request
	)

	[array]$RegisteredPackageSources = Foil\Get-ChocoSource

	$selectedSource = $(
		if ($Request.Source) {
			# Finding the matched package sources from the registered ones
			if ($RegisteredPackageSources.Name -eq $Request.Source) {
				# Found the matched registered source
				$Request.Source
			} else {
				throw 'The specified source is not registered with the package provider.'
			}
		} else {
			# User did not specify a source. Now what?
			if ($RegisteredPackageSources.Count -eq 1) {
				# If no source name is specified and only one source is available, use that source
				$RegisteredPackageSources[0].Name
			} elseif ($RegisteredPackageSources.Name -eq $DefaultPackageSource) {
				# If multiple sources are avaiable but none specified, use the default package source if present
				$DefaultPackageSource
			} else {
				# If the default assumed source is not present and no source specified, we can't guess what the user wants - throw an exception
				throw 'Multiple non-default sources are defined, but no source was specified. Source could not be determined.'
			}
		}
	)

	$chocoParams = @{
		Name = $Request.Name
		Source = $selectedSource
	}

	if (-Not [WildcardPattern]::ContainsWildcardCharacters($Request.Name)) {
		# Limit NuGet result set to just the specific package name unless it contains a wildcard
		$chocoParams.Add('Exact',$true)
	}

	# Choco does not support searching by min or max version, so if a user is picky we'll need to pull back all versions and filter ourselves
	if ($Request.Version) {
		$chocoParams.Add('AllVersions',$true)
	}

	# Filter results by any name and version requirements
	# We apply additional package name filtering when using wildcards to make Chocolatey's wildcard behavior more PowerShell-esque
	# The final results must be grouped by package name, showing the highest available version for install, to make the results easier to consume
	# Choco does not include source information in it's result set, so we need to include it in the results as a calculated property
	Foil\Find-ChocoPackage @chocoParams |
		Where-Object {$Request.IsMatch($_.Name)} |
			Where-Object {-Not $Request.Version -Or (([NuGet.Versioning.VersionRange]$Request.Version).Satisfies($_.Version))} | Group-Object Name |
				Select-Object Name,@{
						Name = 'Version'
						Expression = {$_.Group | Sort-Object -Descending Version | Select-Object -First 1 -ExpandProperty Version}
					},@{
						Name = 'Source'
						Expression = {$selectedSource}
					}
}
