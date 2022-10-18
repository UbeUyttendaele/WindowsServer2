param (
    [String]$deviceType="1"
    [String]$stage="2"
)


switch ($hostname) {
  "dc" {
        switch ($stage) {
          "1" { .\dc\stage1.ps1 ; break }
          "2" { .\dc\stage2.ps1 ; break }
          "3" { .\dc\stage3.ps1 ; break }
          default { "Uh, something unexpected happened" }
        }  
        ; break 
      }
  "web" {
        switch ($stage) {
          "1" { .\web\stage1.ps1 ; break }
          "2" { .\web\stage2.ps1 ; break }
          "3" { .\web\stage3.ps1 ; break }
          default { "Uh, something unexpected happened" }
        }  
        ; break 
      }
  "mail" {
        switch ($stage) {
          "1" { .\mail\stage1.ps1 ; break }
          "2" { .\mail\stage2.ps1 ; break }
          "3" { .\mail\stage3.ps1 ; break }
          default { "Uh, something unexpected happened" }
        }  
        ; break 
    }
  "ws" {
        switch ($stage) {
          "1" { .\ws\stage1.ps1 ; break }
          "2" { .\dc\stage2.ps1 ; break }
          "3" { .\dc\stage3.ps1 ; break }
          default { "Uh, something unexpected happened" }
        }  
        ; break 
      }
  default { "Uh, something unexpected happened" }
}



