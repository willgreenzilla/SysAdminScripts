#!/bin/ksh

####################################################################################################
##### get-info.ksh                                                                            ######
##### v1.0 - 9/30/2015                                                                        ######
##### will green                                                                              ######
####################################################################################################
##### To run: ./get-info.ksh                                                                  ######
##### Requires: allhosts file with list of hosts to have info gathered from (just hostname)   ######
#####           and have get-info.ksh script in the same dir as the host list file            ######
####################################################################################################

# Variables 
FAN=1

# Sort list of hosts to maintain sync
cat allhosts | sort > sorthostlist

# Configure DSH variables
export DSH_NODE_RSH=/usr/bin/ssh
export DSH_NODE_OPTS="-q -o BatchMode=yes"
export DCP_NODE_RCP=/usr/bin/scp
export DSH_FANOUT=$FAN
export DSH_NODE_LIST="sorthostlist"

cat sorthostlist > outputinfo

# Build the FQDN and IP columns
cat outputinfo | while read HOST; do

        nslookup $HOST | grep Name | awk -F: '{print $2}' | perl -pe 's/^\s+//' >> outputinfo1
        nslookup $HOST | grep Address:" " | awk -F: '{print $2}' | perl -pe 's/^\s+//' >> outputinfo8

done

# Gather OS level info
dsh oslevel -s >> outputinfotmp 2>/dev/null

# Build OS level column
cat outputinfotmp | awk -F" " '{print $2}' | perl -pe 's/^\s+//' > outputinfotmp
cat outputinfotmp | while read OSLEVEL; do
        print "AIX-""$OSLEVEL" >> outputinfo2   
done

rm outputinfotmp

# Gather memory info
dsh /usr/sbin/lsattr -El sys0 -a realmem >> outputinfotmp 2>/dev/null

# Build total memory columns
cat outputinfotmp | while read MEM; do
        MEMCALC=`print "$MEM" | awk -F" " '{print $3}'`
        let TOTMEM=$MEMCALC/1024/1024 
        print "$TOTMEM""GB" >> outputinfo3
done

rm outputinfotmp

# Gather CPU info
dsh /usr/bin/lparstat -i >> outputinfotmp 2>/dev/null

# Build desired virtual CPU column
cat outputinfotmp | grep "Desired Virtual CPUs" | awk -F: '{print $3}' | perl -pe 's/^\s+//' > outputinfo4

# Build active physical CPU column
cat outputinfotmp | grep "Active Physical CPUs" | awk -F: '{print $3}' | perl -pe 's/^\s+//' > outputinfo5

# Determine environment
cat outputinfo1 | awk -F. '{print $2}' > outputinfo6

# Build environment column and set based on info in fqdn
cat outputinfo6 | while read ENV; do

        if [ "$ENV" == "sb" ]; then
                print "Selbd Production" >> outputinfo7
        elif [ "$ENV" == "dev" ]; then
                print "Development" >> outputinfo7
        elif [ "$ENV" == "test" ]; then
                print "Test" >> outputinfo7
        elif [ "$ENV" == "mdc" ]; then
                print "Production" >> outputinfo7
        fi
done

rm outputinfotmp

# Gather MAC address info and build MAC column
dsh "/usr/sbin/netstat -ia | grep : | awk -F' ' '{print $2}' | grep : | grep -v :: | sed 's/:/./g' | tr -s '\n' ', ' | rev | cut -c 2- | rev | sed 's/,/,/g'" 2>/dev/null | awk -F: '{print $2}' | sed 's/ //g' | sed 's/,/,/g' >> outputinfo9

# Gather file system mount info
dsh "/usr/bin/df -g | grep -v Filesystem | grep -v lbos | perl -pne 's/[^\S\n]+/,/g' | cut -d',' -f'7 2' | tr -s '\n' ','" 2>/dev/null | awk -F: '{print $2}' >> outputinfotmp 

# Build file system column
cat outputinfotmp | rev | cut -c 2- | rev | while read DF; do

        print "$DF" >> outputinfo10 

done

# Build final output
print "Hostname:FQDN:OS:Memory:Virtual CPUs:Active Physical CPUs:Environment:IP:MAC:Filesystems (GB,mount)" > finalout
paste -d: outputinfo outputinfo1 outputinfo2 outputinfo3 outputinfo4 outputinfo5 outputinfo7 outputinfo8 outputinfo9 outputinfo10 >> finalout

# Give import instructions
print "\nTo import into Excel perform the following steps:\n\n1) Copy the following info block and paste into Excel (cell A1)\n2) Click on the A column header to highlight entire column\n3) Select the Data ribbon tab\n4) Select Text to Columns button\n5) Select the Delimited radio button and hit the Next button\n6) Check only the Other delimiters box and input a colon (:) into the field and hit the Next button\n7) Hit the Finish button\n8) Arrange column width as desired\n"

# Display final assembled gathered info
cat finalout

echo

# Purge temp files
rm outputinfo outputinfo1 outputinfo2 outputinfo3 outputinfo4 outputinfo5 outputinfo6
rm outputinfo7 outputinfo8 outputinfo9 outputinfo10 outputinfotmp sorthostlist
