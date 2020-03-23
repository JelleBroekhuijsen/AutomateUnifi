# Ubiquity Unifi Controller VM managed by Azure Automation DSC

This repo contains ARM templates and supporting PowerShell-scripts to deploy a VM with Ubiquity's Unifi Controller-software via Chocolatey.

The template includes:
- Keyvault
- Storage account
- Automation Account
  - With cChoco DSC module
  - DSC configuration and compile tasks
- VM with network interface and the following extensions:
  - antimalware
  - DSC
  - diskencryption


## Dependencies
- Requires an existing subnet's resource ID as input parameter
- [cChoco DSC module](https://www.powershellgallery.com/packages/cChoco/)
- Chocolatey packages: 
  - [Ubiquiti UniFI Controller](https://chocolatey.org/packages/ubiquiti-unifi-controller)
  - [AutoHotkey (Portable)](https://chocolatey.org/packages/autohotkey.portable)
  - [Java Runtime (JRE)](https://chocolatey.org/packages/javaruntime)

## Tested scenarios
- End-to-end deployment

## Future work
- Automatically restore backups

## Release notes
2020-03-22: Initial release

## How-to / design:
[Link to be posted](https://blog.jll.io)