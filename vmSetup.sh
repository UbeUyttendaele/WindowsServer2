#! /bin/bash

# Create a new VM
windowsServerIso="./iso/en_windows_server_2019_x64_dvd_4cb967d8.iso"
exchangeIso="./iso/mul_exchange_server_2019_cumulative_update_12_x64_dvd_52bf3153.iso"
windowsClientIso="./iso/win10Client.iso"
guestAdditionsIso="./iso/VBoxGuestAdditions_6.1.38.iso"

function newVM() {
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
if [ $1 = "dc" ]; then
    VBoxManage modifyvm $1 --cpus $3 --memory $4 --vram $5 --nic1 nat --nic2 intnet 
else
    VBoxManage modifyvm $1 --cpus $3 --memory $4 --vram $5 --nic1 intnet
fi
vboxmanage storagectl $1 --name "IDE controller" --add sata --controller IntelAHCI --portcount 2 --bootable on
VBoxManage createmedium disk --filename $6 --size $7
vboxmanage storageattach $1 --storagectl "IDE controller" --device 0 --port 0 --type hdd --medium $6
vboxmanage storageattach $1 --storagectl "IDE controller" --device 0 --port 1 --type dvddrive --medium $8
if [ $1 = "Mail" ]; then
vboxmanage storageattach $1 --storagectl "IDE controller" --device 0 --port 2 --type dvddrive --medium $9
fi
vboxmanage sharedfolder add $1 --name "provisioning" --hostpath "./provisioning" --automount
}

function unattendedInstall() {
VBoxManage unattended install $1 --iso=$2 --hostname=$1.ws2-2223-ube.hogent --user=admin --password=Admin2021 --install-additions --additions-iso=$3 --full-user-name=Administrator --country=BE --start-vm=gui --post-install-command="shutdown /r /t 0"
}

newVM "dc" "Windows2019_64" 2 2048 39 "./vm/DC.vdi" 20480 $windowsServerIso
newVM "web" "Windows2019_64" 2 2048 39 "./vm/Wev.vdi" 20480 $windowsServerIso
#newVM "mail" "Windows2019_64" 2 6144 39 "./vm/Mail.vdi" 20480 $windowsServerIso $exchangeIso
newVM "ws1" "Windows10_64" 1 2048 128 "./vm/ws1.vdi" 20480 $windowsClientIso

unattendedInstall "dc" $windowsServerIso $guestAdditionsIso
unattendedInstall "web" $windowsServerIso $guestAdditionsIso
#unattendedInstall "mail" $windowsServerIso $guestAdditionsIso
unattendedInstall "ws1" $windowsClientIso $guestAdditionsIso


