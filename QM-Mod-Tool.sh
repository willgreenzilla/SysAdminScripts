#!/bin/bash

# Script to update fields on an export of the MQ export file before importing it back in.
# Allows changing of all queues (not system) at once much quicker than within MQ Explorer.

IFS=$'\n'
inputfile=$1
newcustom="   CUSTOM('CAPEXPRY(864000)') +"
newmax="   MAXMSGL(10485760) +"

queuelist=$(grep "DEFINE QLOCAL" $inputfile | grep -v SYSTEM | awk -F" " '{print $1,$2}')

for queuename in $queuelist; do

        customvalue=$(grep -A 30 "$queuename" $1 | grep CUSTOM)
        customline=$(grep -A 30 -n "$queuename" $1 | grep CUSTOM | awk -F"-" '{print $1}')

        maxvalue=$(grep -A 30 "$queuename" $1 | grep MAXMSGL)
        maxline=$(grep -A 30 -n "$queuename" $1 | grep MAXMSGL | awk -F"-" '{print $1}')

        sed -i "${customline}s/$customvalue/$newcustom/" $1
        sed -i "${maxline}s/$maxvalue/$newmax/" $1

done

printf "\nCUSTOM & MAXMSGL fields updated for all queues NOT system!\n"
