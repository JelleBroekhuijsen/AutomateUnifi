Configuration dscAutomateUnifi
{
    Import-DscResource -ModuleName cChoco   
    
    cChocoInstaller installChoco
    {
        InstallDir = 'c:\choco'
    }
    cChocoPackageInstaller javaRuntime
    {
        Name = "javaruntime"
        AutoUpgrade = $True
        DependsOn = "[cChocoInstaller]installChoco"
    }
    cChocoPackageInstaller autohotkeyPortable
    {
        Name = "autohotkey.portable"
        AutoUpgrade = $True
        DependsOn = "[cChocoPackageInstaller]javaRuntime"
    }
    cChocoPackageInstaller unifiController
    {
        Name = "ubiquiti-unifi-controller"
        AutoUpgrade = $True
        DependsOn = "[cChocoPackageInstaller]autoHotKeyPortable"
    }
}