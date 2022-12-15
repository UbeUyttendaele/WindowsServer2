. .\function.ps1
$source_dir = ".\provisioning\scripts\"
get-childitem $source_dir | New-IsoFile -path .\iso\scripts.iso -Force