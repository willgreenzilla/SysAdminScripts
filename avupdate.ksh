#!/bin/ksh

####################################################################################################
##### avupdate.ksh                                                                            ######
##### v1.0 - 4/04/201                                                                         ######
##### will green                                                                              ######
####################################################################################################
##### Simple script wrapper to simplify updating AV on AIX servers via 1 command              ######
##### Be sure to run script in same dir as latest av tar file and that designated             ######
##### hostlist file has an up to date list of AIX servers to be updated                       ######
#####                                                                                         ######
##### Use example: ./avupdate.ksh 7389 allhosts 50                                            ######
####################################################################################################

# Take user input
VERSION=$1
HOSTLIST=$2
FAN=$3

# Configure DSH variables
export DSH_NODE_LIST="$HOSTLIST"
export DSH_NODE_RSH=/usr/bin/ssh
export DSH_NODE_OPTS="-q -o BatchMode=yes"
export DCP_NODE_RCP=/usr/bin/scp
export DSH_FANOUT=$FAN

# Check input
if [ "$#" -ne 3 ]
then
	print "\nScript format should be: ./avupdate.ksh VERSION HOSTLIST NUMBEROFPARALLELS\n\nExample: ./avupdate.ksh 7395 allhosts 40\n"
	exit 1
else
	# Set variables
	NAME="avvdat-$VERSION.tar"
	FULLPATH="`pwd`/$NAME"
	COMMALIST=`tr '\n' ',' < $HOSTLIST | sed 's/.$//'`

	# Run prepare_dat.sh on nim server
	print "\nRunning prepare_dat.sh locally...\n"
	sudo LDR_CNTRL=MAXDATA=0x30000000@DSA /usr/local/scripts/prepare_dat.sh $VERSION

	# Run update_av.sh on nim server
	print "\nRunning update_av.sh locally...\n"
	LDR_CNTRL=MAXDATA=0x30000000@DSA /usr/local/scripts/update_av.sh $FULLPATH

	# Push out av updates to all servers listed in hostlist
	print "\nPushing $NAME out to: $COMMALIST\n"
	dcp -Q $NAME ~/$NAME 2>/dev/null

	# Run update_av.sh on all other servers in the hostlist
	print "\nRunning update_av.sh on: $COMMALIST\n"
	dsh "LDR_CNTRL=MAXDATA=0x30000000@DSA /usr/local/scripts/update_av.sh ~/$NAME" 2>/dev/null

	# Remove av data file
	print "\nRemoving $NAME from: $COMMALIST\n"
	dsh -Q "rm ~/$NAME" 2>/dev/null

	# Verify version is correct on all servers and report back
	print "\nChecking AV version on: $COMMALIST\n"
	dsh 'LDR_CNTRL=MAXDATA=0x30000000@DSA uvscan --version | grep "Dat set version:"' 2>/dev/null

	# Delete local copy of av update file
	print "\nRemoving local copy of $NAME\n"
	rm $NAME 2>/dev/null

	# Exit
	print "\nFINISHED!\n"
fi
exit 0
