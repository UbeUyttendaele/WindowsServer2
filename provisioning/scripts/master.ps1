param (
    $deviceType="dc",
    $step="1"
)

$script = "C:\scripts\master.ps1"
. (Join-Path $PSScriptRoot function.ps1)
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

Clear-Any-Restart

switch ($deviceType) {

  dc {
    if (Should-Run-Step "1") {
	    Write-Host "Executing stage 1 / user:$env:UserName" -ForegroundColor yellow
      invoke-expression "C:\scripts\dc\stage1.ps1"
	    Wait-For-Keypress "The script will continue after a reboot, press any key to reboot..." 
	    Restart-And-Resume $script -deviceType $deviceType -step "2"
    }
    if (Should-Run-Step "2") {
	    Write-Host "Executing stage 2 / user:$env:UserName" -ForegroundColor yellow
      invoke-expression "C:\scripts\dc\stage2.ps1"
      Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
      Set-ItemProperty $RegPath "DefaultUsername" -Value "WS2-2223-UBE\Administrator" -type String 
      Set-ItemProperty $RegPath "DefaultPassword" -Value "Admin2021" -type String
      Wait-For-Keypress "The script will continue after a reboot, press any key to reboot..." 
      Restart-And-Resume $script -deviceType $deviceType -step "3"
    }
    if (Should-Run-Step "3") {
	    Write-Host "Executing stage 3 / user:$env:UserName" -ForegroundColor yellow
      invoke-expression "C:\scripts\dc\stage3.ps1"
	    #Wait-For-Keypress "Before continuing the script wait until Web is done setting up the DNS server, press any key to continue..."
      #invoke-expression "C:\scripts\dc\stage4.ps1"
	    Wait-For-Keypress "Script complete"
    }
    }

  web {
    if (Should-Run-Step "1") {
	    Write-Host "Executing stage 1 / user:$env:UserName" -ForegroundColor yellow
	    Wait-For-Keypress "Before continuing the script wait until DC is done configuring, press any key to continue..." 
      invoke-expression "C:\scripts\web\stage1.ps1"
      Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
      Set-ItemProperty $RegPath "DefaultUsername" -Value "WS2-2223-UBE\Administrator" -type String 
      Set-ItemProperty $RegPath "DefaultPassword" -Value "Admin2021" -type String
      Wait-For-Keypress "The script will continue after a reboot, press any key to reboot..." 
	    Restart-And-Resume $script -deviceType $deviceType -step "2"
    }
    if (Should-Run-Step "2") {
	    Write-Host "Executing stage 2 / user:$env:UserName" -ForegroundColor yellow
      invoke-expression "C:\scripts\web\stage2.ps1"
      invoke-expression "C:\scripts\web\stage3.ps1"
	    Wait-For-Keypress "Script complete"
    }
      }

  sql {
    if (Should-Run-Step "1") {
	    Write-Host "Executing stage 1 / user:$env:UserName" -ForegroundColor yellow
	    Wait-For-Keypress "Before continuing the script wait until DC is done configuring, press any key to continue..." 
      invoke-expression "C:\scripts\sql\stage1.ps1"
      Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
      Set-ItemProperty $RegPath "DefaultUsername" -Value "WS2-2223-UBE\Administrator" -type String 
      Set-ItemProperty $RegPath "DefaultPassword" -Value "Admin2021" -type String
      Wait-For-Keypress "The script will continue after a reboot, press any key to reboot..." 
	    Restart-And-Resume $script -deviceType $deviceType -step "2"
    }
    if (Should-Run-Step "2") {
	    Write-Host "Executing stage 2 / user:$env:UserName" -ForegroundColor yellow
      invoke-expression "C:\scripts\sql\stage2.ps1"
      Wait-For-Keypress "The script will continue after a reboot, press any key to reboot..." 
	    Restart-And-Resume $script -deviceType $deviceType -step "3"
    }
    if (Should-Run-Step "3") {
      Write-Host "Executing stage 3 / user:$env:UserName" -ForegroundColor yellow
	    invoke-expression "C:\scripts\sql\stage3.ps1"
      Wait-For-Keypress "Script complete"
    }
  }


  mail {
    if (Should-Run-Step "1") {
	    Write-Host "Executing stage 1 / user:$env:UserName" -ForegroundColor yellow
	    Wait-For-Keypress "Before continuing the script wait until DC and Web are done configuring, press any key to continue..." 
      invoke-expression "C:\scripts\mail\stage1.ps1"
      Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
      Set-ItemProperty $RegPath "DefaultUsername" -Value "WS2-2223-UBE\Administrator" -type String 
      Set-ItemProperty $RegPath "DefaultPassword" -Value "Admin2021" -type String
      Wait-For-Keypress "Script complete, press any key to reboot..." 
    }
    }


  ws {
    if (Should-Run-Step "1") {
	    Write-Host "Executing stage 1 / user:$env:UserName" -ForegroundColor yellow
	    Wait-For-Keypress "Before continuing the script wait until DC and Web are done configuring, press any key to continue..." 
      invoke-expression "C:\scripts\ws\stage1.ps1"
      Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
      Set-ItemProperty $RegPath "DefaultUsername" -Value "WS2-2223-UBE\Administrator" -type String 
      Set-ItemProperty $RegPath "DefaultPassword" -Value "Admin2021" -type String
      Wait-For-Keypress "Script complete, press any key to reboot..." 
	    shutdown /r /t 0
    }
      }
  default { "Uh, something unexpected happened"
  ; break}
}