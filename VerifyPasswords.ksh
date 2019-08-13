#!/bin/ksh

# Check if less than 8 characters are in old and new passwords.
#
# Checks for the following password criteria:
#
# > at least 1 digit
# > at least 4 letters
# > at least 1 special characters
# > at least not 8 characters used from the previous password
#
# Use the following to show just passwords that FAIL the check:
#
# ./VerifyPasswords.ksh 2019accountlist | grep -B 6 BAD
#
# Will Green 
# 08/12/2019

YEARFILE=2019passwordlist

while read line
do
    ACCOUNT=$line
    ALPHACOUNT=`grep "^$ACCOUNT:" $YEARFILE | awk -F: '{print $2}' | grep -o "[[:alpha:]]" | wc -l`
    DIGITCOUNT=`grep "^$ACCOUNT:" $YEARFILE | awk -F: '{print $2}' | grep -o "[[:digit:]]" | wc -l`
    TOTALCOUNT=`grep "^$ACCOUNT:" $YEARFILE | awk -F: '{print $2}' | wc | awk '{print $3-$1}'`
    SPECIALCOUNT=`expr $TOTALCOUNT - $ALPHACOUNT - $DIGITCOUNT`
    NUM1=`grep "^$ACCOUNT:" *passwordlist* | awk -F: '{print $3}' | grep -o . | sort | tr -d "\n" | wc -m`
    NUM2=`grep "^$ACCOUNT:" *passwordlist* | awk -F: '{print $3}' | grep -o . | sort -u | tr -d "\n" | wc -m`
    NUM3=`expr $NUM1 - $NUM2`

    echo "> $ACCOUNT"

    echo "Total characters: $TOTALCOUNT"
    echo "Alpha characters: $ALPHACOUNT"
    echo "Digit characters: $DIGITCOUNT"
    echo "Special characters: $SPECIALCOUNT"

    #grep "^$ACCOUNT:" *pw* | awk -F: '{print $3}' | grep -o . | sort | tr -d "\n" | wc -m
    #grep "^$ACCOUNT:" *pw* | awk -F: '{print $3}' | grep -o . | sort -u | tr -d "\n" | wc -m

    echo "Character match: $NUM3"

    if
    [ "$ALPHACOUNT" -gt "3" ] && [ "$DIGITCOUNT" -gt "0" ] && [ "$TOTALCOUNT" -eq "15" ] && [ "$NUM3" -lt "9" ] && [ "$SPECIALCOUNT" -gt "0" ]
    
    then
        echo "GOOD PASSWORD"
    else
        echo "***** BAD PASSWORD *****"
    fi

    echo "-----------------------------------"

done < $1
