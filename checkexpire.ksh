#!/bin/ksh

####################################################################################################
##### checkexpire.ksh                                                                         ######
##### v0.1 - 10/15/2014                                                                       ######
##### will green                                                                              ######
####################################################################################################
##### Simple script to check when various passwords will expire by feeding it a list of       ######
##### application/user accounts                                                               ######
#####                                                                                         ######
##### Use example: ./checkexpire.ksh devaccountlist                                           ######
####################################################################################################

ONEYEAR=31556926

while read line
do
	ACCOUNT=$line

	# Check last password change date for account
	CHANGEDATE=`sudo grep -p $ACCOUNT /etc/security/passwd | grep lastupdate | awk -F= '{print $2}' | sed -e 's/^[ \t]*//'`

	# Add a year to it (52 weeks)
	EXPIREDATE=$CHANGEDATE+$ONEYEAR

	# Determine expire date of account
	FUTUREDATE=`perl -e 'print scalar(localtime('$EXPIREDATE')), "\n"'`

	# Spit out the account and when it will expire
	print "Account: $ACCOUNT  Expires: $FUTUREDATE" | grep -v 700

done < $1
