param (
    [String]$deviceType="1",
    [String]$stage="2"
)


switch ($deviceType) {
  dc {
    Write-Host "Device type found"
    $path = ".\dc\stage$stage.ps1"
      }
  web {
    Write-Host "Device type found"
    $path = ".\web\stage$stage.ps1"
      }
  mail {
    Write-Host "Device type found"
    $path = ".\mail\stage$stage.ps1"
    }
  ws {
    Write-Host "Device type found"
    $path = ".\ws\stage$stage.ps1"
      }
  default { "Uh, something unexpected happened, deviceType not found"
  ; break}
}
invoke-expression $path  



