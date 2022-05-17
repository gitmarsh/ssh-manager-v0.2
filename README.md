# ssh-manager-v0.2
Testing repository for SSH key management.
This is purely for learning purposes only to help better understand bash scripting and secruity practices.
Feedback is appreciated

The way this consists of 3 encrypted lists:

  - serverlist: Nicknames(Aliases) of the servers for easy identification
  
 -  identity.conf:  Matches the nicknames(aliases) to an ID # that points to the file with the ip and user name
	
 - ./server_list/:  Directory with the ip and username of each server each encrypted with a randomly numbered filename
  
