#!/bin/ksh

####################################################################################################
##### pwgen.keh                                                                               ######
##### v0.4 - 08/12/2019                                                                       ######
##### will green                                                                              ######
####################################################################################################
##### Generates the account passwords for dev/test/prod in a 3 column list.                   ######
#####                                                                                         ######
##### Use example: ./pwgen.ksh accountlist                                                    ######
####################################################################################################

ACCOUNTS=`cat $1`

print "$ACCOUNTS" | while read accounts; do

#	PWGEN1=`tr -cd '[:alnum:]' < /dev/urandom | fold -w15 | head -n1`
#	PWGEN2=`tr -cd '[:alnum:]' < /dev/urandom | fold -w14 | head -n1`
#	PWGEN3=`tr -cd '[:alnum:]' < /dev/urandom | fold -w14 | head -n1`

        PWGEN1=`tr -cd 'A-Za-z0-9!@#$%^&*' < /dev/urandom | fold -w15 | head -n1`
	PWGEN2=`tr -cd 'A-Za-z0-9!@#$%^&*' < /dev/urandom | fold -w15 | head -n1`
	PWGEN3=`tr -cd 'A-Za-z0-9!@#$%^&*' < /dev/urandom | fold -w15 | head -n1`
#	print "$accounts:$PWGEN1:$PWGEN2:$PWGEN3"
	print "$accounts:$PWGEN1"

done 
