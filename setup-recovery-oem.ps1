#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Run ONCE after fresh Windows install (as Administrator).
    Sets up C:\Recovery\OEM\ so Reset PC always skips online account.
    These files survive every future reset — never need to run again.

.USAGE
    Option A - Local:
        powershell -ExecutionPolicy Bypass -File setup-recovery-oem.ps1

    Option B - Direct from web (host this file online):
        irm "https://raw.githubusercontent.com/techvalleyapps/WinRecoveryFix/main/setup-recovery-oem.ps1" | iex
#>

function Step { param($m) Write-Host "`n>> $m" -ForegroundColor Cyan }
function OK   { param($m) Write-Host "   OK: $m" -ForegroundColor Green }
function Fail { param($m) Write-Host "   ERROR: $m" -ForegroundColor Red; exit 1 }

Step "Creating C:\Recovery if missing..."
if (-not (Test-Path "C:\Recovery")) {
    New-Item -ItemType Directory -Path "C:\Recovery" | Out-Null
    OK "Created"
} else { OK "Already exists" }

Step "Taking ownership and granting write access..."
takeown /f "C:\Recovery" /r /d Y 2>$null | Out-Null
icacls "C:\Recovery" /grant "Administrators:F" /t /c /q | Out-Null
OK "Permissions set"

Step "Creating C:\Recovery\OEM..."
New-Item -ItemType Directory -Force -Path "C:\Recovery\OEM" | Out-Null
OK "Folder ready"

Step "Writing ResetConfig.xml..."
@'
<?xml version="1.0" encoding="utf-8"?>
<Reset>
  <Run Phase="BasicReset_AfterImageApply">
    <Path>Restore.cmd</Path>
    <Duration>2</Duration>
  </Run>
  <Run Phase="FactoryReset_AfterImageApply">
    <Path>Restore.cmd</Path>
    <Duration>2</Duration>
  </Run>
</Reset>
'@ | Set-Content "C:\Recovery\OEM\ResetConfig.xml" -Encoding UTF8
OK "ResetConfig.xml"

Step "Writing Restore.cmd..."
@'
@echo off
if not exist "C:\Windows\Panther" mkdir "C:\Windows\Panther"
copy /y "%~dp0unattend.xml" "C:\Windows\Panther\unattend.xml" >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v BypassNRO /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v NoConnectedUser /t REG_DWORD /d 3 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v NoConnectedUser /t REG_DWORD /d 3 /f >nul
exit /b 0
'@ | Set-Content "C:\Recovery\OEM\Restore.cmd" -Encoding ASCII
OK "Restore.cmd"

Step "Writing unattend.xml..."
@'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend"
          xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">

  <settings pass="specialize">
    <component name="Microsoft-Windows-Shell-Setup"
               processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35"
               language="neutral" versionScope="nonSxS">
      <ComputerName>WIN11-PC</ComputerName>
    </component>
    <component name="Microsoft-Windows-International-Core"
               processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35"
               language="neutral" versionScope="nonSxS">
      <InputLocale>0809:00000809</InputLocale>
      <SystemLocale>en-GB</SystemLocale>
      <UILanguage>en-GB</UILanguage>
      <UserLocale>en-GB</UserLocale>
    </component>
  </settings>

  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-International-Core"
               processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35"
               language="neutral" versionScope="nonSxS">
      <InputLocale>0809:00000809</InputLocale>
      <SystemLocale>en-GB</SystemLocale>
      <UILanguage>en-GB</UILanguage>
      <UserLocale>en-GB</UserLocale>
    </component>
    <component name="Microsoft-Windows-Shell-Setup"
               processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35"
               language="neutral" versionScope="nonSxS">
      <TimeZone>GMT Standard Time</TimeZone>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
        <HideLocalAccountScreen>false</HideLocalAccountScreen>
        <NetworkLocation>Work</NetworkLocation>
        <ProtectYourPC>3</ProtectYourPC>
        <SkipMachineOOBE>false</SkipMachineOOBE>
        <SkipUserOOBE>false</SkipUserOOBE>
      </OOBE>
      <FirstLogonCommands>
        <SynchronousCommand wcm:action="add">
          <Order>1</Order>
          <CommandLine>reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v NoConnectedUser /t REG_DWORD /d 3 /f</CommandLine>
          <RequiresUserInput>false</RequiresUserInput>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <Order>2</Order>
          <CommandLine>reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v BypassNRO /t REG_DWORD /d 1 /f</CommandLine>
          <RequiresUserInput>false</RequiresUserInput>
        </SynchronousCommand>
      </FirstLogonCommands>
    </component>
  </settings>

</unattend>
'@ | Set-Content "C:\Recovery\OEM\unattend.xml" -Encoding UTF8
OK "unattend.xml"

Step "Restoring C:\Recovery hidden/system attributes..."
& attrib +h +s "C:\Recovery"
OK "Done"

Step "Verifying files..."
$ok = $true
foreach ($f in @("ResetConfig.xml","Restore.cmd","unattend.xml")) {
    if (Test-Path "C:\Recovery\OEM\$f") { OK $f }
    else { Write-Host "   MISSING: $f" -ForegroundColor Red; $ok = $false }
}

if ($ok) {
    Write-Host @"

==============================================================
  ALL DONE.

  Reset PC > Remove all files will now always:
  - Skip online account screen
  - Show Windows local account creation screen
  - You choose your own username and password at that point

  This survives every future reset. Never run this again.
==============================================================
"@ -ForegroundColor Green
} else {
    Fail "Some files missing — check errors above."
}
