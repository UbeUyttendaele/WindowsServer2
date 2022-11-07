set PATH=%PATH%;"C:\Program Files\Oracle\VirtualBox"
$env:PATH = $env:PATH + ";C:\Program Files\Oracle\VirtualBox"
. .\function.ps1
$source_dir = ".\provisioning\scripts\"
get-childitem $source_dir | New-IsoFile -path .\iso\scripts.iso -Force
# Create a new VM
$windowsServerIso=".\iso\en_windows_server_2019_x64_dvd_4cb967d8.iso"
$exchangeIso=".\iso\mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
$windowsClientIso=".\iso\win10Client.iso"
$scriptsIso=".\iso\scripts.iso"


$dc="dc"
$web="web"
$mail="mail"
$ws="ws1"

function newVM($1, $2, $3, $4,$5,$6,$7,$8,$9) {
    #1: VM name 
    #2: VM os type
    #3: VM cores
    #4: VM RAM
    #5: VM VRAM
    #6: VM disk path
    #7: VM disk size
    #8: Iso path
    #9 exchange iso path
    

VBoxManage createvm --name $1 --ostype $2 --groups "/WS2"  --register
# if else to check if vm name is DC
if ( $1 -like $dc ){
    VBoxManage modifyvm $1 --cpus $3 --memory $4 --vram $5 --nic1 nat --nic2 intnet
}
else{
    VBoxManage modifyvm $1 --cpus $3 --memory $4 --vram $5 --nic1 intnet
}

VBoxManage storagectl $1 --name "IDE controller" --add sata --controller IntelAHCI --portcount 3 --bootable on
VBoxManage createmedium disk --filename $6 --size $7
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 0 --type hdd --medium $6
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 1 --type dvddrive --medium $8
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 2 --type dvddrive --medium $8
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 3 --type dvddrive --medium $8
}

function unattendedInstall($1, $2, $3) {
VBoxManage unattended install $1 --iso=$2 --hostname="${1}.ws2-2223-ube.hogent" --user=ladmin --password=Admin2021 --full-user-name=lAdmin --country=BE --image-index=$3 --start-vm=gui --post-install-command="powershell copy-Item -Path E: -Destination C:\scripts -Recurse && powershell C:\scripts\master.ps1 -deviceType ${1}"
}
function mountScripts($1, $2, $3) {
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 2 --type dvddrive --medium $2
if ( $1 -like "mail" ){
    VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 3 --type dvddrive --medium $3
}
}

function setupVM() {
for($i=0; $i -lt $args.Count; $i++){
    switch ($args[$i]){
        $dc {
            newVM "dc" "Windows2019_64" 2 8192 39 "./vm/dc.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso
            unattendedInstall "dc" $windowsServerIso 1
            mountScripts "dc" $scriptsIso
            }
        $web {
            newVM "web" "Windows2019_64" 2 2048 39 "./vm/web.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso
            unattendedInstall "web" $windowsServerIso 1
            mountScripts "web" $scriptsIso
            }
        $mail {
            newVM "mail" "Windows2019_64" 2 6144 39 "./vm/mail.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso
            unattendedInstall "mail" $windowsServerIso 1
            mountScripts "mail" $scriptsIso $exchangeIso
            }
        Default {
            newVM $args[$i]"Windows10_64" 1 2048 128 "./vm/${args[$i]}.vdi" 20480 $windowsClientIso $scriptsIso $exchangeIso
            unattendedInstall $args[$i] $windowsClientIso 1
            mountScripts $args[$i] $scriptsIso
            }
        }
}
}

#newVM "dctest" "Windows2019_64" 2 2048 39 "./vm/dctest.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso
#unattendedInstallTest "dctest" $windowsServerIso 1
#mountScripts "dctest" $scriptsIso

setupVM  $dc #$web $ws  
