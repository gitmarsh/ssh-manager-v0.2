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

newid="$user""@""$serverip"
fileid=$RANDOM

gpg -d ./serverlist.gpg > ./.list.tmp			# The list of server aliases is decrypted into a hidden temporary file
gpg -d ./identity.conf.gpg > ./.id.conf.tmp;		# The list of file and alias pairs is decrypted into a hidden temporary file

echo "$nickname" >> ./.list.tmp 			# The new server alias is add into the hidden temporary serverlist file
echo "$nickname"="$fileid" >> ./.id.conf.tmp;		# The alias and the filename for its credentials is add to the hidden temporary identity.conf file
echo "$newid" > ./server_list/"$fileid".conf		# A file is generated with the new server credentials with a random number for a file name

mv ./.list.tmp ./serverlist				# After all the new data is add the hidden temporary files are converted back to standard files
mv ./.id.conf.tmp ./identity.conf

gpg -c ./serverlist					
gpg -c ./identity.conf
gpg -c ./server_list/"$fileid".conf			
							# All files are Re-Encrypted & the exposed original files are deleted			
rm ./identity.conf
rm ./serverlist
rm ./server_list/"$fileid".conf

echo -e "${green}Quick SSH Entry Added!${reset}"
exit

}

function ssh_connect  () {

gpg -d ./serverlist.gpg > ./.list.tmp 
    cat ./.list.tmp -n

echo -e "\n${cyan}Enter server name you wish to connect to${reset}\n"
    read -r -n 1 -s answer

tempid="$( cat ./.list.tmp | sed -n "$answer"p | awk '{print $1}' )"
serverid="$( gpg -d identity.conf.gpg | grep -e "$tempid" | awk -F"=" '{print $2}' )"
matchid="$( gpg -d ./server_list/"$serverid".conf.gpg )"

 echo -e "${yellow}Connecting.....${reset} ${purple}$serverid${reset}\n"

mv ./.list.tmp ./serverlist
gpg -c ./serverlist
rm ./serverlist

ssh "$matchid"

}
function delete () {

gpg -d ./serverlist.gpg > ./.list.tmp
gpg -d identity.conf.gpg > ./.id.tmp
cat ./.list.tmp -n


echo -e "\n${cyan}Enter server name you wish to delete${reset}\n"
	read -n 1 -s answer2



tempid="$( cat ./.list.tmp | sed -n "$answer2"p | awk '{print $1}' )"
serverid="$( gpg -d identity.conf.gpg | grep -e "$tempid" | awk -F"=" '{print $2}' )"
serverln=$( gpg -d identity.conf.gpg | grep -en "$tempid" | awk -F"=" '{print $1}' )

echo -e "${red}Are you sure you wish to delete this server from this list?${reset}: (y)Yes/(n)No"
read -n 1 -s confirm
if [ "$confirm" == "y" ]
then

rm ./server_list/"$serverid".conf.gpg 
sed -i "$answer2"d ./.list.tmp
sed -i "$serverln"d ./.id.conf.tmp
mv ./.list.tmp serverlist
mv ./.id.conf.tmp identity.conf
gpg -c identity.conf
gpg -c serverlist
rm identity.conf
rm serverlist

echo "Server has been deleted: return to beginning?: (y)Yes/(n)Exit"
read -n 1 -s response
	if [ "$response" == "y" ]
	then
         sh ./ssh-manager.sh
	else
		exit
	fi
else
	exit
fi

}




function init () {
    
    function list () {
         gpg -d ./serverlist.gpg
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
        ssh_connect "$@"    ;;
        "2")
        list        ;;
        "3")
        newserver   ;;
        "4")
        delete "$@"      ;;
        "5")
        exit        ;;
        esac
    }
}

init
menu
