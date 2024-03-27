#!/bin/bash
#
# backup.sh - Manual backup of all common and specific builds
#
# Updates:
# 03/26/2024 - git repo
#

### Variables
bkup=/opt/diskstation/backup/`hostname -s`
date=$(date +"%Y-%m-%dT%H:%M:%S")
line=$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =)
INFO="$date: INFO:"
WARN="$date: WARN:"

### Backup Array
declare -a arraydownloads=($HOME/Downloads/*)
declare -a arraygithub=($HOME/git/*)
declare -a arrayhome=($HOME/.bash* $HOME/.tmux.conf $HOME/.vim* $HOME/.ssh $HOME/.open*  $HOME/*.yml $HOME/.config)
declare -a arrayhomebin=($HOME/bin/*)
declare -a arraykvm=(/var/lib/libvirt/images /etc/sysconfig/network-scripts/*)
declare -a arraykvmxml=(/etc/libvirt/qemu/*)
declare -a arrayncmpcpp=($HOME/.ncmpcpp/config $HOME/.mpd/mpd.conf /home/user/.config/pulse/daemon.conf)
declare -a arraynetcam=(/home/netcam/bin/*)
declare -a arraynetcool=(/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86 /opt/IBM/tivoli/netcool/omnibus/etc/AGG_P.props /opt/IBM/tivoli/netcool/omnibus/etc/nco_pa.conf /opt/IBM/tivoli/netcool/etc/omni.dat)
declare -a arraynetmon=($HOME/netmon/*)
declare -a arraynetmon=($HOME/website/* $HOME/netmon/* /etc/hosts)
declare -a arrayopenvpn=("$HOME/.openvpn/.pass.txt" "$HOME/.openvpn/us2-aes-128-cbc-udp-dns.ovpn" )
declare -a arraypictures=($HOME/Pictures/*)
declare -a arraypytivo=(/etc/firewalld/services/plexmediaserver.xml $HOME/bin/* /usr/share/pyTivo/pyTivo.conf /etc/firewalld/services/pyTivo.xml /etc/init.d/pyTivo )
declare -a arrayrsabnzbdplus=($HOME/.sabnzbd/* $HOME/.sabnzbd/sabnzbd.ini)
declare -a arrayrsyslog=(/etc/rsyslog.conf)
declare -a arrayscripts=($HOME/scripts/*)
declare -a arraysmokeping=(/etc/smokeping/config /etc/httpd/conf.d/smokeping.conf /var/lib/smokeping/rrd)
declare -a arrayssh=($HOME/.ssh/*)
declare -a arraysystemfiles=("/etc/sudoers.d/*" "/etc/fstab" "/etc/hosts" "/etc/security/limits.conf" "/etc/sysconfig/iptables" "/etc/hosts.allow" "/etc/sysctl.conf" "/boot/grub2/grub.cfg" "/etc/default/grub" "/etc/ssh/sshd_config" /etc/aide.conf /etc/issue.net )
declare -a arraywebsite=($HOME/website/*)
declare -a arraywww=(/var/www/*)

function mount_check {
	mount=/opt/diskstation/backup
	testmount=$(nfsstat -m | grep -A 1 $mount)
	if [[ "$testmount" == "" ]]; then
		echo "$WARN $mount not mounted"
		if [ ! -d $mount ]; then
			echo "$WARN Mount $mount does not exist"
			echo "$INFO Creating $mount mount point"
			sudo mkdir -p /opt/diskstation/backup
		fi
		echo "$INFO Attempting to mount NAS to $mount mount point"
		sudo mount 192.168.0.253:/volume1/backup /opt/diskstation/backup
		testmount=$(nfsstat -m | grep -A 1 $mount)
		if [[ "$testmount" == "" ]]; then
			echo "$WARN Mount failed."
			read -p ">> Backup to $HOME/.backup_mirror local directory? [N] " -n 1 -r
			if [[ ! $REPLY =~ ^[Yy]$ ]]; then
				exit 1
			else
				sftpfile=$HOME/`hostname -s`-snapshot-`date +"%Y-%m-%d"`.tar.gz
				bkup=$HOME/.backup_mirror/`hostname -s`
			fi
		else
			echo "$INFO Successfully mounted $mount"
		fi
	else
		echo "$INFO $mount is mounted"
	fi
}

function error_check {
	[ ! -d $HOME/log ] && printf "$INFO Creating log directory\n\n" && mkdir -p $HOME/log
	[ ! -x "$(command -v rsync)" ] && echo "$WARN The rsync package not installed. Exiting." && exit 1
	[[ "$(read -e -p 'CMD: Remove existing backup directory? [y/N] '; echo $REPLY)" == [Yy]* ]] && sudo rm -rf $bkup
	[ ! -d $bkup ] && mkdir -p $bkup && echo "$INFO Creating $bkup"
	[ ! -d $bkup ] && echo "$WARN Unable to create $bkup. Exiting" && exit 1
	echo "$INFO Root permissions required for system files"
	touch $bkup/.test.nonroot
	sudo touch $bkup/.test.root
	[ ! -f $bkup/.test.nonroot ] && echo "$WARN non-root write test to $bkup failed. Exiting" && exit 1
	[ ! -f $bkup/.test.root ] && echo "$WARN root write test to $bkup failed. Exiting" && exit 1
	sudo rm $bkup/.test.*
}

run_bleachbit() {
	pkill -f firefox
	if hash bleachbit 2>/dev/null; then
		printf "\n\n$line BleachBit \n$line\n"
		/usr/bin/bleachbit -c --preset >> /dev/null 2>&1
	fi
}

function rootcopyfiles (){
	logfile=$HOME/log/rsync_$(date +%Y%m%dt%H%Ms%s).log
	target=$bkup/$1
	printf "\n$line Copy $1 files to $target\n$line"
	[ ! -d $target ] && mkdir $target && echo "$INFO $target directory created"
	eval sudo rsync -avzp --log-file $logfile --progress --no-owner --no-group \
		--recursive \"\${array${1}[${2:-@}]}\" $target
	ls -la $target | grep -v total
}

function movedownloads {
	target=/opt/diskstation/backup
	maxsize=500M
	printf "\n$line Move specific files & files larger than $maxsize to $target\n$line"
	find $HOME/Downloads -type f -size +$maxsize -exec ls -lh {} +
	find $HOME/Downloads -type f -size +$maxsize -exec sudo mv -ft /opt/diskstation/backup/ {} +
	find $HOME/Downloads -type f -iname 'config-pfsense.*.xml' -exec ls -l {} +
	find $HOME/Downloads -type f -iname 'config-pfsense.*.xml' -exec mv -t /opt/diskstation/common/backup/pfsense/ {} +
	mv -t /opt/diskstation/backup/*.iso /opt/diskstation/tmp/images/
}

function usercopyfiles (){
	logfile=$HOME/log/rsync_$(date +%Y%m%dt%H%Ms%s).log
	target=$bkup/$1
	printf "\n$line Copy $1 files to $target\n$line"
	[ ! -d $target ] && mkdir $target && echo "$INFO $target directory created"
	eval rsync -avz --log-file $logfile --progress --no-owner --no-group \
	       --recursive \"\${array${1}[${2:-@}]}\" $target
	ls -la $target | grep -v total
}

function kvm_stop_running {
	for i in `sudo virsh list | grep running | awk '{print $2}'`
	do
		sudo virsh shutdown $i
	done
}

function execute_commands {
	target=$bkup/cmdout
	printf "\n$line Running commands saving output to $target\n$line"
	[ ! -d $target ] && mkdir $target && echo "$INFO $target directory created"
	crontab -l > $target/crontab.out 2>&1
	ifconfig -a > $target/ifconfig.out 2>&1
	inxi -z -F > $target/system_info.out 2>&1
	iptables -nvL > $target/iptables.out 2>&1
	iwconfig > $target/iwconfig.out 2>&1
	lsusb > $target/lsusb.out 2>&1
	sudo netstat -tulpn > $target/netstat_tulpn.out 2>&1
	showmount -e 192.168.1.253 > $target/showmount.out 2>&1
	uname -a > $target/uname.out 2>&1
	ls -la $target | grep -v total
}

function sftp_local_backup {
	printf "\n$line Compress and SFTP local backup to NAS\n$line"
	read -p ">> Continue? [N] " -n 1 -r
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit 1
	else
		echo "$INFO Compressing local $backup to $sftpfile"
		tar -cvzf $sftpfile -C $HOME/.backup_mirror `hostname -s`
		ls -la $sftpfile
	fi
}

### Execute Functions
cd
mount_check
error_check
kvm_stop_running
execute_commands
rootcopyfiles systemfiles
[ ! -x "$(command -v bleachbit)" ] &&	run_bleachbit
[ -d /home/user ] &&			usercopyfiles home
[ -d $HOME/bin ] &&		usercopyfiles homebin
[ -d $HOME/github ] &&		usercopyfiles github
[ -d $HOME/.ssh ] &&		usercopyfiles ssh
[ -d $HOME/scripts ] &&		usercopyfiles scripts
[ -d $HOME/Downloads ] &&		movedownloads
[ -d $HOME/Downloads ] &&		usercopyfiles downloads
[ -d $HOME/Pictures ] &&		usercopyfiles pictures
[ -d $HOME/netmon ] &&		usercopyfiles netmon
[ -d $HOME/website ] &&		usercopyfiles website
[ -d $HOME/.ncmpcpp ] &&		usercopyfiles ncmpcpp
[ -d $HOME/.openvpn ] &&		rootcopyfiles openvpn
[ -d /home/netcam ] &&			rootcopyfiles netcam
[ -d $HOME/netmon ] &&			rootcopyfiles netmon
[ -d /etc/davical ] &&			rootcopyfiles davical
[ -d /etc/smokeping ] &&		rootcopyfiles smokeping
[ -d /opt/IBM/tivoli/netcool ] &&	rootcopyfiles netcool
[ -d /usr/share/pyTivo ] &&		rootcopyfiles pytivo
[ -d $HOME/.sabnzbd ] &&		usercopyfiles sabnzbdplus
[ -d /var/www ] &&			rootcopyfiles www
[ -f /etc/rsyslog.conf ] &&		rootcopyfiles rsyslog
[ -d /var/lib/libvirt/images ] &&	rootcopyfiles kvm
[ ! -z 'sudo ls /etc/libvirt/qemu/*' ] &&	rootcopyfiles kvmxml
last=$bkup/RSYNC_LAST_$(date +%Y%m%d)
[ -f $bkup/RSYNC_LAST* ] && rm -f $bkup/RSYNC_LAST*
touch $last
date > $HOME/.lastbackup
find $bkup -type d -empty -delete
sleep 2
printf "\n$line Backup Complete - Target: $bkup\n$line`ls -la $bkup/*`\n$line\n\n"
[ -n "$sftpfile" ] &&			sftp_local_backup

