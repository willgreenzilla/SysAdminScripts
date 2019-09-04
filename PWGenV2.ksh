#!/bin/ksh

####################################################################################################
##### PWGenV2.ksh                                                                             ######
##### v1.0 - 08/28/2019                                                                       ######
##### will green                                                                              ######
####################################################################################################
##### Generates account passwords that meet the password requirements.                        ######
#####                                                                                         ######
##### Check if less than 8 identical characters are in old and new passwords.                 ######
#####                                                                                         ######
##### Checks for the following password criteria:                                             ######
#####                                                                                         ######
##### > exactly 15 characters in length                                                       ######
##### > at least 1 digit                                                                      ######
##### > at least 4 letters                                                                    ######
##### > at least 1 special characters                                                         ######
##### > at least not 8 characters used from the previous password                             ######
#####                                                                                         ######
##### NOTE: Only have 1 or 2 password files in the script directory, last years, and this     ######
#####       years and only for a single environment at a time. Such as 2019passwordlist-dev   ######
#####       & 2018passwordlist-dev file. The password file being created name is set with     ######
#####       the THEYEAR & WORKINGENV variables which combine into the file name and is        ######
#####       provided by the user when the script is ran. The password file is purged each     ######
#####       time the script is ran with the same parameters.                                  ######
#####                                                                                         ######
##### EXAMPLE: ./PWGenV2.ksh 2019accountlist 2019 dev                                         ######
#####               ^             ^           ^   ^                                           ######
#####             script       accountlist  year  environment                                 ######
#####                                                                                         ######
####################################################################################################

# Set variables and requirements including output file name
ACCOUNTS=$(cat $1)
THEYEAR="$2"passwordlist
WORKINGENV=$3
YEARFILE="$THEYEAR-$WORKINGENV"
SPECIALCHARS='!@#$%^&*'
TOTALLIMIT="15"
DIGITLIMIT="1"
ALPHALIMIT="4"
SPECIALLIMIT="1"
NOTMATCHLIMIT="8"

# Reset the new password file
rm $YEARFILE 2> /dev/null

# Begin the process
print "-----------------------------------------------------------------"
print "-----------------------------------------------------------------\n>>>>> $YEARFILE is being built...\n-----------------------------------------------------------------"
print "-----------------------------------------------------------------"

# Generate each account password and place into password file if requirements are met, if not met, keep generating until password is good
print "$ACCOUNTS" | while read accounts; do

    GOODBAD="0"

    until [ $GOODBAD -eq 1 ]; do

        # Password generation from /dev/urandom
        PWGEN=$(tr -cd "A-Za-z0-9$SPECIALCHARS" < /dev/urandom | fold -w15 | head -n1)

        #Account being worked on from the account list provided to script
        ACCOUNT=$accounts

        # Build details of the generated password to check against requirements detailed at top
        ALPHACOUNT=$(echo "$PWGEN" | grep -o "[[:alpha:]]" | wc -l)
        DIGITCOUNT=$(echo "$PWGEN" | grep -o "[[:digit:]]" | wc -l)
        TOTALCOUNT=$(echo "$PWGEN" | wc | awk '{print $3-$1}')
        SPECIALCOUNT=$(expr $TOTALCOUNT - $ALPHACOUNT - $DIGITCOUNT)

        # Find if there are special characters are the beginning or end of the password (which I guess breaks some stuff?)
        # Do this by counting characters between front/back/special chars and these same chars sort unique to make sure special
        # chars not a first or last character of the password
        FRONTBACKCHARS="${PWGEN:0:1}${PWGEN: -1}"
        FRONTBACKSPECIAL="$FRONTBACKCHARS$SPECIALCHARS"
        FRONTBACKSPECIALSORT=$(echo -n $FRONTBACKSPECIAL | grep -o . | sort -u | tr -d "\n")
        SPECIALCHARSCOUNT=$(echo -n $FRONTBACKSPECIALSORT | wc -c)
        FRONTBACKSPECIALCOUNT=$(echo -n $FRONTBACKSPECIAL | wc -c)

        # Set front/end special char yes/no flag to check against when generating the passwords
        FRONTBACKYESNO="NO"
        if [ $FRONTBACKSPECIALCOUNT -eq  $SPECIALCHARSCOUNT ]; then

            FRONTBACKYESNO="YES"
        else

            FRONTBACKYESNO="NO"
        fi

        # Cheap way to check if old password for account matches 8 or more characters with newly generated password, to work,
        # be sure only 2 password files are in the script dir and named passwordlist, such as 2019passwordlist-dev and 2018passwordlist-dev
        NUM1=$(grep "^$ACCOUNT:" *passwordlist* | awk -F: '{print $3}' | grep -o . | sort | tr -d "\n" | wc -m)
        NUM2=$(grep "^$ACCOUNT:" *passwordlist* | awk -F: '{print $3}' | grep -o . | sort -u | tr -d "\n" | wc -m)
        NUM3=$(expr $NUM1 - $NUM2)

        # Check password against all requirements, keep generating password for each account until every password for every account meets every requirement 
        if [ "$ALPHACOUNT" -ge "$ALPHALIMIT" ] && [ "$DIGITCOUNT" -ge "$DIGITLIMIT" ] && [ "$TOTALCOUNT" -eq "$TOTALLIMIT" ] && [ "$NUM3" -le "$NOTMATCHLIMIT" ] && [ "$SPECIALCOUNT" -ge "$SPECIALLIMIT" ] && [ "$FRONTBACKYESNO" == "YES" ]; then

            echo "$accounts is GOOD..."
            GOODBAD="1"

        else

            echo "$accounts is BAD... fixing..." 

        fi

    done
    
    print "-----------------------------------------------------------------"
    print "$accounts:$PWGEN" >> $YEARFILE 

done < $1

# Finish up and display file name and contents
print "-----------------------------------------------------------------\n>>>>> $YEARFILE is COMPLETE!\n-----------------------------------------------------------------"
print "-----------------------------------------------------------------\n$YEARFILE OUTPUT:\n"
cat $YEARFILE
print "-----------------------------------------------------------------"

exit
