# AnyPackage.Chocolatey
AnyPackage.Chocolatey is an AnyPackage provider that facilitates installing Chocolatey packages from any NuGet repository.

## Install AnyPackage.Chocolatey
```PowerShell
Install-Module AnyPackage.Chocolatey -Force
```

## Importing AnyPackage.Chocolatey
```PowerShell
Import-Module AnyPackage.Chocolatey
```

## Sample usages

### Search for a package
```PowerShell
Find-Package -Name nodejs

Find-Package -Name firefox*
```

### Install a package
```PowerShell
Find-Package nodejs | Install-Package

Install-Package -Name 7zip
```

### Get list of installed packages
```PowerShell
Get-Package nodejs
```

### Uninstall a package
```PowerShell
Get-Package keepass-plugin-winhello | Uninstall-Package
```

### Manage package sources
```PowerShell
Register-PackageSource privateRepo -Location 'https://somewhere/out/there/api/v2/'
Find-Package nodejs -Source privateRepo | Install-Package
Unregister-PackageSource privateRepo
```
AnyPackage.Chocolatey integrates with Choco.exe to manage and store source information

## Known Issues
### Compatibility
AnyPackage.Chocolatey works with PowerShell for both FullCLR/'Desktop' (ex 5.1) and CoreCLR (ex: 7.0.1), though Chocolatey itself still requires FullCLR.

### Save a package
Save-Package is not supported with the AnyPackage.Chocolatey provider, due to Chocolatey not supporting package downloads without special licensing.

## Legal and Licensing
AnyPackage.Chocolatey is licensed under the [MIT license](./LICENSE.txt).
