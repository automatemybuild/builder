#!/bin/bash
#
# functions.sh - Common functions used by builder.sh
#
# Updates:
# 07/08/2020 - Created to be souced into scripts that require common functions
# 03/24/2024 - Removed funtions no longer used
# 

function header () {
  line=$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' +)
  printf "\n${YELLOW}${line}${WHITE}${*}${YELLOW}\n${line}${NC}\n"
}
function packagemgr { 
    if hash dnf 2>/dev/null; then
        export pkgmgr=dnf
    elif hash yum 2>/dev/null; then
        export pkgmgr=yum
    elif hash apt 2>/dev/null; then
        export pkgmgr=apt
    else
        echo ">> No package installers found."
        exit 1
    fi
    echo ">> Package manager set to ${pkgmgr}"
}
function set_static_hostname {
	hostnamectl status
	read -p "Enter static short hostname: " staticname
	echo "sudo hostnamectl set-hostname $staticname"
	hostnamectl set-hostname $staticname
	hostnamectl status
}
function set_timezone {
	sudo echo "America/New_York" > /etc/timezone
	timedatectl set-timezone America/New_York
	timedatectl
}
function flatpak_repositories {
	echo "Add flatpak repositories..."
	[[ "$(read -e -p 'FlatHub? [y/N] '; echo $REPLY)" == [Yy]* ]] && \
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}
function flatpak_update {
    if hash flatpak 2>/dev/null; then
        sudo flatpak update -y
    else
        echo "flatpak not installed"
    fi
}
function common_package_installs {
    [[ -z $pkgmgr ]] && packagemgr
    echo "Common packages: vim, tree, htop.wavemon, nmap, iperf3, iftop, nethogs, inxi, evemu, tmux, geany, gimp, lnav, figlet, xdotool, sysstat"
	[ ! -x "$(command -v curl)" ] && header "install curl" && sudo ${pkgmgr} -y install curl
	[ ! -x "$(command -v evemu-event)" ] && header "install evemu" && sudo ${pkgmgr} -y install evemu
	[ ! -x "$(command -v evemu-event)" ] && header "install evemu-tools" && sudo ${pkgmgr} -y install evemu-tools
	[ ! -x "$(command -v exiftool)" ] && header "install libimage-exiftool-perl" && sudo ${pkgmgr} -y install libimage-exiftool-perl
	[ ! -x "$(command -v fdupes)" ] && header "install fdupes" && sudo ${pkgmgr} -y install fdupes
	header "install figlet" && sudo ${pkgmgr} -y install figlet
	[ ! -x "$(command -v gimp)" ] && header "install gimp" && sudo ${pkgmgr} -y install gimp
	[ ! -x "$(command -v git)" ] && header "install git" && sudo ${pkgmgr} -y install git
	[ ! -x "$(command -v htop)" ] && header "install htop" && sudo ${pkgmgr} -y install htop
	[ ! -x "$(command -v identify)" ] && header "install ImageMagick" && sudo ${pkgmgr} -y install ImageMagick
	[ ! -x "$(command -v iftop)" ] && header "install iftop" && sudo ${pkgmgr} -y install iftop
	[ ! -x "$(command -v inxi)" ] && header "install inxi" && sudo ${pkgmgr} -y install inxi
	[ ! -x "$(command -v inxi)" ] && header "install inxi" && sudo ${pkgmgr} -y install inxi
	[ ! -x "$(command -v iperf3)" ] && header "install iperf3" && sudo ${pkgmgr} -y install iperf3
	[ ! -x "$(command -v lnav)" ] && header "install lnav" && sudo ${pkgmgr} -y install lnav
	[ ! -x "$(command -v neofetch)" ] && header "install neofetch" && sudo ${pkgmgr} -y install neofetch
	[ ! -x "$(command -v nethogs)" ] && header "install nethogs" && sudo ${pkgmgr} -y install nethogs
	[ ! -x "$(command -v nmap)" ] && header "install nmap" && sudo ${pkgmgr} -y install nmap
	[ ! -x "$(command -v nmtui)" ] && header "install nmtui" && sudo ${pkgmgr} -y install nmtui
	[ ! -x "$(command -v pip)" ] && header "install python3-pip" && sudo ${pkgmgr} -y install python3-pip
	[ ! -x "$(command -v python3)" ] && header "install python3" && sudo ${pkgmgr} -y install python3
	header "install python3-tqdm" && sudo ${pkgmgr} -y install python3-tqdm
	[ ! -x "$(command -v sar)" ] && header "install sysstat" && sudo ${pkgmgr} -y install sysstat
	[ ! -x "$(command -v tmux)" ] && header "install tmux" && sudo ${pkgmgr} -y install tmux
	[ ! -x "$(command -v traceroute)" ] && header "install net-tools" && sudo ${pkgmgr} -y install net-tools
	[ ! -x "$(command -v tree)" ] && header "install tree" && sudo ${pkgmgr} -y install tree
	[ ! -x "$(command -v vim)" ] && header "install vim" && sudo ${pkgmgr} -y install vim
	[ ! -x "$(command -v wavemon)" ] && header "install wavemon" && sudo ${pkgmgr} -y install wavemon
	[ ! -x "$(command -v xdotool)" ] && header "install xdotool" && sudo ${pkgmgr} -y install xdotool
}
function nfs_mounts_points {
    MOUNT="/opt/diskstation"
    NAS="192.168.0.253:/volume1"
    [[ "$(read -e -p 'backup? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mkdir -p $MOUNT/backup && \
    sudo sh -c 'echo "$NAS/backup $MOUNT/backup nfs defaults 0 0" >> /etc/fstab'
    [[ "$(read -e -p 'common? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mkdir -p $MOUNT/common && \
    sudo sh -c 'echo "$NAS/common $MOUNT/common nfs defaults 0 0" >> /etc/fstab'
    [[ "$(read -e -p 'emiller? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mkdir -p $MOUNT/emiller && \
    sudo sh -c 'echo "$NAS/emiller $MOUNT/emiller nfs defaults 0 0" >> /etc/fstab'
    [[ "$(read -e -p 'jenn_folders? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mkdir -p $MOUNT/jenn_folders && \
    sudo sh -c 'echo "$NAS/jenn_folders $MOUNT/jenn_folders nfs defaults 0 0" >> /etc/fstab'
    [[ "$(read -e -p 'media? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mkdir -p $MOUNT/media && \
    sudo sh -c 'echo "$NAS/media $MOUNT/media nfs defaults 0 0" >> /etc/fstab'
    [[ "$(read -e -p 'music? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mkdir -p $MOUNT/music && \
    sudo sh -c 'echo "$NAS/music $MOUNT/music nfs defaults 0 0" >> /etc/fstab'
    [[ "$(read -e -p 'photos? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mkdir -p $MOUNT/photos && \
    sudo sh -c 'echo "$NAS/photos $MOUNT/photos nfs defaults 0 0" >> /etc/fstab'
    [[ "$(read -e -p 'tmp? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mkdir -p $MOUNT/tmp && \
    sudo sh -c 'echo "$NAS/tmp $MOUNT/tmp nfs defaults 0 0" >> /etc/fstab'
    [[ "$(read -e -p 'Review & Edit /etc/fstab? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo vi /etc/fstab
    echo "Running command: systemctl daemon-reload..."
    sudo systemctl daemon-reload
    [[ "$(read -e -p 'Run sudo mount -a? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo mount -a
    ls -l $MOUNT
}
function bashrc_update {
    printf '\n# Source all .bashrc_FILES\nfor f in ~/.bashrc_*; do source $f; done\n' >> ~/.bashrc
}
function ssh_config {
    [[ ! -f /etc/ssh/sshd_config_orig ]] && sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_orig && sudo chmod a-w /etc/ssh/sshd_config_orig
    sudo grep -q "^MaxStartups" /etc/ssh/sshd_config
    if [[ $? != 0 ]]; then
        sudo sh -c 'echo "MaxStartups 10:30:60" >> /etc/ssh/sshd_config'
    fi
    sudo grep -q "^Banner" /etc/ssh/sshd_config
    if [[ $? != 0 ]]; then
        sudo sh -c 'echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config'
    fi
        echo "
***************************************************************************
                            NOTICE TO USERS
***************************************************************************

This computer system is the private property of its owner, whether
individual, corporate or government.  It is for authorized use only.
Users (authorized or unauthorized) have no explicit or implicit
expectation of privacy.

Any or all uses of this system and all files on this system may be
intercepted, monitored, recorded, copied, audited, inspected, and
disclosed to your employer, to authorized site, government, and law
enforcement personnel, as well as authorized officials of government
agencies, both domestic and foreign.

By using this system, the user consents to such interception, monitoring,
recording, copying, auditing, inspection, and disclosure at the
discretion of such personnel or officials.  Unauthorized or improper use
of this system may result in civil and criminal penalties and
administrative or disciplinary action, as appropriate. By continuing to
use this system you indicate your awareness of and consent to these terms
and conditions of use. LOG OFF IMMEDIATELY if you do not agree to the
conditions stated in this warning.

****************************************************************************
" > /tmp/issue.net
	sudo cp -f /tmp/issue.net /etc/issue.net
	sudo systemctl restart sshd
	sudo systemctl enable sshd
	sudo systemctl status sshd
}
function ufw_enable {
    [[ -z $pkgmgr ]] && packagemgr
    [ ! -x "$(command -v ufw)" ] && header "install ufw" && sudo ${pkgmgr} -y install ufw
    if [ -f /usr/sbin/ufw ] ;then 
        header "configure ufw"
        systemd status ufw
        sudo ufw status
        #sudo ufw allow from 192.168.1.10 to any port 22 proto tcp
        sudo ufw limit 22/tcp
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw enable
        sudo ufw status verbose
        echo "Firewall ufw has been configured. Adding ufw to sudoers for health.sh script"
        [ ! -d /etc/sudoers.d ] && sudo mkdir /etc/sudoers.d
        printf "Cmnd_Alias    UFWSTATUS = /usr/sbin/ufw status\n%%ufwstatus    ALL=NOPASSWD: UFWSTATUS\n" > /tmp/ufwstatus
        sudo cp /tmp/ufwstatus /etc/sudoers.d
        sudo groupadd -r ufwstatus
        sudo gpasswd --add user ufwstatus
        echo "reboot is needed to apply the sudoers update"
    else
        echo "ufw was not installed"
    fi
}
function timezone_america_new_york {
  sudo sh -c 'echo \"America/New_York\" > /etc/timezone'
  cat /etc/timezone
}
function install_printer_driver {
    DRIVER=linux-brprinter-installer-2.2.3-1
    [ ! -f $DRIVER ] && echo "Error: $DRIVER not found in $PWD" && return
    [ ! -d /tmp/brother ] && mkdir /tmp/brother
    cp $DRIVER /tmp/brother
    cd /tmp/brother
    chmod 777 $DRIVER
    echo "==========> Brother hl-l6200dw"
    sudo ./$DRIVER
}
function kvm_restore {
    KVM_IMG=/opt/diskstation/backup/$HOSTNAME/kvm/images
    KVM_XML=/opt/diskstation/backup/$HOSTNAME/kvmxml
    [ ! -d $KVM_IMG ] && echo "KVM Images not found $KVM_IMG" && return 1
	ls $KVM_IMG
    sudo rsync --info=progress2 $KVM_IMG/* /var/lib/libvirt/images/ 
    [ ! -d $KVM_XML ] && echo "KVM XML not found $KVM_IMG" && return 1
    sudo rsync --info=progress2 $KVM_XML/* /etc/libvirt/qemu/
    sudo sudo virsh list
    for i in $KVM_XML/*.xml; do sudo virsh define --file $i; done && \
    sudo sudo virsh list
    #sudo setfacl -m u:qemu:rx /home/user
}
echo "builder_functions.sh file sourced..."
