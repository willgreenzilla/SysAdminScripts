# SysAdminScripts
This is a small collection of random system admin scripts that I've written. Many are pretty specific to what I use them for in the environment that I work in (AIX). Many of these had been quickly tossed together, used, and mostly ugly and forgotten.

1) avupdate.ksh - A wrapper script to update McAfee Virus Signatures on all AIX servers from a central server utilizing DSH.
2) checkexpire.ksh - A script to check when a list of newline seperated AIX accounts will expire and display the date in friendly human readable format.
3) deploy.ksh - An ugly deployment script to install and configure a number of Debian Linux servers based on an input file containing server specific details such as IP/hostname/etc, santizied configuration files (that are deployed to the servers and then configured after apps are installed), etc. Utilizes parallel-ssh. This is an old version of the script and contains test code for troubleshooting as I built the script. I have not touched this script in years. This script was built to deploy small 13 server casino servers in various locations quickly. The script performs the following actions and the on-site technicial clones x amount of base servers from a gold image to setup the initial Debian servers and configure networking. The script performs the following once the base environment is up (executed from the chosen management server of the server "cluster"):
   * Takes input from a hostlist file and sets various variables.
   * Offers testing/installation/configuration selection menu.
   * Performs network checks to verify all servers are reachable.
   * Generates root SSH keys and pushes to servers and pulls keys back to the management server.
   * Exchange keys with the remote repo.
   * Rsync remote repo files down to local mgmt server.
   * Verify parallel-ssh functioning and keys are good.
   * Update resolv.conf and hosts files on servers.
   * Create local repo on mgmt server and updates sources list on all servers to communicate with this local repo.
   * Setup and configure ldap on the mgmt and host servers.
   * Install and configure vsftpd.
   * Install and configure phpmyadmin.
   * Install and configure backuppc.
   * Install and configure NTP.
   * Install and configure MySQL.
   * Configure MySQL backups.
   * Install and configure HAPROXY load balancing.
   * Install and configure heartbeat.
   * Install and configure NGINX.
   * Install and condfigure memcached.
   * Install and configure Varnish.
   * Install and configure the web servers (Apache).
   * Etc..
4) get-info.ksh - Script to gather server details from a list of AIX servers and generate a report that is easy to import into Microsoft Excel. Data gathered includes: Hostname, FQDN, Operating System, Memory, Virtual CPUs, Active Physical CPUs, Environment (Prod/Test/Dev), IP address, MAC address, and mounted filesystems.
5) gogo.ksh - Script to make performing system admin functions easier on a collection of servers (which are set within environmental text files with newline seperated list of servers for each environment) from a central managament server using DSH in an AIX environment without LDAP. Functions that the script performs include:
   * Act on various environment group of servers (such as DEV/TEST/PROD) as well as a list of user input servers.
   * Display selected servers to be acted on.
   * Check status of servers.
   * Display filesystems equal to or over 90% capacity.
   * Change account passwords to a default password or set to a specific password.
   * Lock and unlock accounts.
   * Create and delete accounts.
   * Send files to collection of servers.
   * Locate accounts and what servers they reside on.
6) keypush.ksh - Simple script to push SSH keys out to a list of servers.
7) pingcast.ksh - Simple script to check status of a list of servers (if ICMP packets are blocked this won't work of course).
8) pwgen.ksh - Simple script to generate x amount of random passwords initially aimed for sets of 3 random passwords per row for 3 environments for the same application accounts in each environment.
9) setpass.ksh - Built to change a large collection of account passwords on a large number of servers quickly. Very specific for my own use.
10) VerifyPasswords.ksh - Simple tool to check that newly generated passwords meet various security requirements. Currently setup to verify against the following: 8 or less shared characters between the new password and the previous password, at least 1 digit, at least 4 letters, and at least 0 special characters. I tossed this script together quickly to solve a specific problem/need at work.

