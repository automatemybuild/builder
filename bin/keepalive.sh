#!/bin/bash
#
# Usage:
#
# Install ->		sudo dnf install evemu
# Find Device ->	sudo evemu-describe
#
# Updates:
# 02/18/2021 - player.sh branch for simple text output
# 03/26/2024 - git repo
#

[[ "$HOSTNAME" == "skull" ]] && device=/dev/input/event6 && echo $device
[[ "$HOSTNAME" == "xps9550" ]] && device=/dev/input/event4 && echo $device
inputfile=/home/user/data/player_cmds/keepalive.txt
ls -l $inputfile
start=$(date)

function press {
	[ "$SHIFT" == "" ] || evemu-event ${device} --type EV_KEY --code $SHIFT --value 1 --sync
	evemu-event ${device} --type EV_KEY --code $1 --value 1 --sync
	evemu-event ${device} --type EV_KEY --code $1 --value 0 --sync
	[ "$SHIFT" == "" ] || evemu-event ${device} --type EV_KEY --code $SHIFT --value 0 --sync
	SHIFT=
	SEC=$(( (RANDOM % 10 ) + 1 )) && sleep 0.1$SEC
}

function keymap {
	case $char in
		[0-9])
		;;
		[A-Z])
		if [[ $char = [QWERTASDFGZXCVB] ]]; then 
			SHIFT=KEY_LEFTSHIFT
		else
			SHIFT=KEY_RIGHTSHIFT
		fi
		;;
		[a-z])
			char=${char^^}
		;;
		' ')
			char=SPACE
			sleep 0.4
		;;
		'-')
			char=MINUS
		;;
		'=')
			char=EQUAL
		;;
		',')
			char=COMMA
		;;
		':')
			SHIFT=KEY_LEFTSHIFT
			char=SEMICOLON
		;;
		';')
			char=SEMICOLON
		;;
		'.')
			char=DOT
		;;
		'/')
			char=SLASH
		;;
		'\')
			char=BACKSLASH
		;;
		'[')
			char=LEFTBRACE
		;;
		']')
			char=RIGHTBRACE
		;;
		'{')
			SHIFT=KEY_LEFTSHIFT
			char=LEFTBRACE
		;;
		'}')
			SHIFT=KEY_LEFTSHIFT
			char=RIGHTBRACE
		;;
		'!')
			SHIFT=KEY_RIGHTSHIFT
			char=1
		;;
		'@')
			SHIFT=KEY_RIGHTSHIFT
			char=2
		;;
		'#')
			### Custom ESC key map
			char=ESC
		;;
		'$')
			SHIFT=KEY_RIGHTSHIFT
			char=4
		;;
		'%')
			SHIFT=KEY_RIGHTSHIFT
			char=5
		;;
		'^')
			SHIFT=KEY_RIGHTSHIFT
			char=6
		;;
		'&')
			SHIFT=KEY_LEFTSHIFT
			char=7
		;;
		'*')
			SHIFT=KEY_LEFTSHIFT
			char=8
		;;
		'(')
			SHIFT=KEY_LEFTSHIFT
			char=9
		;;
		')')
			SHIFT=KEY_LEFTSHIFT
			char=0
		;;
		'_')
			SHIFT=KEY_LEFTSHIFT
			char=MINUS
		;;
		'+')
			SHIFT=KEY_LEFTSHIFT
			char=EQUAL
		;;
		'|')
			SHIFT=KEY_LEFTSHIFT
			char=BACKSLASH
		;;
		*)
			char=ENTER
		;;
	esac
}

function progress_bar () {
	# $1 = sleep
	for ((k = 0; k <= 10 ; k++))
	do
		echo -n "[ "
		for ((i = 0 ; i <= k; i++)); do echo -n "######"; done
		for ((j = i ; j <= 10 ; j++)); do echo -n "      "; done
		v=$((k * 10))
		echo -n " ] "
		echo -n "$v %" $'\r'
		sleep $1
	done
	echo
}

### Error Check
[ "$1" != "" ] && echo "Device: $device" && $device = $1
#[ ! -f $inputfile ] && echo "Error: Input file not found" && exit 1
[ $EUID -ne 0 ] && echo "Error: This script must be run as root" && exit 1
[ ! -x "$(command -v evemu-event)" ] && echo "Error: evemu-event not installed. Exiting." && exit 1

### Select Screen Message
clear
figlet KEEPALIVE...
figlet STARTING!
printf " Find Device ->	sudo evemu-describe\n"
printf "\n\n>>>  EVEMU Keyboard player starting. Select window... "
printf "5" && sleep 1
printf "\b4" && sleep 1
printf "\b3" && sleep 1
printf "\b2" && sleep 1
printf "\b1" && sleep 1
printf "\bSTARTING\n" && sleep 1

### Continuous Play 
while :
do
	[ $(date +'%H') = 17 ] && printf "Exit: 5PM EOD\n`date`\n\n" && exit 0
	while IFS= read -r -n1 char
	do
		printf "$char"
		keymap $char
		press  KEY_$char
		SEC=$(( (RANDOM % 10 ) + 1 )) && sleep 0.0$SEC
		[ "$char" == "ENTER" ] && SEC=$(( (RANDOM % 10 ) + 1 )) && printf "\n[$SEC sec] " && sleep $SEC
	done < "$inputfile"
	clear
	figlet KEEPALIVE...
	figlet ACTIVE!
	progress_bar 10
done

