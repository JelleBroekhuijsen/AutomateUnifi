# Ubiquiti Unifi Controller VM managed by Azure Automation DSC

This repo contains ARM templates and supporting PowerShell-scripts to deploy a VM with Ubiquity's Unifi Controller-software via Chocolatey.

The templates includes:
- Keyvault
- Storage account
- Automation Account
  - With cChoco DSC module
  - DSC configuration and compile tasks
- VM with network interface and the following extensions:
  - antimalware
  - DSC
  - diskencryption

The powershell scripts include:
 - A script to generate a VM password and Key Encryption Key (KEK) and publish them to a key vault
 - A script to copy the DSC config to a storage account blob container
 - A script to write ARM-output back to the DevOps release pipeline

# Limitations
- The solution is currently dependent on a subnetResourceId being provided to it. This means you need to have or create a vnet in your Azure environment before you can deploy this solution. Also the example now uses a static IP config in the 10.0.10.0/24 address space. This IP can and should be changed to reflect your own vnet configuration. You can set it to 'dynamic' however I do not recommend this since Unifi AP's don't handle IP changes in their controller very well.

## Dependencies
- Requires an existing subnet's resource ID as input parameter
- [cChoco DSC module](https://www.powershellgallery.com/packages/cChoco/)
- Chocolatey packages: 
  - [Ubiquiti UniFI Controller](https://chocolatey.org/packages/ubiquiti-unifi-controller)
  - [AutoHotkey (Portable)](https://chocolatey.org/packages/autohotkey.portable)
  - [Java Runtime (JRE)](https://chocolatey.org/packages/javaruntime)

## Tested scenarios
- End-to-end deployment
- Incremental deployment

## Future work
- Automatically restore backups

## Release notes
- 2020-03-23: Added a reference yml-build file and fixed an issue where a vm password would be generated on a incremental deployment
- 2020-03-22: Initial release

## How-to / design:
[Automating Desired State Configuration](https://blog.jll.io/2020/03/23/automating-desired-state-configuration/)
