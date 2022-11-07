#! /bin/bash

echo "Making script ISO"
./makeIso.sh &> /dev/null


windowsServerIso="./iso/en_windows_server_2019_x64_dvd_4cb967d8.iso"
exchangeIso="./iso/mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
sqlIso="./iso/win10Client.iso"
windowsClientIso="./iso/win10Client.iso"
guestAdditionsIso="./iso/VBoxGuestAdditions_6.1.38.iso"
scriptsIso="./iso/scripts.iso"


# Create a new VM
function newVM() {

VBoxManage createvm --name $1 --ostype $2 --groups "/WS2"  --register
# if else to check if vm name is DC
if [ $1 = "dc" ]; then
    VBoxManage modifyvm $1 --cpus $3 --memory $4 --vram $5 --nic1 nat --nic2 intnet 
else
    VBoxManage modifyvm $1 --cpus $3 --memory $4 --vram $5 --nic1 intnet
fi

VBoxManage storagectl $1 --name "IDE controller" --add sata --controller IntelAHCI --portcount 3 --bootable on
VBoxManage createmedium disk --filename $6 --size $7
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 0 --type hdd --medium $6
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 1 --type dvddrive --medium $8
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 2 --type dvddrive --medium $9
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 3 --type dvddrive --medium ${10}
}

function unattendedInstall() {
VBoxManage unattended install $1 --iso=$2 --hostname=$1.ws2-2223-ube.hogent --user=ladmin --password=Admin2021 --full-user-name=lAdmin --country=BE --image-index=$3 --start-vm=gui --post-install-command="powershell copy-Item -Path E: -Destination C:\scripts -Recurse && powershell C:\scripts\master.ps1 -deviceType ${1}"
}
function mountScripts() {
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 2 --type dvddrive --medium $2
if [ $1 = "mail" ] || [ $1 = "web" ]; then
    VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 3 --type dvddrive --medium $3
fi
}

function setupVM() {
for i in $*; do 

    case $i in

    dc)
        echo "---------------------------"
        echo "Creating ${1}"
        newVM "dc" "Windows2019_64" 2 2048 39 "./vm/dc.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${1}"
        unattendedInstall "dc" $windowsServerIso 1 &> /dev/null
        echo "Mounting scripts"
        mountScripts "dc" $scriptsIso &> /dev/null
        ;;

    web)
        echo "Creating ${1}"
        newVM "web" "Windows2019_64" 2 2048 39 "./vm/web.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${1}"
        unattendedInstall "web" $windowsServerIso 1 &> /dev/null
        mountScripts "web" $scriptsIso $sqlIso &> /dev/null
        ;;

    mail)
        echo "Creating ${1}"
        newVM "mail" "Windows2019_64" 2 6144 39 "./vm/mail.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${1}"
        unattendedInstall "mail" $windowsServerIso 1 &> /dev/null
        echo "Mounting scripts"
        mountScripts "mail" $scriptsIso $exchangeIso &> /dev/null
        ;;

    *)
        echo "Creating ${1}"
        newVM $i "Windows10_64" 1 2048 128 "./vm/$i.vdi" 20480 $windowsClientIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${1}"
        unattendedInstall $i $windowsClientIso 1 &> /dev/null
        echo "Mounting scripts"
        mountScripts $i $scriptsIso &> /dev/null
        ;;
    esac

done
}

#newVM "dctest" "Windows2019_64" 2 2048 39 "./vm/dctest.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso
#unattendedInstallTest "dctest" $windowsServerIso 1
#mountScripts "dctest" $scriptsIso

setupVM dc #web #ws1 
