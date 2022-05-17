#!/bin/bash


red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
purple="\e[35m"
cyan="\e[36m"
grey="\e[37m"
reset="\e[0m"

function newserver () {

read -p $'\e[35mEnter server ip\e[0m: ' serverip
read -p  $'\e[34mEnter username\e[0m: ' user
read -p $'\e[36mEnter an  alias\e[0m: ' nickname
sleep 1
newid="$($user@$serverip)"
fileid=$RANDOM

echo "$newid" > './server_list/"$fileid".conf' &&		## Generates a randomly named file with the servers IP and User
		gpg -c './server_list/"$fileid".conf' &&	## Encrypts the new file and deletes the regular file
	rm './server_list/"$fileid".conf' &&			
		gpg -d 'identity.conf.gpg' > 'identity.conf' && ## Decrypts the List that associates the server alias with correct credentials
		gpg -d 'serverlist.gpg' > 'serverlist' &&	## Decrypts the list contaings just the aliases
echo "$nickname" >> 'serverlist' &&				## Adds the new alias to the serverlist
		gpg -c 'serverlist' && rm 'serverlist' &&	## Re-Encrypts the Server Aliaes List and removes the original
echo "$nickname"= "$fileid" >> 'identity.conf' &&		## Adds the Alias and the Credentials File ID into the Identity List
	rm 'identity.conf.gpg' &&				## Removes the old Identity List
		gpg -c 'identity.conf' && 			## Encrypts the new list
	rm 'identity.conf'					## Removes the origanl List
echo -e "${green}Quick SSH Entry Added!${reset}"		### Everything new should be added and everything re-encrypted

exit

}

function connect () {

gpg -d serverlist.gpg > .srv.tmp && cat .srv.tmp -n			## Decrypts the Servlist into a hidden temporary file and cats out the contents

echo -e "\n${cyan}Enter server name you wish to connect to${reset}\n"
read -n 1 -s answer2

tempid="$(cat .srv.tmp | sed -n "$answer2"p | awk "{print $1}" )"			## Extracts the selected Alias into a variable
serverid="$(gpg -d identity.conf.gpg | grep -e "$tempid" | awk -F"=" '{print $2}')"	##  Decrypts the Identity list and matches the --
connectid="$(gpg -d ./server_list/$serverid.conf.gpg)"					## the variable to the correct credentials file	

sleep 1 
echo -e "${yellow}Connecting.....${reset} ${purple}$serverid${reset}\n"
sleep 1
rm .srv.tmp && ssh "$connectid"								## Deletes the Tempororary File and Attempts SSH Connection

}

function delete () {
ls -1 ~/.scripts/sshkeymanager/server_aliases/ | cat -n

echo -e "\n${cyan}Enter server name you wish to delete${reset}\n"
	read -n 1 -s answer2
	
serverid="$( ls -1 ~/.scripts/sshkeymanager/server_aliases/ | sed -n "$answer2"p | awk "{print $1}" )"
sleep 1
echo -e "${red}Are you sure you wish to delete this server from this list?${reset}: (y)Yes/(n)No"
read -n 1 -s confirm
if [ "$confirm" == "y" ]
then
rm ~/.scripts/sshkeymanager/server_aliases/"$serverid"
echo "Server has been deleted: return to beginning?: (y)Yes/(n)Exit"
read -n 1 -s response
	if [ "$response" == "y" ]
	then sh ~/.scripts/sshkeymanager/remote-aliases
	else
		exit
	fi
else
	exit
fi
}


function init () {
    
    function list () {
         ls -1 ~/.scripts/sshkeymanager/server_aliases/ | cat -n
        menu
    }

###  START TITLE
echo -e "${green}############################################################################################${reset}"
echo -e "${green}#########################${reset} ${red}SSH QUICK CONNECT / SERVER ALIASING${reset} ${green}##############################${reset}"

###  MENU

    function menu () { 
        echo -e "\n${cyan}Select an option${reset}:\n\n1.) ${green}Connect To Server${reset}  2.) ${purple}List Servers${reset}   3.) ${yellow}Add New Server${reset}   4.) ${red}Delete Server${reset}   5.) Exit\n"
        read -n 1 -s firstab
        sleep 1 
        case $firstab in
        "1")
        connect     ;;
        "2")
        list        ;;
        "3")
        newserver   ;;
        "4")
        delete      ;;
        "5")
        exit        ;;
        esac
    }
}

init
menu
