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
    Script installService{
        TestScript = {(Get-Service "Unifi" -ErrorAction SilentlyContinue) -ne $null}
        SetScript = {
            Start-Process java -WorkingDirectory "C:\WINDOWS\SysWOW64\config\systemprofile\Ubiquiti Unifi\lib" -ArgumentList "-jar ace.jar installsvc"
        }
        GetScript = {@{Result = (Get-Service "Unifi").Status}}
        DependsOn = "[cChocoPackageInstaller]unifiController"
    }
    Script startService{
        TestScript = {(Get-Service "Unifi" -ErrorAction SilentlyContinue).Status -eq 'Running'}
        SetScript = {
            Start-Process java -WorkingDirectory "C:\WINDOWS\SysWOW64\config\systemprofile\Ubiquiti Unifi\lib" -ArgumentList "-jar ace.jar startsvc"
        }
        GetScript = {@{Result = (Get-Service "Unifi").Status}}
        DependsOn = "[Script]installService"
    }
}