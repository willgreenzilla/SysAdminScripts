#!/bin/ksh

####################################################################################################
##### gogo                                                                                    ######
##### v1.3 - 7/18/2014                                                                        ######
##### will green                                                                              ######
####################################################################################################
##### Simple dsh enabled script to execute commands to a multitude of servers                 ######
##### at the same time in parallel                                                            ######
#####                                                                                         ######
##### Use example: gogo all uptime                                                            ######
####################################################################################################

# Take user input
WHAT=$1
INPUT=$2
FILEFROM=$3
FILETO=$4

# Variables
FAN=50
HOSTLISTDIR=""
DEFAULTPASS='CHANGEME'

# Configure DSH variables
export DSH_NODE_RSH=/usr/bin/ssh
export DSH_NODE_OPTS="-q -o BatchMode=yes"
export DCP_NODE_RCP=/usr/bin/scp
export DSH_FANOUT=$FAN

# Check input
if [ "$#" -lt 1 -gt 2 ]
then
	print '\nScript format should be: gogo SERVERGROUP COMMAND\n\nExamples:\tgogo all uptime\n\t\tgogo all "/usr/sbin/ifconfig -a | grep en0"\n\nNote: Type gogo help for help\n'
	exit 1
else
	case "$WHAT" in
	
		[aA][lL][lL])	export DSH_NODE_LIST="$HOSTLISTDIR/allhosts"
				HOSTLIST="$HOSTLISTDIR/allhosts"
				COMMALIST=`tr '\n' ',' < $HOSTLIST | sed 's/.$//'`
				SERVERSELECT="$HOSTLISTDIR/allhosts"

		;;

		[pP]rod|PROD)	export DSH_NODE_LIST="$HOSTLISTDIR/prodhosts"
				HOSTLIST="$HOSTLISTDIR/prodhosts"
				COMMALIST=`tr '\n' ',' < $HOSTLIST | sed 's/.$//'`
				SERVERSELECT="$HOSTLISTDIR/allhosts"

		;;

		[dD][eE][vV])	export DSH_NODE_LIST="$HOSTLISTDIR/devhosts"
				HOSTLIST="$HOSTLISTDIR/devhosts"
				COMMALIST=`tr '\n' ',' < $HOSTLIST | sed 's/.$//'`
				SERVERSELECT="$HOSTLISTDIR/allhosts"

		;;

		[tT]est|TEST)	export DSH_NODE_LIST="$HOSTLISTDIR/testhosts"
				HOSTLIST="$HOSTLISTDIR/testhosts"
				COMMALIST=`tr '\n' ',' < $HOSTLIST | sed 's/.$//'`
				SERVERSELECT="$HOSTLISTDIR/allhosts"

		;;

		[tT]iv|TIV)	export DSH_NODE_LIST="$HOSTLISTDIR/tivhosts"
				HOSTLIST="$HOSTLISTDIR/tivhosts"
				COMMALIST=`tr '\n' ',' < $HOSTLIST | sed 's/.$//'`
				SERVERSELECT="$HOSTLISTDIR/allhosts"

		;;

		[sS]et|SET)	printf "\nProvide list of servers to be targeted (hostname only and space separated)...\n\nServer Input: "
				read -r LISTHOSTS
				cat $LISTHOSTS | tr ' ' '\n' > $HOSTLISTDIR/listhosts	

				exit 0

		;;

		[lL]ist|LIST)	export DSH_NODE_LIST="$HOSTLISTDIR/listhosts"
				HOSTLIST="$HOSTLISTDIR/listhosts"
				COMMALIST=`tr '\n' ',' < $HOSTLIST | sed 's/.$//'`
				SERVERSELECT="$HOSTLISTDIR/allhosts"

		;;

		[hH]elp|HELP)	print "\n#######################\ngogo v1.2 - will green\n#######################\n\nHELP:\nScript format should be: gogo SERVERGROUP COMMAND\n\nSERVERGROUP OPTIONS:\nall\nprod\ntest\ndev\ntiv\nlist\n\nCOMMAND OPTIONS:\nhosts - Shows a list of all servers in the selected serverlist\nfs - Shows all server file-systems >= 90% full\npass - Reset a user password to the default [ $DEFAULTPASS ]\nsetpass - Set a user provided password on a user/account\nlock - Lock a user account\nunlock - Unlock a user account\npeek - Check to see if a user is on any of the serverlist servers\nput - Send file(s) from the server out to all designated servernode servers\nmakeuser (or mu) - Create a new user on all designated servernode servers\ndeluser (or du) - Delete a user from all designated servernode servers (can specify delete of home dir or not)\n* - Any other command will be interpreted as input\n\nEXAMPLES:\ngogo help - This display\ngogo all uptime - Displays server uptime on every server in the all serverlist node\ngogo all \"/usr/sbin/ifconfig -a | grep en0\" - Displays server nic card infomation for en0 on every server in the all serverlist node\ngogo all fs - Displays file-systems with greater (or equal to)  90% capacity of every server in the all serverlist node\ngogo prod put test /tmp/test - Send file test to all all servers in the prod servernode to /tmp/test\n"

				exit 0

		;;

		*)		export DSH_NODE_LIST=""

				print "\nERROR: Invalid server group selection\n"

				exit 1

		;;

	esac
	
	case "$INPUT" in

		[hH]osts|HOSTS)		print "\nServers in the [$WHAT] node: $COMMALIST\n"

					;;

		[cC]heck|CHECK)		print "\nChecking status of [$WHAT] servers...\n"

					dsh "date" 2>/dev/null

					print ""

					;;

		[fF][sS])		print "\nFile Systems >=90%:\n"

					dsh "df | egrep -v lbos | grep -E '9[5-9]%|100%'" 2>/dev/null | dshbak			

					;;

		[pP]ass|PASS)		print "\nPassword reset...\n\nNote: if you do not know the username use the gogo peek command\n"

					printf "Username to reset? "
					read -r USERNAME
					print ""

					dsh "echo '$USERNAME:$DEFAULTPASS'|sudo chpasswd" 2>/dev/null | dshbak

					print "\nPassword has been reset to the default password of $DEFAULTPASS\n"

					;;

		[sS]etpass|SETPASS)	print "\nSet user/account password...\n\nNote: if you do not know the username use the gogo peek command\n"

					printf "Username/account to reset? "
					read -r USERNAME
					print "\nSet password to? "
					read -r ACCTPASS
					printf ""

					dsh "echo '$USERNAME:$ACCTPASS'|sudo chpasswd" 2>/dev/null | dshbak

					print "\nPassword of $USERNAME has been set to $ACCTPASS\n"

					;;

		[lL]ock|LOCK)		print "\nLock user account...\n\nNote: if you do not know the username use the gogo peek command\n"

					printf "Username to lock? "
					read -r USERNAME
					print ""

					dsh "sudo chuser account_locked=true $USERNAME" 2>/dev/null | dshbak

					print "\n$USERNAME has been LOCKED\n"

					;;

		[uU]nlock|UNLOCK)	print "\nUnlock user account...\n\nNote: if you do not know the username use the gogo peek command\n"

					printf "Username to unlock? "
					read -r USERNAME
					print ""

					dsh "sudo chuser account_locked=false $USERNAME" 2>/dev/null | dshbak
					dsh "sudo chsec -f /etc/security/lastlog -a 'unsuccessful_login_count=0' -s $USERNAME" 2>/dev/null | dshbak

					print "\n$USERNAME has been UNLOCKED\n"

					;;

		[mM]akeuser|MAKEUSER|mu|MU)	print "\nMake new user account\n"

					printf "Username to make? "
					read -r USERNAME
					printf "First & last name of new user (gecos)? "
					read -r FULLNAME
					printf "Primary group to place new user into? "
					read -r PRIGRP
					printf "Other groups to place new user into (comma separated) "
					read -r OTHERGRPS
					print ""

					dsh "sudo /usr/bin/mkuser pgrp='$PRIGRP' groups='$OTHERGRPS' gecos='$FULLNAME' home='/home/$USERNAME' shell='/bin/ksh' $USERNAME" 2>/dev/null | dshbak
					dsh "echo '$USERNAME:$DEFAULTPASS'|sudo chpasswd" 2>/dev/null | dshbak

					print "\nUser $USERNAME has been CREATED and password set to Password12345!\n\nNote: Run peek command to verify\n"

					;;

		[dD]eluser|DELUSER|du)	print "\nDELETE a user account\n\nNote: Typically you will want to LOCK a user account and NOT delete it\n"

					printf "Username to delete (be sure this is 100% correct via peek command)? "
					read -r USERNAME
					printf "Remove user home dir (y|Y|n|N)? "
					read -r HOMEDIRYESNO
					print ""

					dsh "sudo /usr/sbin/rmuser -p $USERNAME" 2>/dev/null | dshbak

					print "\nUser $USERNAME has been DELETED\n\nNote: Run peek command to verify\n"

					if [ "$HOMEDIRYESNO" == y ] || [ "$HOMEDIRYESNO" == Y ]
                                        then

						dsh "sudo rm -rf /home/$USERNAME" 2>/dev/null | dshbak
                                                printf "\n$USERNAME home dir has been removed\n"

                                                exit 0

                                        elif [ "$HOMEDIRYESNO" == n ] || [ "$HOMEDIRYESNO" == N ]
					then
						
						printf "\n$USERNAME home dir was NOT removed\n"

                                                exit 1

					else
						printf "\nERROR: Incorrect input received. No action taken on $USERNAME home dir\n"
						
						exit 2					

                                        fi

					;;

		[pP]ut|PUT)		print "\nSend file(s)...\n"

					if [[ -z "$FILEFROM" ]]
					then

						printf "\nERROR: Missing file to be copied out. Format is \"gogo all put /tmp/testfrom /tmp/testto\"\n"
						exit 1

					else
				
						if [[ -z "$FILETO" ]]
						then

							printf "\nERROR: Missing location for file to be copied to. Format is \"gogo all put /tmp/testfrom /tmp/testto\"\n"
							exit 1
						fi
					fi

					printf "FILE: $FILEFROM\nDESTINATION: $FILETO\nSERVERS: $COMMALIST\n"

					dcp $FILEFROM $FILETO 2>/dev/null

					printf "\nDone.\n\n"

					;;

		[pP]eek|PEEK)		print "\nLocate user account...\n"

					printf "Last name of user? "
					read -r LASTNAME
					print ""

					YESUSER=`dsh "sudo egrep -i $LASTNAME /etc/passwd" 2>/dev/null | tail -n1 | wc | awk -F"      " '{print $2}' | tr -d ' '`

					if [ "$YESUSER" -eq 1 ]
					then

						USERONHOSTS=`dsh "sudo egrep -i $LASTNAME /etc/passwd" 2>/dev/null | awk -F: '{print $1}' | awk -F. '{print $1}' | tr '\n' ',' | sed 's/.$//'`
						ACCOUNTNAME=`dsh "sudo egrep -i $LASTNAME /etc/passwd" 2>/dev/null | tail -n1 | awk -F" " '{print $2}' | awk -F: '{print $1}'`
						PASSWDSTRING=`dsh "sudo egrep -i $LASTNAME /etc/passwd" 2>/dev/null | tail -n1 | awk -F: '{print $2":"$3":"$4":"$5":"$6":"$7":"$8}'`

						print "\nUser account name: $ACCOUNTNAME\nUser passwd entry:$PASSWDSTRING\nUser is on these servers (of the [$WHAT] node): $USERONHOSTS\n"
						
						exit 0

					else
						print "\nERROR: User $LASTNAME is NOT found on ANY of the [$WHAT] node servers!\n"

						exit 1

					fi

					;;

		*)			print "\nExecuting command...\n"

					dsh "$INPUT" 2>/dev/null

					;;

	esac
fi
exit 0
