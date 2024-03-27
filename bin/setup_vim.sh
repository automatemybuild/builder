#!/usr/bin/bash
#
# setup_vim.sh - Setup VIM files
# 
# 06/29/2022 - Created to setup Vim directories and install packages

#Variables
date=$(date +%Y%m%dT%H%M)
YELLOW='\033[0;33m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

#Functions
function header () {
    line=$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' +)
    printf "\n${YELLOW}${line}${WHITE}${*}${YELLOW}\n${line}${NC}\n"
}

#Create directories
[ ! -d ~/.vim ] && mkdir ~/.vim && echo "Created ~/.vim"
[ ! -d ~/.vim/plugged ] && mkdir ~/.vim/plugged && echo "Created ~/.vim/plugged"
[ ! -d ~/.vim/bundle ] && mkdir ~/.vim/bundle && echo "Created ~/.vim/bundle"
[ ! -d ~/.vim/autoload ] && mkdir ~/.vim/autoload && echo "Created ~/.vim/autoload"
[ ! -d ~/.vim_undo ] && mkdir ~/.vim_undo && echo "Created ~/.vim_undo"

#Update vimrc
[ -f ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.$date
cp /opt/diskstation/common/user/dotfiles/.vimrc ~/.vimrc

#Packages
[[ "$(read -e -p 'Reinstall plugin manager and YCM dependancies? [Y/n] '; echo $REPLY)" == [Nn]* ]] && exit 0
header ">>> plugin package manager"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ls -l ~/.vim/autoload/
header ">>> bundle manager"
curl -fLo ~/.vim/bundle/Vundle.vim --create-dirs \
https://github.com/VundleVim/Vundle.vim
header ">>> YCM dependancies"
	[[ "$(read -e -p 'Install YouCompleteMe? [y/N] '; echo $REPLY)" == [Yy]* ]] && \
sudo dnf install cmake gcc-c++ make python3-devel npm && \
cd ~/.vim/plugged/YouCompleteMe && ./install.py --ts-completer
echo
echo "To complete plugin installations run the following"
echo "vim ~/.vimrc ;; Plugins :source % ;; :PlugInstall"
