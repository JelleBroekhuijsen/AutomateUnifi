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
- The solution is currently dependent on a subnetResourceId being provided to it. This means you need to have or create a virtual network in your Azure environment before you can deploy this solution. Also the example now uses a static IP config in the 10.0.10.0/24 address space. This IP can and should be changed to reflect your own vnet configuration. You can set it to 'dynamic', however, I do not recommend this since Unifi AP's don't handle IP changes in their controller very well.
- The package is being installed in the Windows\syswow64\config\sytemprofile directory as this is the %userprofile% directory for the SYSTEM account. You might want to keep this in mind when using this specific solution in a production environment.  
- Since this solution is designed with for multiple ARM deployment tasks a 'complete'-mode deployment is only supported for the first deployment in the chain.

## Dependencies
- Requires an existing subnet's resource ID as input parameter
- [cChoco DSC module](https://www.powershellgallery.com/packages/cChoco/)
- Chocolatey packages: 
  - [Ubiquiti UniFI Controller](https://chocolatey.org/packages/ubiquiti-unifi-controller)
  - [AutoHotkey (Portable)](https://chocolatey.org/packages/autohotkey.portable)
  - [Java Runtime (JRE)](https://chocolatey.org/packages/javaruntime)

## Tested scenarios
- Deployment from a Azure DevOps release pipeline as described in [Automating Desired State Configuration](https://blog.jll.io/2020/03/23/automating-desired-state-configuration/)

## Future work
- Automatically restore backups

## Release notes
- 2020-03-24: Changed vmImageSku to 2019-Datacenter after encountering incompatibility with 2019-Datacenter-core. Adjusted the vmSize to Standard_B1ms to compensate for the bigger memory footprint. Added 2 task to DSC script to get the software in a running state after deployment.
- 2020-03-23: Added a reference yml-build file and fixed an issue where a vm password would be generated on a incremental deployment.
- 2020-03-22: Initial release.

## How-to / design:
[Automating Desired State Configuration](https://blog.jll.io/2020/03/23/automating-desired-state-configuration/)