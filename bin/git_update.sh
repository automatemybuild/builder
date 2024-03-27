#!/bin/bash
#
# git_update.sh - update local files from git pull
#
# 03/26/2024 - git repo

function error_check {
	[ ! -d $source_dir ] && printf "ERROR: $source_dir does not exist or not mounted.\n\n"
}

function update_local {
	[ ! -d $local_dir ] && printf "Creating $local_dir\n\n" && mkdir -p $local_dir
	if [ -z "$(find $source_dir -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
		printf "INFO: rsync $source_dir to $local_dir...\n\n"
		rsync -avhRm $1 --include='.*' $source_dir $local_dir
	else
		printf "WARNING: $source_dir is empty maybe not mounted. Skipping...\n\n"
	fi
}

cd ~/git/builder; git pull https://github.com/automatemybuild/builder

local_dir=~/bin
source_dir=~/git/builder/bin/./
[ -d $source_dir ] && error_check
[ -d $source_dir ] && update_local

local_dir=~/nastools
source_dir=~/git/builder/nastools/./
[ -d $source_dir ] && error_check
[ -d $source_dir ] && update_local

local_dir=~
source_dir=~/git/builder/dotfiles/./
[ -d $source_dir ] && error_check
[ -d $source_dir ] && update_local

