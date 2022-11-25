#! /bin/bash

echo "Making script ISO"
./makeIso.sh &> /dev/null


windowsServerIso="./iso/server.iso"
exchangeIso="./iso/exchange.iso"
windowsClientIso="./iso/client.iso"
sqlIso="./iso/sql.iso"
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
VBoxManage unattended install $1 --iso=$2 --hostname=$1.ws2-2223-ube.hogent --user=ladmin --password=Admin2021 --full-user-name=lAdmin --country=BE --image-index=$3 --start-vm=gui --post-install-command="powershell Set-ExecutionPolicy unrestricted localmachine && powershell copy-Item -Path E: -Destination C:\scripts -Recurse && start powershell C:\scripts\master.ps1 -deviceType ${4}"
}
function mountScripts() {
VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 2 --type dvddrive --medium $2
if [ $1 = "mail" ] || [ $1 = "sql" ]; then
    VBoxManage storageattach $1 --storagectl "IDE controller" --device 0 --port 3 --type dvddrive --medium $3
fi
}

function setupVM() {
for i in $*; do 

    case $i in

    dc)
        echo "---------------------------"
        command=
        echo "Creating ${i}"
        newVM "dc" "Windows2019_64" 2 2048 39 "./vm/dc.vdi" 25000 $windowsServerIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${i}"
        unattendedInstall "dc" $windowsServerIso 1 "dc" &> /dev/null
        echo "Mounting scripts"
        mountScripts "dc" $scriptsIso &> /dev/null
        ;;

    web)
        echo "---------------------------"
        echo "Creating ${i}"
        newVM "web" "Windows2019_64" 2 1024 39 "./vm/web.vdi" 20000 $windowsServerIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${i}"
        unattendedInstall "web" $windowsServerIso 1 "web" &> /dev/null
        echo "Mounting scripts"
        mountScripts "web" $scriptsIso &> /dev/null
        ;;
    sql)
        echo "---------------------------"
        echo "Creating ${i}"
        newVM "sql" "Windows2019_64" 1 1024 39 "./vm/sql.vdi" 25000 $windowsServerIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${i}"
        unattendedInstall "sql" $windowsServerIso 1 "sql" &> /dev/null
        echo "Mounting scripts"
        mountScripts "sql" $scriptsIso $sqlIso &> /dev/null
        ;;

    mail)
        echo "---------------------------"
        echo "Creating ${i}"
        newVM "mail" "Windows2019_64" 2 6144 39 "./vm/mail.vdi" 50000 $windowsServerIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${i}"
        unattendedInstall "mail" $windowsServerIso 1 "mail" &> /dev/null
        echo "Mounting scripts"
        mountScripts "mail" $scriptsIso $exchangeIso &> /dev/null
        ;;

    *)
        echo "---------------------------"
        echo "Creating ${i}"
        newVM $i "Windows10_64" 1 2048 128 "./vm/$i.vdi" 30000 $windowsClientIso $scriptsIso $exchangeIso &> /dev/null
        echo "Starting unattended install: ${i}"
        unattendedInstall $i $windowsClientIso 1 "ws" &> /dev/null
        echo "Mounting scripts"
        mountScripts $i $scriptsIso &> /dev/null
        ;;
    esac

done
}

#newVM "dctest" "Windows2019_64" 2 2048 39 "./vm/dctest.vdi" 20480 $windowsServerIso $scriptsIso $exchangeIso
#unattendedInstallTest "dctest" $windowsServerIso 1
#mountScripts "dctest" $scriptsIso

setupVM web