#!/bin/ksh

####################################################################################################
##### keypush.ksh                                                                             ######
##### v0.1 - 10/15/2014                                                                       ######
##### will green                                                                              ######
####################################################################################################
##### Push public key to multiple servers in a list                                           ######
##### First keygen ssh keys then run this                                                     ######
#####                                                                                         ######
##### Use example: ./keypush.ksh ~/.ssh/id_dsa.pub ~/.ssh/id_dsa.pub hostlist                 ######
####################################################################################################

# Push public key to multiple servers in a list
# First keygen ssh keys then run this
# To run: ./keypush.ksh ~/.ssh/id_dsa.pub ~/.ssh/id_dsa.pub hostlist

SOURCE=$1
TARGET=$2
HOSTLIST=$3

if [ -f $SOURCE ]
then
	printf "Key on the way...\n"
	while read server
	do
		ssh -n $server "mkdir ~/.ssh"
		scp -r -p $SOURCE $server:$TARGET
		ssh -n $server "cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys2;chmod 640 ~/.ssh/authorized_keys2;rm -f ~.ssh/id_rsa.pub"
	done < $HOSTLIST
else
	printf "No file found!\n"
	exit 0
fi
exit 0
