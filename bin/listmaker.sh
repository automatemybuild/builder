#!/bin/bash
#
# listmaker.sh - description
#
# Updates:
# 06/23/2020 - Created list
# 03/26/2024 - git repo
# 
store=${1:-"grocery"}
line="===============================       "
store_isles=/opt/diskstation/common/etc/shopping_lists/"${store}".*
shopping_list=/tmp/shopping.list.txt
[[ -f $shopping_list ]] && rm $shopping_list
printf "\n${0} [STORE default=grocery]\nUsing: ${store_isles}\nShopping list contains `cat $store_isles | wc -l` items.\n\n"
[[ "$(read -e -p 'Should the list have headers for each store isle? [Y/n] '; echo $REPLY)" == [Nn]* ]] && headers=off 
clear
for file in $store_isles
do
  [[ "$headers" != "off" ]] && printf "$line\n`basename $file`\n$line\n" >> $shopping_list
  clear
  echo -en "\033[2J`basename $file`\n$line\033[s\n"
  cat $file
  printf "\n >> Enter quantity [1-9], any key to skip, [Esc] key to break from isle list, [q] to quit, [v] edit list"
  echo -en "\033[u"
  IFS=$'\n' read -d '' -r -a lines < $file
  for item in "${lines[@]}"
  do
    printf "\n%-24s%3s" "> ${item^}" ""
    read -sn 1 key
    case $key in
      1) printf "($key)"&& printf "[ ] ${item^}\n" >> $shopping_list ;;
      [2-9]) printf "($key)"&& printf "[ ] ${item^} (${key})\n" >> $shopping_list ;;
      q) clear && exit 1 ;;
      v) vi $file ;;
      $'\e') break ;;
      *) printf "none" ;;
    esac
  done
done
clear
pr -3 $shopping_list | grep -v ^$
[[ "$(read -e -p 'Edit Shopping List? [y/N] '; echo $REPLY)" == [Yy]* ]] && vi $shopping_list 
[[ "$(read -e -p 'Print Shopping List? [y/N] '; echo $REPLY)" == [Yy]* ]] && pr -3 $shopping_list | lp
printf "Shopping list single column text file: ${shopping_list}\n\n"

