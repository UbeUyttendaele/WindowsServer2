. .\function.ps1
$source_dir = ".\provisioning\"
get-childitem $source_dir | New-IsoFile -path .\iso\scripts2.iso -Force