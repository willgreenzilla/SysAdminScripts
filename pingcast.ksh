#!/bin/ksh

# Send out a ping to every box and respond back w/UP or DOWN status
cat pinghosts | while read ip; do
    if ping -c1 -t2 $ip >/dev/null 2>&1; then
        echo $ip IS UP
    else
        echo $ip IS DOWN
    fi
done
