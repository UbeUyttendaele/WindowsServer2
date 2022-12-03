set PATH=%PATH%;"C:\Program Files\Oracle\VirtualBox"
$env:PATH = $env:PATH + ";C:\Program Files\Oracle\VirtualBox"
. .\function.ps1
$source_dir = ".\provisioning\scripts\"
echo "Making script ISO"
get-childitem $source_dir | New-IsoFile -path .\iso\scripts.iso -Force
# Create a new VM
$windowsServerIso=".\iso\en_windows_server_2019_x64_dvd_4cb967d8.iso"
$exchangeIso=".\iso\mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
$windowsClientIso=".\iso\win10Client.iso"
$sqlIso=".\iso\sql.iso"
$scriptsIso=".\iso\scripts.iso"


$dc="dc"
$web="web"
$mail="mail"
$sql="sql"
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

function unattendedInstall($1, $2, $3, $4) {
VBoxManage unattended install $4 --iso=$2 --hostname="${1}.ws2-2223-ube.hogent" --user=ladmin --password=Admin2021 --full-user-name=lAdmin --country=BE --image-index=$3 --start-vm=gui --post-install-command="powershell copy-Item -Path E: -Destination C:\scripts -Recurse && powershell C:\scripts\master.ps1 -deviceType ${1}"
}
function mountScripts($1, $2, $3, $4) {
VBoxManage storageattach $4 --storagectl "IDE controller" --device 0 --port 2 --type dvddrive --medium $2

if ( $1 -like "mail" || $1 -like "sql"){
    VBoxManage storageattach $3 --storagectl "IDE controller" --device 0 --port 3 --type dvddrive --medium $4
}
}

function setupVM() {
for($i=0; $i -lt $args.Count; $i++){
    switch ($args[$i]){
        $dc {
            echo "---------------------------"
            echo "Creating ${dc}"
            newVM $args[$i] "Windows2019_64" 2 2048 39 "./vm/dc.vdi" 25000 $windowsServerIso $scriptsIso $exchangeIso
            echo "Starting unattended install"
            unattendedInstall "dc" $windowsServerIso 1 $args[$i]
            echo "Mounting scripts"
            mountScripts "dc" $scriptsIso $args[$i]
            }
        $web {
            echo "---------------------------"
            echo "Creating ${web}"
            newVM $args[$i] "Windows2019_64" 2 2048 39 "./vm/web.vdi" 20000 $windowsServerIso $scriptsIso $exchangeIso
            echo "Starting unattended install"
            unattendedInstall "web" $windowsServerIso 1 $args[$i]
            echo "Mounting scripts"
            mountScripts "web" $scriptsIso $args[$i]
            }
        $mail {
            echo "---------------------------"
            echo "Creating ${mail}"
            newVM $args[$i] "Windows2019_64" 2 6144 39 "./vm/mail.vdi" 50000 $windowsServerIso $scriptsIso $exchangeIso
            echo "Starting unattended install"
            unattendedInstall "mail" $windowsServerIso 1 $args[$i]
            echo "Mounting scripts"
            mountScripts "mail" $scriptsIso $args[$i] $exchangeIso
            
            }
        $sql {
            echo "---------------------------"
            echo "Creating ${sql}"
            newVM $args[$i] "Windows2019_64" 1 1024 39 "./vm/mail.vdi" 25000 $windowsServerIso $scriptsIso $exchangeIso
            echo "Starting unattended install"
            unattendedInstall "sql" $windowsServerIso 1 $args[$i]
            echo "Mounting scripts"
            mountScripts "mail" $scriptsIso $args[$i] $sqlIso
            }
        Default {
            echo "---------------------------"
            echo "Creating ${args[i]}"
            newVM $args[$i] "Windows10_64" 1 2048 128 "./vm/${args[$i]}.vdi" 30000 $windowsClientIso $scriptsIso $exchangeIso
            echo "Starting unattended install"
            unattendedInstall "ws" $windowsClientIso 1 $args[$i]
            echo "Mounting scripts"
            mountScripts $args[$i] $scriptsIso $args[$i]
            }
        }
}
}

#newVM "dctest" "Windows2019_64" 2 2048 39 "./vm/dctest.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso
#unattendedInstallTest "dctest" $windowsServerIso 1
#mountScripts "dctest" $scriptsIso

setupVM $dc $web $ws  
