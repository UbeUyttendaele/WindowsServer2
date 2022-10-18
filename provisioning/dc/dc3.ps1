$groepen = @("Enterprise Admins")
try {
    foreach($groep in $groepen) {
        Add-ADGroupmember -Identity "$groep" -Members "admin" -ErrorAction Stop | out-null
    } 
}
catch {
    Write-Warning -Message $("Failed to complete task:"+ $_.Exception.Message)
}