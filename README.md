# AnyPackage.Chocolatey

[![gallery-image]][gallery-site]
[![build-image]][build-site]
[![cf-image]][cf-site]

[gallery-image]: https://img.shields.io/powershellgallery/dt/AnyPackage.Chocolatey
[build-image]: https://img.shields.io/github/actions/workflow/status/anypackage/chocolatey/ci.yml
[cf-image]: https://img.shields.io/codefactor/grade/github/anypackage/chocolatey
[gallery-site]: https://www.powershellgallery.com/packages/AnyPackage.Chocolatey
[build-site]: https://github.com/anypackage/chocolatey/actions/workflows/ci.yml
[cf-site]: https://www.codefactor.io/repository/github/anypackage/chocolatey

`AnyPackage.Chocolatey` is an AnyPackage provider that facilitates installing Chocolatey packages from any NuGet repository.

## Install AnyPackage.Chocolatey

```powerShell
Install-Module AnyPackage.Chocolatey -Force
```

## Import AnyPackage.Chocolatey

```powerShell
Import-Module AnyPackage.Chocolatey
```

## Sample usages

### Search for a package

```powerShell
Find-Package -Name nodejs

Find-Package -Name firefox*
```

### Install a package

```powerShell
Find-Package nodejs | Install-Package

Install-Package -Name 7zip
```

### Get list of installed packages

```powerShell
Get-Package nodejs
```

### Uninstall a package

```powerShell
Get-Package keepass-plugin-winhello | Uninstall-Package
```

### Manage package sources

```powerShell
Register-PackageSource privateRepo -Provider Chocolatey -Location 'https://somewhere/out/there/api/v2/'
Find-Package nodejs -Source privateRepo | Install-Package
Unregister-PackageSource privateRepo
```

AnyPackage.Chocolatey integrates with Choco.exe to manage and store source information

## Known Issues

### Compatibility

AnyPackage.Chocolatey works with PowerShell for both FullCLR/'Desktop' (ex 5.1) and CoreCLR (ex: 7.0.1), though Chocolatey itself still requires FullCLR.

Users must upgrade to v0.1.0 or higher of this provider module prior to the release of Chocolatey v2 to ensure continued compatibility.

### Save a package

Save-Package is not supported with the AnyPackage.Chocolatey provider, due to Chocolatey not supporting package downloads without special licensing.

## Legal and Licensing

AnyPackage.Chocolatey is licensed under the [MIT license](./LICENSE).
