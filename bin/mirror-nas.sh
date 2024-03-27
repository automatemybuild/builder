#!/bin/bash
#
# mirror.sh - update local files from remote NAS
#
# 03/28/2020 - Added logic for updating if NAS mount is present
# 02/10/2021 - Updated to remove local documents from files mirrored

function error_check {
	[ ! -x "$(command -v rsync)" ] && echo "ERROR: rsync command on installed\n\n" && sudo yum -y install rsync
	[ ! -d $remote_dir ] && printf "ERROR: $remote_dir does not exist or not mounted.\n\n"
	[ ! -d $HOME/log ] && printf "INFO: Creating log directory\n\n" && mkdir -p $HOME/log
}

function update_local {
	[ ! -d $local_dir ] && printf "Error: $local_dir does not exist. Creating $local_dir\n\n" && mkdir -p $local_dir
	logfile=$HOME/log/rsync_$(date +%Y%m%dt%H:%M:%s).log
	if [ -z "$(find $remote_dir -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
		printf "INFO: rsync $remote_dir to $local_dir...\n\n"
		rsync -avhRm --log-file $logfile --chmod=750 --chown=user:user \
			--exclude="*22" --exclude="@eaDir" \
			$1 --delete \
			$remote_dir $local_dir
	else
		printf "WARNING: $remote_dir is empty maybe not mounted. Skipping...\n\n"
	fi
	chmod 700 $local_dir
	last=$local_dir/RSYNC_LAST_$(date +%Y%m%d)
	[ -f $local_dir/RSYNC_LAST* ] && rm $local_dir/RSYNC_LAST*
	touch $last
}

local_dir=$HOME/bin
remote_dir=/opt/diskstation/common/bin/./
[ -d $remote_dir ] && error_check
[ -d $remote_dir ] && update_local

local_dir=$HOME/nastools
remote_dir=/opt/diskstation/common/nastools/./
[ -d $remote_dir ] && error_check
[ -d $remote_dir ] && update_local

local_dir=$HOME/Documents/notes
remote_dir=/opt/diskstation/emiller/notes/./
[ -d $remote_dir ] && error_check
[ -d $remote_dir ] && update_local

local_dir=$HOME/data
remote_dir=/opt/diskstation/common/data/./
[ -d $remote_dir ] && error_check
[ -d $remote_dir ] && update_local

local_dir=$HOME/dotfiles
remote_dir=/opt/diskstation/common/dotfiles/./
[ -d $remote_dir ] && error_check
[ -d $remote_dir ] && update_local

remote_dir=/opt/diskstation/emiller/.keepass/./
[ ! -d $HOME/.keepass ] && printf "Info: Creating .keepass directory\n\n" && mkdir -p $HOME/.keepass 
[ -d $remote_dir ] && \
	rsync -avzuh --chmod=500 --chown=user:user /opt/diskstation/emiller/keepass/master_database.kdbx $HOME/.keepass/

local_dir=$HOME/Documents/documents
[ -d $local_dir ] && chmod 700 -R $local_dir && rm -rf $local_dir && echo "$local_dir REMOVED" 

date > $HOME/.lastmirror
