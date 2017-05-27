#!/bin/ksh

#####################################################################################
##### deploy.ksh							v1.1	                                            #####
#####################################################################################
##### Script to be ran AFTER prep.ksh has been ran				                      #####
##### by Will Green (willgreen@ieee.org) 				                                #####
##### &  David Byron (xxxxx) 			                  	                          #####
##### 1/31/2014				 				                                                  #####
#####################################################################################

##### VARIABLES #####

FULLDOMAIN='changeme.local'
CASINO1='CHANGEME'
CASINO2='CHANGEME'
CASINO3='CHANGEME'
CASINO4='CHANGEME'
GAMEPASSWORD='CHANGEME'
BACKUPPCPW='CHANGEME'
SAMBABACKUPPW='CHANGEME'
SQLKEY='CHANGEME'
MYSQLROOTPW='CHANGEME'
MYSQLCHECKPW=`tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1`
MYSQLBACKPW=`tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1`
PROGNAME=$(basename $0)
EXITCODES='EXIT CODES: |1| General |2| Misuse of shell builtins |126| Command cannot execute |127| Command not found |128| Invalid argument'

##### IP HOSTLIST CHOP #####

LB1IP=`grep lb1 /root/hostlist | awk -F: '{print $3}'`
LB2IP=`grep lb2 /root/hostlist | awk -F: '{print $3}'`
WEB1IP=`grep web1 /root/hostlist | awk -F: '{print $3}'`
WEB2IP=`grep web2 /root/hostlist | awk -F: '{print $3}'`
WEB3IP=`grep web3 /root/hostlist | awk -F: '{print $3}'`
WEB4IP=`grep web4 /root/hostlist | awk -F: '{print $3}'`
DB1IP=`grep db1 /root/hostlist | awk -F: '{print $3}'`
DB2IP=`grep db2 /root/hostlist | awk -F: '{print $3}'`
MGMT1IP=`grep mgmt1 /root/hostlist | awk -F: '{print $3}'`
NODJS1IP=`grep nodejs1 /root/hostlist | awk -F: '{print $3}'`
NFS1IP=`grep nfs1 /root/hostlist | awk -F: '{print $3}'`
EMAIL1IP=`grep emaildns1 /root/hostlist | awk -F: '{print $3}'`
EMAIL2IP=`grep emaildns2 /root/hostlist | awk -F: '{print $3}'`
SYS1IP=`grep sys1 /root/hostlist | awk -F: '{print $3}'`
TIME1IP=`grep time1 /root/hostlist | awk -F: '{print $3}'`
TIME2IP=`grep time2 /root/hostlist | awk -F: '{print $3}'`
WINDC1IP=`grep windc1 /root/hostlist | awk -F: '{print $3}'`
WINDC2IP=`grep windc2 /root/hostlist | awk -F: '{print $3}'`
FIREWALL1IP=`grep firewall /root/hostlist | awk -F: '{print $3}'`
OUTBOUNDIP=`grep outip /root/hostlist | awk -F: '{print $3}'`
POSTOUTIP=`grep postout /root/hostlist | awk -F: '{print $3}'`
LBFLOAT1=`grep float1 /root/hostlist | awk -F: '{print $3}'`
LBFLOAT2=`grep float2 /root/hostlist | awk -F: '{print $3}'`
LBFLOAT3=`grep float3 /root/hostlist | awk -F: '{print $3}'`
LBFLOAT4=`grep float4 /root/hostlist | awk -F: '{print $3}'`

##### FQDN HOSTLIST CHOP #####

LB1FQDN=`grep lb1 /root/hostlist | awk -F: '{print $2}'`
LB2FQDN=`grep lb2 /root/hostlist | awk -F: '{print $2}'`
WEB1FQDN=`grep web1 /root/hostlist | awk -F: '{print $2}'`
WEB2FQDN=`grep web2 /root/hostlist | awk -F: '{print $2}'`
WEB3FQDN=`grep web3 /root/hostlist | awk -F: '{print $2}'`
WEB4FQDN=`grep web4 /root/hostlist | awk -F: '{print $2}'`
DB1FQDN=`grep db1 /root/hostlist | awk -F: '{print $2}'`
DB2FQDN=`grep db2 /root/hostlist | awk -F: '{print $2}'`
MGMT1FQDN=`grep mgmt1 /root/hostlist | awk -F: '{print $2}'`
NODJS1FQDN=`grep nodejs1 /root/hostlist | awk -F: '{print $2}'`
NFS1FQDN=`grep nfs1 /root/hostlist | awk -F: '{print $2}'`
EMAIL1FQDN=`grep emaildns1 /root/hostlist | awk -F: '{print $2}'`
EMAIL2FQDN=`grep emaildns2 /root/hostlist | awk -F: '{print $2}'`
SYS1FQDN=`grep sys1 /root/hostlist | awk -F: '{print $2}'`
VIPLB=`grep lbmail2 /root/hostlist | awk -F: '{print $2}'`
WINDC1FQDN=`grep windc1 /root/hostlist | awk -F: '{print $2}'`
WINDC2FQDN=`grep windc2 /root/hostlist | awk -F: '{print $2}'`
MAILNAME=`grep mailname /root/hostlist | awk -F: '{print $2}'`
CAPDOMAIN=`grep windc1 /root/hostlist | awk -F: '{print $2}' | awk -F. '{print $2"."$3"."$4}' | awk '{print toupper($0)}'`
WINDC1FQDN1=`grep -w windc1 /root/hostlist | awk -F: '{print $2}'`
WINDC1FQDN2=`grep -w windc1 /root/hostlist | awk -F: '{print $2}' | awk -F. '{print $2}'`
WINDC1FQDN3=`grep -w windc1 /root/hostlist | awk -F: '{print $2}' | awk -F. '{print $3}'`
WINDC1FQDN4=`grep -w windc1 /root/hostlist | awk -F: '{print $2}' | awk -F. '{print $4}'`
WINDC2FQDN2=`grep -w windc2 /root/hostlist | awk -F: '{print $2}'`
WINDC2FQDN3=`grep -w windc2 /root/hostlist | awk -F: '{print $2}' | awk -F. '{print $3}'`
WINDC2FQDN4=`grep -w windc2 /root/hostlist | awk -F: '{print $2}' | awk -F. '{print $4}'`
LBLOCALFQDN=`grep lblocal /root/hostlist | awk -F: '{print $2}'`
LBMAIL1FQDN=`grep -w lbmail /root/hostlist | awk -F: '{print $2}'`
LBMAIL2FQDN=`grep -w lbmail2 /root/hostlist | awk -F: '{print $2}'`
VARNISHLOCALFQDN=`grep -w varnish /root/hostlist | awk -F: '{print $2}'`

### PORT HOSTLIST CHOP ###

DB1PORT=`grep db1 /root/hostlist | awk -F: '{print $4}'`
DB2PORT=`grep db1 /root/hostlist | awk -F: '{print $4}'`
LBPORT=`grep lblocal /root/hostlist | awk -F: '{print $4}'`
WEB1PORT=`grep web1 /root/hostlist | awk -F: '{print $4}'`
WEB2PORT=`grep web2 /root/hostlist | awk -F: '{print $4}'`
WEB3PORT=`grep web3 /root/hostlist | awk -F: '{print $4}'`
WEB4PORT=`grep web4 /root/hostlist | awk -F: '{print $4}'`
LBMAIL1PORT=`grep -w lbmail /root/hostlist | awk -F: '{print $4}'`
LBMAIL2PORT=`grep -w lbmail2 /root/hostlist | awk -F: '{print $4}'`
NODEJS1PORT=`grep nodejs1 /root/hostlist | awk -F: '{print $4}'`
LBSEC1PORT=`grep float1 /root/hostlist | awk -F: '{print $4}'`
LBSEC2PORT=`grep float2 /root/hostlist | awk -F: '{print $4}'`
LBSEC3PORT=`grep float3 /root/hostlist | awk -F: '{print $4}'`
LBSEC4PORT=`grep float4 /root/hostlist | awk -F: '{print $4}'`
VARNISHPORT1=`grep -w varnish /root/hostlist | awk -F: '{print $4}'`
VARNISHPORT2=`grep -w varnishlocal /root/hostlist | awk -F: '{print $4}'`
WINDC1PORT=`grep -w windc1 /root/hostlist | awk -F: '{print $4}'`
WINDC2PORT=`grep -w windc2 /root/hostlist | awk -F: '{print $4}'`
DB1PORT=`grep db1 /root/hostlist | awk -F: '{print $4}'`
DB2PORT=`grep db1 /root/hostlist | awk -F: '{print $4}'`

##### ERROR CHECKING #####

function error_exit
{

#       ----------------------------------------------------------------
#       Function for exit due to fatal program error
#               Accepts 1 argument:
#                       string containing descriptive error message
#       ----------------------------------------------------------------


	print "\n${PROGNAME}: ${1:-"Unknown Error"}\n" 1>&2
        exit 1
}

##### SETUP #####

# Create hostnamelist file from main hostlist
cat /root/hostlist | sed -e '/^$/,$d' | awk -F: '{print $3}' > hostnamelist



##### MENU #####

selection=
until [ "$selection" = "x|X" ]; do

# Generate option list and read input
print "\n#########################################################################################\niGP AUTOMATED DEPLOYMENT v1.1\n#########################################################################################\nSelect an option from the list below:\n#########################################################################################\n\n1) Test Linux Network Connections\t\t2) Push SSH Keys\n3) Rsync scripts/configs/repo/bin\t\t4) Test Parallel\n5) Configure resolv.conf & hosts\t\t6) Create Local Repo\n7) Setup Linux Mgmt Server LDAP\t\t\t8) Setup Other Linux Servers for LDAP\n9) Install & Configure VSFTPD\t\t\t10) Install & Configure phpMyAdmin\n11) Install & Configure BACKUPPC\t\t12) Install & Configure NTP\n13) DB: Generate GPG Keys & DB Hostlist\t\t14) DB: Install MySQL\n15) DB: MySQL HAProxy Setup\t\t\t16) DB: MySQL Backup Setup\n17) LB2: Install & Configure HAProxy\t\t18) LB2: Install & Configure Heartbeat\n19) LB2: Install & Configure Nginx\t\t20) LB2: Install & Configure Memcached\n21) LB2: Install & Configure Varnish\t\t22) LB1: Install & Configure HAProxy\n23) LB1: Install & Configure Heartbeat\t\t24) LB1: Install & Configure Nginx\n25) LB1: Install & Configure Memcached\t\t26) LB1: Install & Configure Varnish\n27) Install & Configure Apache\n\nx) Exit\n\n#########################################################################################\n"

read OPTION

case $OPTION in

##### TEST NETWORK CONNECTIONS #####
1) print "\n#########################################################################################\nTESTING NETWORK CONNECTIONS\n#########################################################################################\n"

# Send out a ping to every box and respond back w/UP or DOWN status
cat hostnamelist | while read ip; do
    if ping -c1 -t2 $ip >/dev/null 2>&1; then
        echo $ip IS UP
    else
        echo $ip IS DOWN
    fi
done

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### KEY PUSH #####
2) print "\n#########################################################################################\nGENERATING & PUSHING/PULLING SSH KEYS\n#########################################################################################\n"

# Generate root key

ssh-keygen -f /root/.ssh/id_rsa -q -N ""

# Push root SSH keys to all boxes

scp /root/.ssh/id_rsa.pub root@$LB1IP:/tmp/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."
scp /root/.ssh/id_rsa.pub root@$LB2IP:/tmp/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."
scp /root/.ssh/id_rsa.pub root@$WEB1IP:/tmp/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."
scp /root/.ssh/id_rsa.pub root@$WEB2IP:/tmp/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."
scp /root/.ssh/id_rsa.pub root@$DB1IP:/tmp/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."

ssh root@$LB1IP 'ssh-keygen -f /root/.ssh/id_rsa -q -N ""; cat /tmp/id_rsa.pub>>/root/.ssh/authorized_keys; rm /tmp/id_rsa.pub' || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP 'ssh-keygen -f /root/.ssh/id_rsa -q -N ""; cat /tmp/id_rsa.pub>>/root/.ssh/authorized_keys; rm /tmp/id_rsa.pub' || error_exit "ERROR at Line $LINENO of Script."
ssh root@$WEB1IP 'ssh-keygen -f /root/.ssh/id_rsa -q -N ""; cat /tmp/id_rsa.pub>>/root/.ssh/authorized_keys; rm /tmp/id_rsa.pub' || error_exit "ERROR at Line $LINENO of Script."
ssh root@$WEB2IP 'ssh-keygen -f /root/.ssh/id_rsa -q -N ""; cat /tmp/id_rsa.pub>>/root/.ssh/authorized_keys; rm /tmp/id_rsa.pub' || error_exit "ERROR at Line $LINENO of Script."
ssh root@$DB1IP 'ssh-keygen -f /root/.ssh/id_rsa -q -N ""; cat /tmp/id_rsa.pub>>/root/.ssh/authorized_keys; rm /tmp/id_rsa.pub' || error_exit "ERROR at Line $LINENO of Script."

# Slurp keys back to mgmt box

mkdir /tmp/$LB1IP || error_exit "ERROR at Line $LINENO of Script."
mkdir /tmp/$LB2IP || error_exit "ERROR at Line $LINENO of Script."
mkdir /tmp/$WEB1IP || error_exit "ERROR at Line $LINENO of Script."
mkdir /tmp/$WEB2IP || error_exit "ERROR at Line $LINENO of Script."
mkdir /tmp/$DB1IP || error_exit "ERROR at Line $LINENO of Script."

scp root@$LB1IP:/root/.ssh/id_rsa.pub /tmp/$LB1IP/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."
scp root@$LB2IP:/root/.ssh/id_rsa.pub /tmp/$LB2IP/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."
scp root@$WEB1IP:/root/.ssh/id_rsa.pub /tmp/$WEB1IP/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."
scp root@$WEB2IP:/root/.ssh/id_rsa.pub /tmp/$WEB2IP/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."
scp root@$DB1IP:/root/.ssh/id_rsa.pub /tmp/$DB1IP/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script."

cat /tmp/$LB1IP/id_rsa.pub>>/root/.ssh/authorized_keys || error_exit "ERROR at Line $LINENO of Script."
cat /tmp/$LB2IP/id_rsa.pub>>/root/.ssh/authorized_keys || error_exit "ERROR at Line $LINENO of Script."
cat /tmp/$WEB1IP/id_rsa.pub>>/root/.ssh/authorized_keys || error_exit "ERROR at Line $LINENO of Script."
cat /tmp/$WEB2IP/id_rsa.pub>>/root/.ssh/authorized_keys || error_exit "ERROR at Line $LINENO of Script."
cat /tmp/$DB1IP/id_rsa.pub>>/root/.ssh/authorized_keys || error_exit "ERROR at Line $LINENO of Script."

# Add cloud key to mgmt server
cat /root/.ssh/id_rsa.pub | grep ssh-rsa>/tmp/cloudkey || error_exit "ERROR at Line $LINENO of Script."
scp /tmp/cloudkey root@10.1.220.41:/tmp/cloudkey || error_exit "ERROR at Line $LINENO of Script."
ssh root@10.1.220.41 "cat /tmp/cloudkey>>/root/.ssh/authorized_keys" || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### RSYNC OPT #####
3) print "\n#########################################################################################\nRSYNC SLASH OPT\n#########################################################################################\n"

##### RSYNC SCRIPTS/CONFIGS FROM UNIX ADM CLOUD BOX #####

rsync -avzhe ssh root@10.1.220.41:/opt/carnival/scripts/ /opt/scripts/ || error_exit "ERROR at Line $LINENO of Script."
rsync -avzhe ssh root@10.1.220.41:/opt/carnival/config/ /opt/config/ || error_exit "ERROR at Line $LINENO of Script."
rsync -avzhe ssh root@10.1.220.41:/opt/bin/ /opt/bin/ || error_exit "ERROR at Line $LINENO of Script."
rsync -avzhe ssh root@10.1.220.41:/opt/repo/ /opt/repo/ || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### PARALLEL SSH & KEY CHECK #####
4) print "\n#########################################################################################\nPARALLEL SSH & KEY CHECK\n#########################################################################################\n"

##### Check parallel works (thus keys working) #####

# Run parallel out to all boxes and check for success
parallel-ssh -l root -h hostnamelist "date"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### RESOLV.CONF & HOSTS UPDATE #####
5) print "\n#########################################################################################\nRESOLV.CONF\n#########################################################################################\n"

# Write DNS info into local resolve.conf
print "domain $FULLDOMAIN\nnameserver $WINDC1IP\nnameserver $WINDC2IP\nnameserver 8.8.8.8\noptions timeout: 1">/etc/resolv.conf || error_exit "ERROR at Line $LINENO of Script."

# Push resolve.conf to other boxes
parallel-scp -l root -h hostnamelist /etc/resolv.conf /etc/resolv.conf || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Update /etc/hosts locally
sed -i "s/goldimage.CHANGEME.local/$MGMT1FQDN/g" /etc/hosts || error_exit "ERROR at Line $LINENO of Script."
#sed -i -n -e :a -e '1,3!{P;N;D;};N;ba' /etc/hosts || error_exit "ERROR at Line $LINENO of Script."

# Update /etc/hosts on the other servers
parallel-ssh -l root -h hostnamelist 'FQDN=`hostname -f`; sed -i "s/goldimage.CHANGEME.local/$FQDN/g" /etc/hosts' || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i -n -e :a -e '1,3!{P;N;D;};N;ba' /etc/hosts" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### CREATE LOCAL REPO #####
6) print "\n#########################################################################################\nBUILD LOCAL REPO\n#########################################################################################\n"

# Install Apache
aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install libapache2-mod-php5 php5-mysql || error_exit "ERROR at Line $LINENO of Script."
aptitude update || error_exit "ERROR at Line $LINENO of Script."

# Create symbolic web link to /opt/repo
ln -s /opt/repo /var/www/repo || error_exit "ERROR at Line $LINENO of Script."

# Update sources.list
print "deb http://$MGMT1IP/repo binary/">/etc/apt/sources.list || error_exit "ERROR at Line $LINENO of Script."

# Shoot sources.list to all other boxes
parallel-scp -l root -h hostnamelist /etc/apt/sources.list /etc/apt/sources.list || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "aptitude update" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### SETUP LDAP LOCALLY ON MGMT SERVER #####
7) print "\n#########################################################################################\nSETUP LDAP ON MGMT SERVER\n#########################################################################################\n"

# Copy libnss-ldap.conf file over
cp /opt/config/ldap/libnss-ldap.conf /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."

# Make changes to libnss-ldap.conf
sed -i "s/WINDC1FQDN1/$WINDC1FQDN1/g" /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC1FQDN2/$WINDC1FQDN2/g" /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC1FQDN3/$WINDC1FQDN3/g" /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC1FQDN4/$WINDC1FQDN4/g" /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC2FQDN2/$WINDC2FQDN2/g" /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC2FQDN3/$WINDC2FQDN3/g" /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC2FQDN4/$WINDC2FQDN4/g" /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC1IP/$WINDC1IP/g" /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script."

# Copy over more ldap related configurations
cp /opt/config/ldap/common-password /etc/pam.d/common-password || error_exit "ERROR at Line $LINENO of Script."
cp /opt/config/ldap/common-session /etc/pam.d/common-session || error_exit "ERROR at Line $LINENO of Script."
cp /opt/config/ldap/nsswitch.conf /etc/nsswitch.conf || error_exit "ERROR at Line $LINENO of Script."

# Move nscd old to current
mv /etc/init.d/nscd.old /etc/init.d/nscd

# Restart nscd
/etc/init.d/nscd restart || error_exit "ERROR at Line $LINENO of Script."

# Copy over krb5.conf
cp /opt/config/ldap/krb5.conf /etc/krb5.conf || error_exit "ERROR at Line $LINENO of Script."

# Make changes to krb5.conf
sed -i "s/CAPDOMAIN/$CAPDOMAIN/g" /etc/krb5.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC1IP/$WINDC1IP/g" /etc/krb5.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/WINDC2IP/$WINDC2IP/g" /etc/krb5.conf || error_exit "ERROR at Line $LINENO of Script."

# Copy over sshd_config
cp /opt/config/ldap/sshd_config /etc/ssh/sshd_config || error_exit "ERROR at Line $LINENO of Script."

# Restart ssh service
service ssh restart || error_exit "ERROR at Line $LINENO of Script."

# Copy over nscd.conf
cp /opt/config/ldap/nscd.conf /etc/nscd.conf || error_exit "ERROR at Line $LINENO of Script."

# Restart nscd
/etc/init.d/nscd restart || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### SETUP LDAP ON THE OTHER LINUX SERVERS #####
8) print "\n#########################################################################################\nSETUP LDAP ON THE OTHER LINUX SERVERS\n#########################################################################################\n"

# Copy out libnss-ldap.conf
parallel-scp -l root -h hostnamelist /opt/config/ldap/libnss-ldap.conf /etc/libnss-ldap.conf || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Update libnss-ldap.conf
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC1FQDN1/$WINDC1FQDN1/g' /etc/libnss-ldap.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC1FQDN2/$WINDC1FQDN2/g' /etc/libnss-ldap.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC1FQDN3/$WINDC1FQDN3/g' /etc/libnss-ldap.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC1FQDN4/$WINDC1FQDN4/g' /etc/libnss-ldap.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC2FQDN2/$WINDC2FQDN2/g' /etc/libnss-ldap.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC2FQDN3/$WINDC2FQDN3/g' /etc/libnss-ldap.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC2FQDN4/$WINDC2FQDN4/g' /etc/libnss-ldap.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC1IP/$WINDC1IP/g' /etc/libnss-ldap.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Copy out ldap related configs
parallel-scp -l root -h hostnamelist /opt/config/ldap/common-password /etc/pam.d/common-password || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h hostnamelist /opt/config/ldap/common-session /etc/pam.d/common-session || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h hostnamelist /opt/config/ldap/nsswitch.conf /etc/nsswitch.conf || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Move nscd old to current
parallel-ssh -l root -h hostnamelist "mv /etc/init.d/nscd.old /etc/init.d/nscd"

# Restart nscd
parallel-ssh -l root -h hostnamelist -P "/etc/init.d/nscd restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Copy out krb5.conf
parallel-scp -l root -h hostnamelist /opt/config/ldap/krb5.conf /etc/krb5.conf || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Update krb5.conf
parallel-ssh -l root -h hostnamelist "sed -i 's/CAPDOMAIN/$CAPDOMAIN/g' /etc/krb5.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC1IP/$WINDC1IP/g' /etc/krb5.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/WINDC2IP/$WINDC2IP/g' /etc/krb5.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Copy out sshd_config
parallel-scp -l root -h hostnamelist /opt/config/ldap/sshd_config /etc/ssh/sshd_config || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Restart ssh service
parallel-ssh -l root -h hostnamelist -P "service ssh restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Copy out nscd.conf
parallel-scp -l root -h hostnamelist /opt/config/ldap/nscd.conf /etc/nscd.conf || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Restart nscd service
parallel-ssh -l root -h hostnamelist -P "/etc/init.d/nscd restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### VSFTPD #####
9) print "\n#########################################################################################\nVSFTPD\n#########################################################################################\n"

# Install vsftp packages
aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install vsftpd db4.8-util || error_exit "ERROR at Line $LINENO of Script."

# Copy over default configured vsftp config
cp /opt/config/mgmt/vsftpd.conf /etc/vsftpd.conf || error_exit "ERROR at Line $LINENO of Script."

# Create vsftpd_user_conf dir
mkdir -p /etc/vsftpd/vsftpd_user_conf/ || error_exit "ERROR at Line $LINENO of Script."

# Copy over createFtpUser
cp /opt/config/mgmt/createFtpUser /etc/vsftpd/createFtpUser || error_exit "ERROR at Line $LINENO of Script."

# Make execute
chmod +x /etc/vsftpd/createFtpUser || error_exit "ERROR at Line $LINENO of Script."

# Create ftp logins/passwords file
touch /etc/vsftpd/login.txt || error_exit "ERROR at Line $LINENO of Script."
print "CHANGEMEpoker\n$GAMEPASSWORD\nCHANGEMEcasino\n$GAMEPASSWORD\nCHANGEMEaccount\n$GAMEPASSWORD">/etc/vsftpd/login.txt  || error_exit "ERROR at Line $LINENO of Script."

# Create vsftpd accounts
/bin/ksh /etc/vsftpd/createFtpUser || error_exit "ERROR at Line $LINENO of Script."

# Modify local root of vsftpd accounts
sed "s/local_root=.*/local_root=\/home\/nfsshare\/cfn\/account\/cms/" /etc/vsftpd/vsftpd_user_conf/CHANGEMEaccount || error_exit "ERROR at Line $LINENO of Script."
sed "s/local_root=.*/local_root=\/home\/nfsshare\/cdn\/poker\/cms/" /etc/vsftpd/vsftpd_user_conf/CHANGEMEpoker || error_exit "ERROR at Line $LINENO of Script."
sed "s/local_root=.*/local_root=\/home\/nfsshare\/cdn\/casino\/cms/" /etc/vsftpd/vsftpd_user_conf/CHANGEMEcasino || error_exit "ERROR at Line $LINENO of Script."

# Edit pam.d for vsftpd
echo "auth required /lib/x86_64-linux-gnu/security/pam_userdb.so db=/etc/vsftpd/login">/etc/pam.d/vsftpd || error_exit "ERROR at Line $LINENO of Script."
echo "account required /lib/x86_64-linux-gnu/security/pam_userdb.so db=/etc/vsftpd/login">>/etc/pam.d/vsftpd || error_exit "ERROR at Line $LINENO of Script."

# Restart vsftpd
/etc/init.d/vsftpd restart || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### PHPMYADMIN  #####
10) print "\n#########################################################################################\nPHPMYADMIN\n#########################################################################################\n"

# Pull over and rename pma
# Origin located at http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.0.8/phpMyAdmin-4.0.8-all-languages.tar.gz
mv /opt/bin/phpMyAdmin-4.0.8-all-languages.tar.gz phpMyAdmin.tar.gz || error_exit "ERROR at Line $LINENO of Script."

# Untar to /var/www
tar -C /var/www -zxvf phpMyAdmin.tar.gz || error_exit "ERROR at Line $LINENO of Script."

# Rename pma dir
mv /var/www/phpMyAdmin-4.0.8-all-languages /var/www/phpMyAdmin || error_exit "ERROR at Line $LINENO of Script."

# Copy pma config
cp /opt/config/mgmt/config.inc.php /var/www/phpMyAdmin/config.inc.php || error_exit "ERROR at Line $LINENO of Script."

# Configure pma config
sed -i "s/DB1IP/$DB1IP/g" /var/www/phpMyAdmin/config.inc.php || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/DB1FQDN/$DB1FQDN/g" /var/www/phpMyAdmin/config.inc.php || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### BACKUPPC #####
11) print "\n#########################################################################################\nBACKUPPC\n#########################################################################################\n"

# Install backuppc
DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y -q=2 install backuppc || error_exit "ERROR at Line $LINENO of Script."

# Install libfile-rsyncp-perl
DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install libfile-rsyncp-perl || error_exit "ERROR at Line $LINENO of Script."

# Set pw
htpasswd -b /etc/backuppc/htpasswd backuppc $BACKUPPCPW || error_exit "ERROR at Line $LINENO of Script."

# Lay down backuppc configs
cp /opt/config/mgmt/backuppc/* /etc/backuppc/*

# Configure backuppc for site
mv /etc/backuppc/DB1.pl /etc/backuppc/${DB1FQDN}.pl || error_exit "ERROR at Line $LINENO of Script."
mv /etc/backuppc/WEB1.pl /etc/backuppc/${WEB1FQDN}.pl || error_exit "ERROR at Line $LINENO of Script."
mv /etc/backuppc/WEB2.pl /etc/backuppc/${WEB2FQDN}.pl || error_exit "ERROR at Line $LINENO of Script."
mv /etc/backuppc/LB1.pl /etc/backuppc/${LB1FQDN}.pl || error_exit "ERROR at Line $LINENO of Script."
mv /etc/backuppc/LB2.pl /etc/backuppc/${LB2FQDN}.pl || error_exit "ERROR at Line $LINENO of Script."

# Fix backuppc permissions
chgrp www-data /etc/backuppc/* || error_exit "ERROR at Line $LINENO of Script."
chown backuppc /etc/backuppc/* || error_exit "ERROR at Line $LINENO of Script."

# Update backuppc hosts file
print "$LB1FQDN\t0\n$LB2FQDN\t0\n$WEB1FQDN\t0\n$WEB2FQDN\t0\n$DB1FQDN\t0\n$MGMT1FQDN\t0">>/etc/backuppc/hosts || error_exit "ERROR at Line $LINENO of Script."

# Generate SSH keys
su -c 'ssh-keygen -f /var/lib/backuppc/.ssh/id_rsa -q -N ""' -s /bin/ksh backuppc || error_exit "ERROR at Line $LINENO of Script."

# Disable StrictHostKeyChecking in ssh_config
sed -i "s/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/" /etc/ssh/ssh_config || error_exit "ERROR at Line $LINENO of Script."

# Push backuppc public keys to root and to itself
cat /var/lib/backuppc/.ssh/id_rsa.pub >> /var/lib/backuppc/.ssh/authorized_keys
cat /var/lib/backuppc/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# Push authorized keys to all other site boxes for backuppc
parallel-scp -l root -h hostnamelist /var/lib/backuppc/.ssh/id_rsa.pub /tmp/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "cat /tmp/id_rsa.pub>>/root/.ssh/authorized_keys" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Create backuppc user on all other servers
parallel-ssh -l root -h hostnamelist "userdel -r backuppc;groupdel backuppc"
parallel-ssh -l root -h hostnamelist 'adduser backuppc --home /var/lib/backuppc --disabled-password --gecos ""' || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Push backuppc keygen script and run
parallel-scp -l root -h hostnamelist /opt/scripts/mgmt/quickkeygen.ksh /tmp/quickkeygen.ksh || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "/bin/ksh /tmp/quickkeygen.ksh" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "rm /tmp/quickkeygen.ksh"

# Copy mgmt backuppc keys to remote servers
parallel-scp -l root -h hostnamelist /var/lib/backuppc/.ssh/id_rsa.pub /tmp/id_rsa.pub || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "cat /tmp/id_rsa.pub>>/var/lib/backuppc/.ssh/authorized_keys; rm /tmp/id_rsa.pub" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Set backuppc password
parallel-ssh -l root -h hostnamelist "echo 'backuppc:$BACKUPPCPW'|chpasswd" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Build sudoers.d backuppc file
print "backuppc ALL=NOPASSWD: /usr/bin/rsync\nbackuppc ALL=NOPASSWD: /bin/tar">/etc/sudoers.d/backuppc_conf || error_exit "ERROR at Line $LINENO of Script."
chmod 0440 /etc/sudoers.d/backuppc_conf || error_exit "ERROR at Line $LINENO of Script."
/etc/init.d/sudo restart || error_exit "ERROR at Line $LINENO of Script."

# Push backuppc_conf sudoers.d file to all servers
parallel-scp -l root -h hostnamelist /etc/sudoers.d/backuppc_conf /etc/sudoers.d/backuppc_conf || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "/etc/init.d/sudo restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Link to backuppc.conf
ln -s /etc/backuppc/apache.conf /etc/apache2/conf.d/backuppc.conf || error_exit "ERROR at Line $LINENO of Script."

# Fix apache errors
print "\tInclude httpd.conf">>/etc/apache2/apache2.conf || error_exit "ERROR at Line $LINENO of Script."
print "ServerName localhost">/etc/apache2/httpd.conf || error_exit "ERROR at Line $LINENO of Script."
/etc/init.d/apache2 force-reload || error_exit "ERROR at Line $LINENO of Script."
/etc/init.d/apache2 restart || error_exit "ERROR at Line $LINENO of Script."
/etc/init.d/backuppc restart || error_exit "ERROR at Line $LINENO of Script."

# Install samba & cifs-utils
DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install cifs-utils samba || error_exit "ERROR at Line $LINENO of Script."

# Add samba dir
mkdir /mnt/samba || error_exit "ERROR at Line $LINENO of Script."

# Add samba share to fstab
print "//$WINDC1IP/backuppc\t/mnt/samba\tcifs\tcredentials=/root/.smbcredentials,iocharset=utf8\t0 0">>/etc/fstab || error_exit "ERROR at Line $LINENO of Script."

# Create samba credentials file
print "username=CHANGEME.local/backuppc\npassword=$SAMBABACKUPPW">/root/.smbcredentials || error_exit "ERROR at Line $LINENO of Script."
chmod 640 /root/.smbcredentials || error_exit "ERROR at Line $LINENO of Script."

# Mount samba share
mount -a || error_exit "ERROR at Line $LINENO of Script."

# Add cron backuppc rotation
print "00 8 * * 7 tar cvfj /mnt/samba/backuppc.tar.bz2 /var/lib/backuppc/pc/\n00 8 * * 3 tar cvfj /mnt/samba/backuppc.tar.bz2 /var/lib/backuppc/pc/">>/var/spool/cron/crontabs/root || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### SYSLOG CLIENT CHANGES #####
#print "\n########## SYSLOG CLIENT ##########\n"

# Move rsyslog.conf into place
#cp /opt/config/mgmt/rsyslog.conf /etc/rsyslog.conf

# Update rsyslog.conf with current syslog server ip
#sed -i "s/CHANGEME/$SYS1IP/g" /etc/rsyslog.conf

# Push rsyslog.conf out to all other servers
#parallel-scp -l root -h hostnamelist /etc/rsyslog.conf /etc/rsyslog.conf

##### NTP #####
12) print "\n#########################################################################################\nNTP\n#########################################################################################\n"

# Install ntpdate
aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install ntpdate || error_exit "ERROR at Line $LINENO of Script."

# Install ntpdate on other servers
parallel-ssh -l root -h hostnamelist "aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install ntpdate" || error_exit "ERROR at Line $LINENO of Script."

# Configure ntp.conf
sed -i "s/server 0.debian.pool.ntp.org iburst/#server 0.debian.pool.ntp.org iburst/g" /etc/ntp.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/server 1.debian.pool.ntp.org iburst/#server 1.debian.pool.ntp.org iburst/g" /etc/ntp.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/server 2.debian.pool.ntp.org iburst/#server 2.debian.pool.ntp.org iburst/g" /etc/ntp.conf || error_exit "ERROR at Line $LINENO of Script."
sed -i "s/server 3.debian.pool.ntp.org iburst/#server 3.debian.pool.ntp.org iburst\nserver $TIME1IP iburst\nserver $TIME2IP iburst/g" /etc/ntp.conf || error_exit "ERROR at Line $LINENO of Script."

# Stop ntp
/etc/init.d/ntp stop || error_exit "ERROR at Line $LINENO of Script."

# Sync time to time server
ntpdate $TIME1IP

# Change to UTC timezone
cp /usr/share/zoneinfo/UTC /etc/localtime || error_exit "ERROR at Line $LINENO of Script."

# Start ntp
/etc/init.d/ntp start || error_exit "ERROR at Line $LINENO of Script."

# Restart cron to update timezone in cron
/etc/init.d/cron restart || error_exit "ERROR at Line $LINENO of Script."

# Configure ntp.conf on other servers
parallel-ssh -l root -h hostnamelist "sed -i 's/server 0.debian.pool.ntp.org iburst/#server 0.debian.pool.ntp.org iburst/g' /etc/ntp.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/server 1.debian.pool.ntp.org iburst/#server 1.debian.pool.ntp.org iburst/g' /etc/ntp.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/server 2.debian.pool.ntp.org iburst/#server 2.debian.pool.ntp.org iburst/g' /etc/ntp.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h hostnamelist "sed -i 's/server 3.debian.pool.ntp.org iburst/#server 3.debian.pool.ntp.org iburst\nserver $MGMT1IP iburst/g' /etc/ntp.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Stop ntp on other servers
parallel-ssh -l root -h hostnamelist "/etc/init.d/ntp stop" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Sync server time to mgmt server
parallel-ssh -l root -h hostnamelist "npdate $MGMT1IP"

# Change to UTC timezone on other servers
parallel-ssh -l root -h hostnamelist "cp /usr/share/zoneinfo/UTC /etc/localtime" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Start ntp back up on other servers
parallel-ssh -l root -h hostnamelist "/etc/init.d/ntp start" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Restart cron on other servers to update timezone in cron
parallel-ssh -l root -h hostnamelist "/etc/init.d/cron restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### DB SERVER #####
13) print "\n#########################################################################################\nDB: Generate GPG Keys & DB Hostlist\n#########################################################################################\n"

# Build db list file
cat /root/hostlist | grep db | sed -e '/^$/,$d' | awk -F: '{print $3}' > /tmp/dbhostlist || error_exit "ERROR at Line $LINENO of Script."

##### GPG KEY #####

# Generate gpg key on mgmt server
gpg --keyserver keys.gnupg.net --recv-key A2098A6E || error_exit "ERROR at Line $LINENO of Script."

# Export gpg key
gpg -a --export A2098A6E | apt-key add - || error_exit "ERROR at Line $LINENO of Script."

# Copy keys over to the db server
parallel-rsync -r -l root -h /tmp/dbhostlist /root/.gnupg/ /root/.gnupg/ || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### MYSQL INSTALL & SETUP #####
14) print "\n#########################################################################################\nDB: Install MySQL\n#########################################################################################\n"

# Install mysql
parallel-ssh -l root -h /tmp/dbhostlist "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install mysql-server" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Create mysql dirs
parallel-ssh -l root -h /tmp/dbhostlist "mkdir -p /data/mysql/log/ /data/mysql/data/" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Chown mysql dirs
parallel-ssh -l root -h /tmp/dbhostlist "chown -Rf mysql:mysql /data/mysql" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Push my.cnf out and make hostname change
parallel-scp -l root -h /tmp/dbhostlist /opt/config/mysql/my.cnf /etc/mysql/my.cnf || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
#parallel-ssh -l root -h /tmp/dbhostlist 'IP=`hostname -I | awk -F" " '{print $1}'`; sed -i "s/THISHOST/$IP/g" /etc/mysql/my.cnf' || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h /tmp/dbhostlist "sed -i 's/THISHOST/$DB1IP/g' /etc/mysql/my.cnf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Stop mysql
parallel-ssh -l root -h /tmp/dbhostlist "/etc/init.d/mysql stop" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Shuffle files from old mysql dir to newly created one
parallel-ssh -l root -h /tmp/dbhostlist "mv /var/lib/mysql/* /data/mysql/data;rm /data/mysql/data/ib_logfile*" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Restart mysql
parallel-ssh -l root -h /tmp/dbhostlist "/etc/init.d/mysql restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### MYSQL HAPROXY SETUP #####
15) print "\n#########################################################################################\nDB: MySQL HAProxy Setup\n#########################################################################################\n"

# Send mysql.sql files to db server
parallel-scp -l root -h /tmp/dbhostlist /opt/scripts/mysql/mysql1.sql /tmp/mysql1.sql || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h /tmp/dbhostlist /opt/scripts/mysql/mysqlcheck.sql /tmp/mysqlcheck.sql || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h /tmp/dbhostlist /opt/scripts/mysql/mysqlback.sql /tmp/mysqlback.sql || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Setup timezone
parallel-ssh -l root -h /tmp/dbhostlist "mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root --force mysql" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Create mysqlCHANGEME user via mysql batch file
parallel-ssh -l root -h /tmp/dbhostlist "mysql -u root < /tmp/mysql1.sql" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Update mysqlcheck.sql PW
parallel-ssh -l root -h /tmp/dbhostlist "sed -i 's/CHANGEPW/$MYSQLCHECKPW/g' /tmp/mysqlcheck.sql" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Setup ha proxy check
parallel-ssh -l root -h /tmp/dbhostlist "mysql -u root < /tmp/mysqlcheck.sql" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install xinetd
parallel-ssh -l root -h /tmp/dbhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install xinetd" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Push over mysqlchk script
parallel-scp -l root -h /tmp/dbhostlist /opt/scripts/mysql/mysqlchk /opt/mysqlchk || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Update mysqlchk script pw
parallel-ssh -l root -h /tmp/dbhostlist "sed -i 's/CHANGEPW/$MYSQLCHECKPW/g' /opt/mysqlchk" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Set up script permissions
parallel-ssh -l root -h /tmp/dbhostlist "chown nobody /opt/mysqlchk;chmod 740 /opt/mysqlchk" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Add line to /etc/services
parallel-ssh -l root -h /tmp/dbhostlist 'print "mysqlchk\t9200/tcp\t\t\t# mysqlchk">>/etc/services' || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Copy over xinetd file
parallel-scp -l root -h /tmp/dbhostlist /opt/scripts/mysql/xinetd/mysqlchk /etc/xinetd.d/mysqlchk || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Restart xinetd service
parallel-ssh -l root -h /tmp/dbhostlist "/etc/init.d/xinetd restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### MYSQL BACKUP SETUP #####
16) print "\n#########################################################################################\nDB: MySQL Backup Setup\n#########################################################################################\n"

# Update mysqlback.sql file with generated random pw
parallel-ssh -l root -h /tmp/dbhostlist "sed -i 's/CHANGEPW/$MYSQLBACKPW/g' /tmp/mysqlback.sql" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Create mysqlbackup user
parallel-ssh -l root -h /tmp/dbhostlist "mysql -u root < /tmp/mysqlback.sql" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Send over dumpMySql.sh & DumpCopy.sh scripts
parallel-scp -l root -h /tmp/dbhostlist /opt/scripts/mysql/dumpMySQL.sh /opt/dumpMySQL.sh || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h /tmp/dbhostlist /opt/scripts/mysql/DumpCopy.sh /opt/DumpCopy.sh || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Update permissions on /opt scripts
parallel-ssh -l root -h /tmp/dbhostlist "chmod 740 /opt/dumpMySQL.sh;chmod 740 /opt/DumpCopy.sh" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Update mysqlbackup user PW to match
parallel-ssh -l root -h /tmp/dbhostlist "sed -i 's/CHANGEPW/$MYSQLBACKPW/g' /opt/dumpMySQL.sh" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Make backup directory
parallel-ssh -l root -h /tmp/dbhostlist "mkdir -p /data/mysql/backup/full" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Add dump scripts to crontab
parallel-ssh -l root -h /tmp/dbhostlist "sed -i 's/#$/30 3\t* * *\troot\t\/opt\/dumpMySQL.sh\n01 7\t* * *\troot\t\/opt\/DumpCopy.sh\n#/g' /etc/crontab" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h /tmp/dbhostlist "/etc/init.d/cron restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install samba & cifs-utils
parallel-ssh -l root -h /tmp/dbhostlist "aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install samba cifs-utils" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Add samba dir
parallel-ssh -l root -h /tmp/dbhostlist "mkdir /mnt/samba" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Add samba share to fstab
parallel-ssh -l root -h /tmp/dbhostlist "print "//$WINDC1IP/backuppc\t/mnt/samba\tcifs\tcredentials=/root/.smbcredentials,iocharset=utf8\t0 0">>/etc/fstab" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Create samba credentials file
parallel-ssh -l root -h /tmp/dbhostlist "print "username=CHANGEME.local/backuppc\npassword=$SAMBABACKUPPW">/root/.smbcredentials" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h /tmp/dbhostlist "chmod 640 /root/.smbcredentials" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Mount samba share
parallel-ssh -l root -h /tmp/dbhostlist "mount -a" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Set mysql root password
parallel-ssh -l root -h /tmp/dbhostlist "mysqladmin -u root password $MYSQLROOTPW"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LOAD BALANCER 2 #####

##### LB2: HAProxy #####
17) print "\n#########################################################################################\nLB2: HAProxy Setup\n#########################################################################################\n"

# Install HA Proxy
ssh root@$LB2IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install haproxy" || error_exit "ERROR at Line $LINENO of Script."

# Make backup of the haproxy.cfg config
ssh root@$LB2IP "cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.dist" || error_exit "ERROR at Line $LINENO of Script."

# Copy over /etc/haproxy.cfg file
scp /opt/config/lb/haproxy.cfg root@$LB2IP:/etc/haproxy/haproxy.cfg || error_exit "ERROR at Line $LINENO of Script."

# Update haproxy.cfg
ssh root@$LB2IP "sed -i 's/LBFLOAT4/$LBFLOAT4/g' /etc/haproxy/haproxy.cfg" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/DB1FQDN/$DB1FQDN/g' /etc/haproxy/haproxy.cfg" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/DB1PORT/$DB1PORT/g' /etc/haproxy/haproxy.cfg" || error_exit "ERROR at Line $LINENO of Script."

# Copy over haproxy config
scp /opt/config/lb/haproxy root@$LB2IP:/etc/default/haproxy || error_exit "ERROR at Line $LINENO of Script."

# Retart haproxy daemon
ssh root@$LB2IP "/etc/init.d/haproxy stop; /etc/init.d/haproxy start"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LB2: Heartbeat #####
18) print "\n#########################################################################################\nLB2: Heartbeat Setup\n#########################################################################################\n"

# Install heartbeat
ssh root@$LB2IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install heartbeat" || error_exit "ERROR at Line $LINENO of Script."

# Authorization keys
ssh root@$LB2IP 'echo "auth 1" >> /etc/ha.d/authkeys' || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP 'echo "1 md5 \"oieYGYgfug665443hhgfdYG6576"\" >> /etc/ha.d/authkeys' || error_exit "ERROR at Line $LINENO of Script."

# chmod authkeys file
ssh root@$LB2IP "chmod 600 /etc/ha.d/authkeys" || error_exit "ERROR at Line $LINENO of Script."

# Move over ha.cf config
scp /opt/config/lb/ha.cf.lb2 root@$LB2IP:/etc/ha.d/ha.cf || error_exit "ERROR at Line $LINENO of Script."

# Update ha.cf config
ssh root@$LB2IP "sed -i 's/LB1IP/$LB1IP/g' /etc/ha.d/ha.cf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LB1FQDN/$LB1FQDN/g' /etc/ha.d/ha.cf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LB2FQDN/$LB2FQDN/g' /etc/ha.d/ha.cf" || error_exit "ERROR at Line $LINENO of Script."

# Move over ARPing config
scp /opt/config/lb/ARPing root@$LB2IP:/etc/ha.d/resource.d/ARPing || error_exit "ERROR at Line $LINENO of Script."

# Make executable
ssh root@$LB2IP "chmod +x /etc/ha.d/resource.d/ARPing" || error_exit "ERROR at Line $LINENO of Script."

# Move over haresources
scp /opt/config/lb/haresources root@$LB2IP:/etc/ha.d/haresources || error_exit "ERROR at Line $LINENO of Script."

# Update haresources
ssh root@$LB2IP "sed -i 's/LB1FQDN/$LB1FQDN/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LB2FQDN/$LB2FQDN/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/FIREWALL1IP/$FIREWALL1IP/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBFLOAT1/$LBFLOAT1/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBFLOAT2/$LBFLOAT2/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBFLOAT3/$LBFLOAT3/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBFLOAT4/$LBFLOAT4/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."

# Move over iptable rules
scp /opt/config/lb/rules.v4 root@$LB2IP:/etc/iptables/rules.v4 || error_exit "ERROR at Line $LINENO of Script."

# Save iptables
ssh root@$LB2IP "iptables-save" || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LB2: NGINX #####
19) print "\n#########################################################################################\nLB2: NGINX Setup\n#########################################################################################\n"

# Copy over nginx tar file
scp /opt/bin/nginx-1.4.3.tar.gz root@$LB2IP:/root/nginx-1.4.3.tar.gz || error_exit "ERROR at Line $LINENO of Script."

# Un-tar nginx
ssh root@$LB2IP "tar xzf /root/nginx-1.4.3.tar.gz" || error_exit "ERROR at Line $LINENO of Script."

# Install libpcre3-dev & libssl-dev
ssh root@$LB2IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install libpcre3-dev libssl-dev" || error_exit "ERROR at Line $LINENO of Script."

# Configure
ssh root@$LB2IP "cd nginx-1.4.3;./configure --with-http_ssl_module" || error_exit "ERROR at Line $LINENO of Script."

# Make install
ssh root@$LB2IP "cd nginx-1.4.3;make && make install" || error_exit "ERROR at Line $LINENO of Script."

# Copy over nginx and nginx.conf
scp /opt/config/lb/nginx.conf root@$LB2IP:/usr/local/nginx/conf/nginx.conf || error_exit "ERROR at Line $LINENO of Script."
scp /opt/config/lb/nginx root@$LB2IP:/etc/init.d/nginx || error_exit "ERROR at Line $LINENO of Script."

# Set permissions
ssh root@$LB2IP "chmod +x /etc/init.d/nginx" || error_exit "ERROR at Line $LINENO of Script."

# Make nginx log dir
ssh root@$LB2IP "mkdir -p /var/log/nginx" || error_exit "ERROR at Line $LINENO of Script."

# Start nginx
ssh root@$LB2IP "/etc/init.d/nginx start" || error_exit "ERROR at Line $LINENO of Script."

# Make nginx dirs
ssh root@$LB2IP "mkdir /usr/local/nginx/sites-available" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "mkdir /usr/local/nginx/sites-enabled" || error_exit "ERROR at Line $LINENO of Script."

# Copy over /usr/local/nginx/sites-available website conf files
scp /opt/config/lb/$CASINO1.conf root@$LB2IP:/usr/local/nginx/sites-available/$CASINO1.conf || error_exit "ERROR at Line $LINENO of Script."
scp /opt/config/lb/$CASINO2.conf root@$LB2IP:/usr/local/nginx/sites-available/$CASINO2.conf || error_exit "ERROR at Line $LINENO of Script."
scp /opt/config/lb/$CASINO3.conf root@$LB2IP:/usr/local/nginx/sites-available/$CASINO3.conf || error_exit "ERROR at Line $LINENO of Script."
scp /opt/config/lb/$CASINO4.conf root@$LB2IP:/usr/local/nginx/sites-available/$CASINO4.conf || error_exit "ERROR at Line $LINENO of Script."

# Update nginx conf files
ssh root@$LB2IP "sed -i 's/LBFLOAT2/$LBFLOAT2/g' /usr/local/nginx/sites-available/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBSEC2PORT/$LBSEC2PORT/g' /usr/local/nginx/sites-available/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /usr/local/nginx/sites-available/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBPORT/$LBPORT/g' /usr/local/nginx/sites-available/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."

ssh root@$LB2IP "sed -i 's/LBFLOAT1/$LBFLOAT1/g' /usr/local/nginx/sites-available/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBSEC1PORT/$LBSEC1PORT/g' /usr/local/nginx/sites-available/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /usr/local/nginx/sites-available/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBPORT/$LBPORT/g' /usr/local/nginx/sites-available/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."

ssh root@$LB2IP "sed -i 's/LBFLOAT3/$LBFLOAT3/g' /usr/local/nginx/sites-available/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBSEC3PORT/$LBSEC3PORT/g' /usr/local/nginx/sites-available/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /usr/local/nginx/sites-available/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBPORT/$LBPORT/g' /usr/local/nginx/sites-available/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."

ssh root@$LB2IP "sed -i 's/LBFLOAT4/$LBFLOAT4/g' /usr/local/nginx/sites-available/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBSEC4PORT/$LBSEC4PORT/g' /usr/local/nginx/sites-available/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /usr/local/nginx/sites-available/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBPORT/$LBPORT/g' /usr/local/nginx/sites-available/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."

# Link vhost file for each website
ssh root@$LB2IP "ln -s /usr/local/nginx/sites-available/$CASINO1.conf /usr/local/nginx/sites-enabled/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "ln -s /usr/local/nginx/sites-available/$CASINO2.conf /usr/local/nginx/sites-enabled/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "ln -s /usr/local/nginx/sites-available/$CASINO3.conf /usr/local/nginx/sites-enabled/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "ln -s /usr/local/nginx/sites-available/$CASINO4.conf /usr/local/nginx/sites-enabled/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."

# Copy over /etc/sysctl.conf
scp /opt/config/lb/sysctl.conf root@$LB2IP:/etc/sysctl.conf || error_exit "ERROR at Line $LINENO of Script."

# Load new parameter
ssh root@$LB2IP "sysctl -p" || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LB2: Memcached #####
20) print "\n#########################################################################################\nLB2: Memcached Setup\n#########################################################################################\n"

# Install the daemon
ssh root@$LB2IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install memcached" || error_exit "ERROR at Line $LINENO of Script."

# Backup memcached.conf
ssh root@$LB2IP "cp /etc/memcached.conf /etc/memcached.conf.org" || error_exit "ERROR at Line $LINENO of Script."

# Copy over memcached.conf
scp /opt/config/lb/memcached.conf root@$LB2IP:/etc/memcached.conf || error_exit "ERROR at Line $LINENO of Script."

# Update /etc/memcached.conf
ssh root@$LB2IP "sed -i 's/LBFLOAT4/$LBFLOAT4/' /etc/memcached.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/-m 64/-m 512/' /etc/memcached.conf" || error_exit "ERROR at Line $LINENO of Script."

# Copy over rc.local
scp /opt/config/lb/rc.local root@$LB2IP:/etc/rc.local || error_exit "ERROR at Line $LINENO of Script."

# Sleep for 2 seconds
sleep 2 || error_exit "ERROR at Line $LINENO of Script."

# rc.local
ssh root@$LB2IP "/etc/rc.local"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LB2: Varnish #####
21) print "\n#########################################################################################\nLB2: Varnish Setup\n#########################################################################################\n"

# Install Varnish
ssh root@$LB2IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install varnish" || error_exit "ERROR at Line $LINENO of Script."

# Backup varnish config file
ssh root@$LB2IP "cp /etc/default/varnish /etc/default/varnish.dist" || error_exit "ERROR at Line $LINENO of Script."

# Copy over varnish config
scp /opt/config/lb/varnish root@$LB2IP:/etc/default/varnish || error_exit "ERROR at Line $LINENO of Script."

# Update varnish config
ssh root@$LB2IP "sed -i 's/VARNISHPORT1/$VARNISHPORT1/g' /etc/default/varnish" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /etc/default/varnish" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/VARNISHPORT2/$VARNISHPORT2/g' /etc/default/varnish" || error_exit "ERROR at Line $LINENO of Script."

# Backup default config
ssh root@$LB2IP "cp /etc/varnish/default.vcl /etc/varnish/default.vcl.dist" || error_exit "ERROR at Line $LINENO of Script."

# Copy over default file
scp /opt/config/lb/default.vcl.lb2 root@$LB2IP:/etc/varnish/default.vcl || error_exit "ERROR at Line $LINENO of Script."

# Update default file
ssh root@$LB2IP "sed -i 's/WEB1IP/$WEB1IP/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/WEB1PORT/$WEB1PORT/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/WEB2IP/$WEB2IP/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/WEB2PORT/$WEB2PORT/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/POSTOUTIP/$POSTOUTIP/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB2IP "sed -i 's/OUTBOUNDIP/$OUTBOUNDIP/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."

# Start varnish
ssh root@$LB2IP "service varnish start" || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LOAD BALANCER 1 #####

##### LB1: HAProxy #####
22) print "\n#########################################################################################\nLB1: HAProxy Setup\n#########################################################################################\n"

# Install HA Proxy
ssh root@$LB1IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install haproxy" || error_exit "ERROR at Line $LINENO of Script."

# Make backup of the haproxy.cfg config
ssh root@$LB1IP "cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.dist" || error_exit "ERROR at Line $LINENO of Script."

# Copy over /etc/haproxy.cfg file
scp /opt/config/lb/haproxy.cfg root@$LB1IP:/etc/haproxy/haproxy.cfg || error_exit "ERROR at Line $LINENO of Script."

# Update haproxy.cfg
ssh root@$LB1IP "sed -i 's/LBMAIL1FQDN/$LBMAIL1FQDN/g' /etc/haproxy/haproxy.cfg" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBMAIL1PORT/$LBMAIL1PORT/g' /etc/haproxy/haproxy.cfg" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/DB1FQDN/$DB1FQDN/g' /etc/haproxy/haproxy.cfg" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/DB1PORT/$DB1PORT/g' /etc/haproxy/haproxy.cfg" || error_exit "ERROR at Line $LINENO of Script."

# Copy over haproxy config
scp /opt/config/lb/haproxy root@$LB1IP:/etc/default/haproxy || error_exit "ERROR at Line $LINENO of Script."

# Retart haproxy daemon
ssh root@$LB1IP "/etc/init.d/haproxy stop; /etc/init.d/haproxy start"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LB1: Heartbeat #####
23) print "\n#########################################################################################\nLB1: Heartbeat Setup\n#########################################################################################\n"

# Install heartbeat
ssh root@$LB1IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install heartbeat" || error_exit "ERROR at Line $LINENO of Script."

# Authorization keys
ssh root@$LB1IP 'echo "auth 1" >> /etc/ha.d/authkeys' || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP 'echo "1 md5 \"oieYGYgfug665443hhgfdYG6576"\" >> /etc/ha.d/authkeys' || error_exit "ERROR at Line $LINENO of Script."

# chmod authkeys file
ssh root@$LB1IP "chmod 600 /etc/ha.d/authkeys" || error_exit "ERROR at Line $LINENO of Script."

# Move over ha.cf config
scp /opt/config/lb/ha.cf.lb1 root@$LB1IP:/etc/ha.d/ha.cf || error_exit "ERROR at Line $LINENO of Script."

# Update ha.cf config
ssh root@$LB1IP "sed -i 's/LB2IP/$LB2IP/g' /etc/ha.d/ha.cf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LB1FQDN/$LB1FQDN/g' /etc/ha.d/ha.cf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LB2FQDN/$LB2FQDN/g' /etc/ha.d/ha.cf" || error_exit "ERROR at Line $LINENO of Script."

# Move over ARPing config
scp /opt/config/lb/ARPing root@$LB1IP:/etc/ha.d/resource.d/ARPing || error_exit "ERROR at Line $LINENO of Script."

# Make executable
ssh root@$LB1IP "chmod +x /etc/ha.d/resource.d/ARPing" || error_exit "ERROR at Line $LINENO of Script."

# Move over haresources
scp /opt/config/lb/haresources root@$LB1IP:/etc/ha.d/haresources || error_exit "ERROR at Line $LINENO of Script."

# Update haresources
ssh root@$LB1IP "sed -i 's/LB1FQDN/$LB1FQDN/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LB2FQDN/$LB2FQDN/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/FIREWALL1IP/$FIREWALL1IP/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBFLOAT1/$LBFLOAT1/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBFLOAT2/$LBFLOAT2/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBFLOAT3/$LBFLOAT3/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBFLOAT4/$LBFLOAT4/g' /etc/ha.d/haresources" || error_exit "ERROR at Line $LINENO of Script."

# Move over iptable rules
scp /opt/config/lb/rules.v4 root@$LB1IP:/etc/iptables/rules.v4 || error_exit "ERROR at Line $LINENO of Script."

# Save iptables
ssh root@$LB1IP "iptables-save" || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LB1: NGINX #####
24) print "\n#########################################################################################\nLB1: NGINX Setup\n#########################################################################################\n"

# Copy over nginx tar file
scp /opt/bin/nginx-1.4.3.tar.gz root@$LB1IP:/root/nginx-1.4.3.tar.gz || error_exit "ERROR at Line $LINENO of Script."

# Un-tar nginx
ssh root@$LB1IP "tar xzf /root/nginx-1.4.3.tar.gz" || error_exit "ERROR at Line $LINENO of Script."

# Install libpcre3-dev & libssl-dev
ssh root@$LB1IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install libpcre3-dev libssl-dev" || error_exit "ERROR at Line $LINENO of Script."

# Configure
ssh root@$LB1IP "cd /root/nginx-1.4.3;./configure --with-http_ssl_module" || error_exit "ERROR at Line $LINENO of Script."

# Make install
ssh root@$LB1IP "cd /root/nginx-1.4.3;make && make install" || error_exit "ERROR at Line $LINENO of Script."

# Copy over nginx and nginx.conf
scp /opt/config/lb/nginx.conf root@$LB1IP:/usr/local/nginx/conf/nginx.conf || error_exit "ERROR at Line $LINENO of Script."
scp /opt/config/lb/nginx root@$LB1IP:/etc/init.d/nginx || error_exit "ERROR at Line $LINENO of Script."

# Set permissions
ssh root@$LB1IP "chmod +x /etc/init.d/nginx" || error_exit "ERROR at Line $LINENO of Script."

# Make nginx log dir
ssh root@$LB1IP "mkdir -p /var/log/nginx" || error_exit "ERROR at Line $LINENO of Script."

# Start nginx
ssh root@$LB1IP "/etc/init.d/nginx start" || error_exit "ERROR at Line $LINENO of Script."

# Make nginx dirs
ssh root@$LB1IP "mkdir /usr/local/nginx/sites-available" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "mkdir /usr/local/nginx/sites-enabled" || error_exit "ERROR at Line $LINENO of Script."

# Copy over /usr/local/nginx/sites-available website conf files
scp /opt/config/lb/$CASINO1.conf root@$LB1IP:/usr/local/nginx/sites-available/$CASINO1.conf || error_exit "ERROR at Line $LINENO of Script."
scp /opt/config/lb/$CASINO2.conf root@$LB1IP:/usr/local/nginx/sites-available/$CASINO2.conf || error_exit "ERROR at Line $LINENO of Script."
scp /opt/config/lb/$CASINO3.conf root@$LB1IP:/usr/local/nginx/sites-available/$CASINO3.conf || error_exit "ERROR at Line $LINENO of Script."
scp /opt/config/lb/$CASINO4.conf root@$LB1IP:/usr/local/nginx/sites-available/$CASINO4.conf || error_exit "ERROR at Line $LINENO of Script."

# Update nginx conf files
ssh root@$LB1IP "sed -i 's/LBFLOAT2/$LBFLOAT2/g' /usr/local/nginx/sites-available/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBSEC2PORT/$LBSEC2PORT/g' /usr/local/nginx/sites-available/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /usr/local/nginx/sites-available/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBPORT/$LBPORT/g' /usr/local/nginx/sites-available/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."

ssh root@$LB1IP "sed -i 's/LBFLOAT1/$LBFLOAT1/g' /usr/local/nginx/sites-available/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBSEC1PORT/$LBSEC1PORT/g' /usr/local/nginx/sites-available/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /usr/local/nginx/sites-available/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBPORT/$LBPORT/g' /usr/local/nginx/sites-available/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."

ssh root@$LB1IP "sed -i 's/LBFLOAT3/$LBFLOAT3/g' /usr/local/nginx/sites-available/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBSEC3PORT/$LBSEC3PORT/g' /usr/local/nginx/sites-available/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /usr/local/nginx/sites-available/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBPORT/$LBPORT/g' /usr/local/nginx/sites-available/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."

ssh root@$LB1IP "sed -i 's/LBFLOAT4/$LBFLOAT4/g' /usr/local/nginx/sites-available/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBSEC4PORT/$LBSEC4PORT/g' /usr/local/nginx/sites-available/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /usr/local/nginx/sites-available/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBPORT/$LBPORT/g' /usr/local/nginx/sites-available/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."

# Link vhost file for each website
ssh root@$LB1IP "ln -s /usr/local/nginx/sites-available/$CASINO1.conf /usr/local/nginx/sites-enabled/$CASINO1.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "ln -s /usr/local/nginx/sites-available/$CASINO2.conf /usr/local/nginx/sites-enabled/$CASINO2.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "ln -s /usr/local/nginx/sites-available/$CASINO3.conf /usr/local/nginx/sites-enabled/$CASINO3.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "ln -s /usr/local/nginx/sites-available/$CASINO4.conf /usr/local/nginx/sites-enabled/$CASINO4.conf" || error_exit "ERROR at Line $LINENO of Script."

# Copy over /etc/sysctl.conf
scp /opt/config/lb/sysctl.conf root@$LB1IP:/etc/sysctl.conf || error_exit "ERROR at Line $LINENO of Script."

# Load new parameter
ssh root@$LB2IP "sysctl -p" || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LB1: Memcached #####
25) print "\n#########################################################################################\nLB1: Memcached Setup\n#########################################################################################\n"

# Install the daemon
ssh root@$LB1IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install memcached" || error_exit "ERROR at Line $LINENO of Script."

# Backup memcached.conf
ssh root@$LB1IP "cp /etc/memcached.conf /etc/memcached.conf.org" || error_exit "ERROR at Line $LINENO of Script."

# Copy over memcached.conf
scp /opt/config/lb/memcached.conf root@$LB1IP:/etc/memcached.conf || error_exit "ERROR at Line $LINENO of Script."

# Update /etc/memcached.conf
ssh root@$LB1IP "sed -i 's/LBFLOAT4/$LBFLOAT4/' /etc/memcached.conf" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/-m 64/-m 512/' /etc/memcached.conf" || error_exit "ERROR at Line $LINENO of Script."

# Copy over rc.local
scp /opt/config/lb/rc.local root@$LB1IP:/etc/rc.local || error_exit "ERROR at Line $LINENO of Script."

# Sleep for 2 seconds
sleep 2 || error_exit "ERROR at Line $LINENO of Script."

# rc.local
ssh root@$LB1IP "/etc/rc.local"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### LB1: Varnish #####
26) print "\n#########################################################################################\nLB1: Varnish Setup\n#########################################################################################\n"

# Install Varnish
ssh root@$LB1IP "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install varnish" || error_exit "ERROR at Line $LINENO of Script."

# Backup varnish config file
ssh root@$LB1IP "cp /etc/default/varnish /etc/default/varnish.dist" || error_exit "ERROR at Line $LINENO of Script."

# Copy over varnish config
scp /opt/config/lb/varnish root@$LB1IP:/etc/default/varnish || error_exit "ERROR at Line $LINENO of Script."

# Update varnish config
ssh root@$LB1IP "sed -i 's/VARNISHPORT1/$VARNISHPORT1/g' /etc/default/varnish" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/LBLOCALFQDN/$LBLOCALFQDN/g' /etc/default/varnish" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/VARNISHPORT2/$VARNISHPORT2/g' /etc/default/varnish" || error_exit "ERROR at Line $LINENO of Script."

# Backup default config
ssh root@$LB1IP "cp /etc/varnish/default.vcl /etc/varnish/default.vcl.dist" || error_exit "ERROR at Line $LINENO of Script."

# Copy over default file
scp /opt/config/lb/default.vcl.lb2 root@$LB1IP:/etc/varnish/default.vcl || error_exit "ERROR at Line $LINENO of Script."

# Update default file
ssh root@$LB1IP "sed -i 's/WEB1IP/$WEB1IP/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/WEB1PORT/$WEB1PORT/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/WEB2IP/$WEB2IP/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/WEB2PORT/$WEB2PORT/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/POSTOUTIP/$POSTOUTIP/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."
ssh root@$LB1IP "sed -i 's/OUTBOUNDIP/$OUTBOUNDIP/g' /etc/varnish/default.vcl" || error_exit "ERROR at Line $LINENO of Script."

# Start varnish
ssh root@$LB1IP "service varnish start" || error_exit "ERROR at Line $LINENO of Script."

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

##### WEB SERVERS #####

##### Install & Configure Apache #####
27) print "\n#########################################################################################\nInstall & Configure Apache\n#########################################################################################\n"

# Create web only hostlist
cat /root/hostlist | grep web | sed -e '/^$/,$d' | awk -F: '{print $3}' > webhostlist || error_exit "ERROR at Line $LINENO of Script."

# Backup local repo
parallel-ssh -l root -h webhostlist "cp /etc/apt/sources.list /etc/apt/sources.list.local" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install apache
parallel-ssh -l root -h webhostlist "aptitude update;DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install apache2" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Enable modules
parallel-ssh -l root -h webhostlist "cd /etc/apache2/mods-available; a2enmod rewrite; service apache2 restart; a2enmod expires" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "service apache2 restart"

# Install curl
parallel-ssh -l root -h webhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install g++" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install libcurl4-openssl-dev curl libcurl3-gnutls php5-curl" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install rpaf and enable
parallel-ssh -l root -h webhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install libapache2-mod-rpaf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Update the config file
parallel-scp -l root -h webhostlist /opt/config/apache/rpaf.conf /etc/apache2/mods-available/rpaf.conf || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "sed -i 's/LB1IP/$LB1IP/g' /etc/apache2/mods-available/rpaf.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "sed -i 's/LB2IP/$LB2IP/g' /etc/apache2/mods-available/rpaf.conf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Generate gpg keys
parallel-ssh -l root -h webhostlist "cd /etc/apache2/mods-available; gpg --keyserver keys.gnupg.net --recv-key A2098A6E" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /etc/apache2/mods-available; gpg -a --export A2098A6E | apt-key add -" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install PHP5 and other needed packages
parallel-ssh -l root -h webhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install php5 libapache2-mod-php5" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install php5-gd php5-mcrypt php5-xmlrpc php5-apc php5-dev php5-mysqlnd bzip2 libgpgme11-dev make libjpeg-progs optipng gifsicle subversion imagemagick" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install git" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install php5-memcached" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Switch to web repo for pecl
parallel-scp -l root -h webhostlist /opt/config/apache/sources.list.internet /etc/apt/sources.list || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "aptitude update" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install gnupg
parallel-ssh -l root -h webhostlist "mkdir -p /root/tmp" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h webhostlist /opt/bin/go-pear.phar /root/tmp/go-pear.phar || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/tmp; php go-pear.phar" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/tmp; pecl download gnupg" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/tmp; tar xzf gnupg-1.3.3.tgz" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install pecl & mongo
parallel-ssh -l root -h webhostlist 'printf "yes\n" | pecl install pecl_http' || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "pecl install mongo" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "/etc/init.d/apache2 restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install wkhtmltopdf
parallel-scp -l root -h webhostlist /opt/bin/wkhtmltopdf-0.9.9-static-amd64.tar.bz2 /root/wkhtmltopdf-0.9.9-static-amd64.tar.bz2 || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root; tar xjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "mv /root/wkhtmltopdf-amd64 /usr/local/bin/wkhtmltopdf" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Install oauth & ssh2
parallel-ssh -l root -h webhostlist "pecl install oauth" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "pecl install ssh2-beta" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "/etc/init.d/apache2 restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Remount /data
parallel-ssh -l root -h webhostlist "mount -o remount /data" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Capifony configuration
parallel-ssh -l root -h webhostlist "mkdir -p /data/capifony" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "usermod -d /data/capifony deploy" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "chown deploy -Rf /data/capifony" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "mkdir -p /data/capifony/CHANGEMEaccount; chown deploy:users /data/capifony/CHANGEMEaccount" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "mkdir -p /data/capifony/CHANGEMEcasino; chown deploy:users /data/capifony/CHANGEMEcasino" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "mkdir -p /data/capifony/CHANGEMEpoker; chown deploy:users /data/capifony/CHANGEMEpoker" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Set sources.list back to local repo
parallel-ssh -l root -h webhostlist "cp /etc/apt/sources.list.local /etc/apt/sources.list" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "aptitude update"

# Generate gpg keys and deploy
parallel-ssh -l root -h webhostlist "DEBIAN_FRONTEND=noninteractive aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install rng-tools" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h webhostlist /opt/config/apache/rng-tools /etc/default/rng-tools || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Set HRNGDEVICE=/dev/urandom
parallel-ssh -l root -h webhostlist "/etc/init.d/rng-tools start"
parallel-ssh -l root -h webhostlist "mkdir -p /root/.gnupg" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h webhostlist /opt/config/apache/Manifest_key_create.out /root/.gnupg/Manifest_key_create.out || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h webhostlist /opt/config/apache/SensitiveConfig_create.out /root/.gnupg/SensitiveConfig_key_create.out || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h webhostlist /opt/config/apache/prodDbCrypt_create.out /root/.gnupg/prodDbCrypt_key_create.out || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; gpg --batch --gen-key /root/.gnupg/Manifest_key_create.out" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; gpg --batch --gen-key /root/.gnupg/SensitiveConfig_key_create.out" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; gpg --batch --gen-key /root/.gnupg/prodDbCrypt_key_create.out" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Export the keys to new name
#parallel-ssh -l root -h hostnamelist -P "gpg --output /root/.gnupg/prodSoftwareManifest_private.key --export-secret-key 'CHANGEMEs (SoftwareManifest) <CISG@CHANGEMEtech.com>'"
#parallel-ssh -l root -h hostnamelist -P "gpg --output /root/.gnupg/prodSensitiveConfig_private.key --export-secret-key 'CHANGEMEs (sensitiveConfig) <CISG@CHANGEMEtech.com>'"
#parallel-ssh -l root -h hostnamelist -P "gpg --output /root/.gnupg/prodDbCrypt_private.key --export-secret-key 'CHANGEMEs (prodDbCrypt) <CISG@CHANGEMEtech.com>'"
parallel-ssh -l root -h webhostlist "chmod 755 /root/.gnupg/prodSoftwareManifest_private.key" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "chmod 755 /root/.gnupg/prodSensitiveConfig_private.key" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "chmod 755 /root/.gnupg/prodDbCrypt_private.key" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Add the keys to deploy and www-data home directories
parallel-ssh -l root -h webhostlist "chown -Rf deploy:users /root/.gnupg" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; su deploy -c 'gpg --import prodDbCrypt_private.key'" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; su deploy -c 'gpg --import prodSensitiveConfig_private.key'" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; su deploy -c 'gpg --import prodSoftwareManifest_private.key'" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; su deploy -c 'gpg --fingerprint'" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "mkdir -p /var/www/.gnupg" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "chown -Rf www-data:www-data /var/www/.gnupg" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "chown -Rf www-data:www-data /root/.gnupg" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; su www-data -c 'gpg --import prodDbCrypt_private.key'" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; su www-data -c 'gpg --import prodSensitiveConfig_private.key'" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; su www-data -c 'gpg --import prodSoftwareManifest_private.key'" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "cd /root/.gnupg; su www-data -c 'gpg --fingerprint'" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Apache logs
parallel-ssh -l root -h webhostlist "mkdir -p /home/apache/logs/web1" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-ssh -l root -h webhostlist "mkdir -p /home/apache/logs/web2" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Copy over php.ini
parallel-scp -l root -h webhostlist /opt/config/apache/php.ini /etc/php5/apache2/php.ini || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"
parallel-scp -l root -h webhostlist /opt/config/apache/php.ini.cli /etc/php5/cli/php.ini || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

# Restart apache
parallel-ssh -l root -h webhostlist "/etc/init.d/apache2 restart" || error_exit "ERROR at Line $LINENO of Script.\n$EXITCODES"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

x|X) print "\nExiting!\n"

exit ;;

*) print "\nInvalid Selection!\n"

print "\n#########################################################################################\nComplete! Hit [ENTER] for the menu....\n#########################################################################################"

read

;;

esac

done
