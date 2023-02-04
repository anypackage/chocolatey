function Get-ChocoPackage {
	param (
		[Parameter()]
		[PackageRequest]
		$Request = $Request
	)

	$chocoParams = @{
		LocalOnly = $true
		AllVersions = $true
	}

	# If a user provides a name without a wildcard, include it in the search
	# This provides wildcard search behavior for locally installed packages, which Chocolatey lacks
	if ($Request.Name -And -Not ([WildcardPattern]::ContainsWildcardCharacters($Request.Name))) {
		$chocoParams.Add('Name',$Request.Name)
	}

	# Filter results by any name and version requirements
	# We apply additional package name filtering when using wildcards to make Chocolatey's wildcard behavior more PowerShell-esque
	Foil\Get-ChocoPackage @chocoParams |
		Where-Object {$Request.IsMatch($_.Name)} |
			Where-Object {-Not $Request.Version -Or (([NuGet.Versioning.VersionRange]$Request.Version).Satisfies($_.Version))}
}
