#!/bin/ksh

####################################################################################################
##### checkexpire.ksh                                                                         ######
##### v1.0 - 10/15/2014                                                                       ######
##### will green                                                                              ######
####################################################################################################
##### Simple script to randomly generate passwords for x amount of accounts for 3             ######
##### environments (dev/test/prod)                                                            ######
#####                                                                                         ######
##### Use example: ./pwgen.ksh 35                                                             ######
####################################################################################################

y=1
x=$1

while [ $y -le $x ]
do

	PWGEN1=`tr -cd '[:alnum:]' < /dev/urandom | fold -w14 | head -n1`
	PWGEN2=`tr -cd '[:alnum:]' < /dev/urandom | fold -w14 | head -n1`
	PWGEN3=`tr -cd '[:alnum:]' < /dev/urandom | fold -w14 | head -n1`
	print ":$PWGEN1:$PWGEN2:$PWGEN3"
	y=$(( $y + 1 ))

done 
