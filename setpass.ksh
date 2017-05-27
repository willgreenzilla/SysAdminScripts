#!/bin/ksh

####################################################################################################
##### setpass.ksh                                                                             ######
##### v1.0 - 10/20/2014                                                                       ######
##### will green                                                                              ######
####################################################################################################
##### Changes the account passwords based on file indicated in HOSTLIST variable              ######
####################################################################################################

# Base variables

FAN=1
HOSTLISTDIR="/home/greenw/scripts"

# Configure DSH variables

export DSH_NODE_RSH=/usr/bin/ssh
export DSH_NODE_OPTS="-q -o BatchMode=yes"
export DCP_NODE_RCP=/usr/bin/scp
export DSH_FANOUT=$FAN
export DSH_NODE_LIST="$HOSTLISTDIR/testhosts"
HOSTLIST="$HOSTLISTDIR/testhosts"

# Set account passwords

bolcca=`grep bolcca: ~/scripts/2014pw | awk -F: '{print $3}'`
bol_user=`grep bol_user: ~/scripts/2014pw | awk -F: '{print $3}'`
adobelc=`grep adobelc: ~/scripts/2014pw | awk -F: '{print $3}'`
boxiaudit=`grep boxiaudit: ~/scripts/2014pw | awk -F: '{print $3}'`
boxiuser=`grep boxiuser: ~/scripts/2014pw | awk -F: '{print $3}'`
crysrep=`grep crysrep: ~/scripts/2014pw | awk -F: '{print $3}'`
dpris=`grep dpris: ~/scripts/2014pw | awk -F: '{print $3}'`
eas=`grep eas: ~/scripts/2014pw | awk -F: '{print $3}'`
erc=`grep erc: ~/scripts/2014pw | awk -F: '{print $3}'`
ercconct=`grep ercconct: ~/scripts/2014pw | awk -F: '{print $3}'`
esubmiss=`grep esubmiss: ~/scripts/2014pw | awk -F: '{print $3}'`
ibmcmadm=`grep ibmcmadm: ~/scripts/2014pw | awk -F: '{print $3}'`
icmadmin=`grep icmadmin: ~/scripts/2014pw | awk -F: '{print $3}'`
icmconct=`grep icmconct: ~/scripts/2014pw | awk -F: '{print $3}'`
lcad=`grep lcad: ~/scripts/2014pw | awk -F: '{print $3}'`
kofaxvnv=`grep kofaxvnv: ~/scripts/2014pw | awk -F: '{print $3}'`
oebs=`grep oebs: ~/scripts/2014pw | awk -F: '{print $3}'`
rep_sr=`grep rep_sr: ~/scripts/2014pw | awk -F: '{print $3}'`
rmadmin=`grep rmadmin: ~/scripts/2014pw | awk -F: '{print $3}'`
rom=`grep rom: ~/scripts/2014pw | awk -F: '{print $3}'`
selbd=`grep selbd: ~/scripts/2014pw | awk -F: '{print $3}'`
selbd_cm=`grep selbd_cm: ~/scripts/2014pw | awk -F: '{print $3}'`
smdbadm=`grep smdbadm: ~/scripts/2014pw | awk -F: '{print $3}'`
wasdbu=`grep wasdbu: ~/scripts/2014pw | awk -F: '{print $3}'`
wasf=`grep wasf: ~/scripts/2014pw | awk -F: '{print $3}'`
wasndm=`grep wasndm: ~/scripts/2014pw | awk -F: '{print $3}'`
wass=`grep wass: ~/scripts/2014pw | awk -F: '{print $3}'`

# Change account passwords on all servers indicated in dsh at top
# Passsword is retrieved from marked 2014pw file based on column

while read line
do
        ACCOUNT=$line

        dsh "echo 'bolcca:$bolcca'|sudo chpasswd" 2>/dev/null
        dsh "echo 'bol_user:$bol_user'|sudo chpasswd" 2>/dev/null
        dsh "echo 'adobelc:$adobelc'|sudo chpasswd" 2>/dev/null
        dsh "echo 'boxiaudit:$boxiaudit'|sudo chpasswd" 2>/dev/null
        dsh "echo 'boxiuser:$boxiuser'|sudo chpasswd" 2>/dev/null
        dsh "echo 'crysrep:$crysrep'|sudo chpasswd" 2>/dev/null
        dsh "echo 'dpris:$dpris'|sudo chpasswd" 2>/dev/null
        dsh "echo 'eas:$eas'|sudo chpasswd" 2>/dev/null
        dsh "echo 'erc:$erc'|sudo chpasswd" 2>/dev/null
        dsh "echo 'ercconct:$ercconct'|sudo chpasswd" 2>/dev/null
        dsh "echo 'esubmiss:$esubmiss'|sudo chpasswd" 2>/dev/null
        dsh "echo 'ibmcmadm:$ibmcmadm'|sudo chpasswd" 2>/dev/null
        dsh "echo 'icmadmin:$icmadmin'|sudo chpasswd" 2>/dev/null
        dsh "echo 'icmconct:$icmconct'|sudo chpasswd" 2>/dev/null
        dsh "echo 'lcad:$lcad'|sudo chpasswd" 2>/dev/null
        dsh "echo 'kofaxvnv:$kofaxvnv'|sudo chpasswd" 2>/dev/null
        dsh "echo 'oebs:$oebs'|sudo chpasswd" 2>/dev/null
        dsh "echo 'rep_sr:$rep_sr'|sudo chpasswd" 2>/dev/null
        dsh "echo 'rmadmin:$rmadmin'|sudo chpasswd" 2>/dev/null
        dsh "echo 'rom:$rom'|sudo chpasswd" 2>/dev/null
        dsh "echo 'selbd:$selbd'|sudo chpasswd" 2>/dev/null
        dsh "echo 'smdbadm:$smdbadm'|sudo chpasswd" 2>/dev/null
        dsh "echo 'wasdbu:$wasdbu'|sudo chpasswd" 2>/dev/null
        dsh "echo 'wasf:$wasf'|sudo chpasswd" 2>/dev/null
        dsh "echo 'wasndm:$wasndm'|sudo chpasswd" 2>/dev/null
        dsh "echo 'wass:$wass'|sudo chpasswd" 2>/dev/null

done < $1

print "Done!\n"
