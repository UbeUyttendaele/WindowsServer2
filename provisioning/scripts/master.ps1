param (
    $deviceType="dc",
    $step="1"
)

$script = "C:\scripts\master.ps1"
$scriptPath = Split-Path -parent $script
. (Join-Path $scriptpath function.ps1)

Clear-Any-Restart

switch ($deviceType) {

  dc {
    if (Should-Run-Step "1") {
	    Write-Host "Executing stage 1" -ForegroundColor yellow
      invoke-expression "C:\scripts\dc\stage1.ps1"
	    Wait-For-Keypress "The script will continue after a reboot, press any key to reboot..." 
	    Restart-And-Resume $script -deviceType $deviceType -step "2"
    }
    if (Should-Run-Step "2") {
	    Write-Host "Executing stage 2"
      invoke-expression "C:\scripts\dc\stage2.ps1"
	    Wait-For-Keypress "Script complete, reboot is required, press any key to exit script and reboot the system..."
      shutdown /r /t 0
    }
    }


  web {
    if (Should-Run-Step "1") {
	    Write-Host "Executing stage 1" -ForegroundColor yellow
	    Wait-For-Keypress "Before continuing the script wait until DC is done configuring the domain, press any key to continue..." 
      invoke-expression "C:\scripts\web\stage1.ps1"
      Wait-For-Keypress "The script will continue after a reboot, before continuing wait until DC is done configuring the domain, press any key to reboot..." 
	    Restart-And-Resume $script -deviceType $deviceType -step "2"
    }
    if (Should-Run-Step "2") {
	    Write-Host "Executing stage 2"
        $credential = New-object -TypeName System.Management.Automation.PSCredential -ArgumentList "Administrator", (ConvertTo-SecureString -AsPlainText "Admin2021" -Force)
        $s = New-PSSession -credential $credential
        Invoke-Command -Session $s -Scriptblock {invoke-expression "C:\scripts\web\stage2.ps1"}
        Remove-PSSession $s 
	    Wait-For-Keypress "Script complete, reboot is required, press any key to exit script and reboot the system..."
        shutdown /r /t 0
    }
      }


  mail {
    Write-Host "Device type found"
    $path = ".\mail\stage$stage.ps1"
    }


  ws {
    if (Should-Run-Step "1") {
	    Write-Host "Executing stage 1" -ForegroundColor yellow
	    Wait-For-Keypress "Before continuing the script wait until DC is done configuring the domain, press any key to continue..." 
        invoke-expression "C:\scripts\ws\stage1.ps1"
        Wait-For-Keypress "The script will continue after a reboot, before continuing wait until DC is done configuring the domain, press any key to reboot..." 
	    shutdown /r /t 0
    }
      }
  default { "Uh, something unexpected happened"
  ; break}
}