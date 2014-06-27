
#!/bin/bash
#based on a script by mckinasole
 
EXPECTED_ARGS=1
E_BADARGS=65
 
 
printHelp ()
{
        echo
        echo  "\tPurpose: For fixing and unfixing your vpn connections"
        echo  "\tUsage: sudo `basename $0` [options]\n"
        echo  "\tOptions"
        echo  "\tprep\t - Run first and once!!!"
        echo  "\t\t Creates directory /etc/racoon/remote/ \n"
        echo  "\tgetcfg\t - Get vpn config."
        echo  "\t\t Repeat for each VPN connection you have."
        echo  "\t\t NOTE! This will disconnect you. \n"
        echo  "\tfix\t - Run after doing getcfg for all connections"
        echo  "\t\t Changes the config path in /etc/racoon/racoon.conf \n"
        echo  "\tunfix\t - Return to Apple original config path."
        echo  "\t\t Enables grabbing new vpn tunnel settings with getcfg.\n"
        echo  "\tunprep\t - reset everything"
        echo  "\t\t This removes --> include "/etc/racoon/remote/*.conf" from /etc/racoon/racoon.conf, "
        echo  "\t\t resets the original config path and removes all amended configs \n"
        
 
}
 
 
if [ $# -lt $EXPECTED_ARGS ]
then
printHelp
exit $E_BADARGS
fi
 
 
#################
if [ $1 = prep ]
        then
 
 
mkdir -p /etc/racoon/remote
echo "creating directory /etc/racoon/remote \n"
cp -a /etc/racoon/racoon.conf /etc/racoon/racoon.conf.orig
echo "backing up /etc/racoon/racoon.conf to /etc/racoon/racoon.conf.orig\n"
fi

#################

if [ $1 = fix ] 
        then

sed -i -e 's~include "/var/run/racoon/\*\.conf"~#include "/var/run/racoon/\*\.conf"~' /etc/racoon/racoon.conf
echo 'commenting out this line ---> include "/var/run/racoon/*.conf"'  
 
echo 'include "/etc/racoon/remote/*.conf" ;' >> /etc/racoon/racoon.conf
echo 'adding this line --> include "/etc/racoon/remote/*.conf" ;" <-- to end of /etc/racoon/racoon.conf\n'

launchctl stop com.apple.racoon
launchctl start com.apple.racoon

fi

################

if [ $1 = unfix ] 
        then

sed -i -e '/include "\/etc\/racoon\/remote\/\*\.conf" ;/d' /etc/racoon/racoon.conf
echo 'removing lines --> include "/etc/racoon/remote/*.conf" ;" <-- from /etc/racoon/racoon.conf\n'

sed -i -e 's~#include "/var/run/racoon/\*\.conf"~include "/var/run/racoon/\*\.conf"~' /etc/racoon/racoon.conf
echo 'Resetting include path to /var/run/racoon/*.conf'

launchctl stop com.apple.racoon
launchctl start com.apple.racoon

fi

#################

if [ $1 = unprep ]
        then
 
 
rm -rf /etc/racoon/remote
echo "removing directory /etc/racoon/remote \n"
 
 
sed -i -e '/include "\/etc\/racoon\/remote\/\*\.conf" ;/d' /etc/racoon/racoon.conf
echo 'removing lines --> include "/etc/racoon/remote/*.conf" ;" <-- from /etc/racoon/racoon.conf\n'

sed -i -e 's~#include "/var/run/racoon/\*\.conf"~include "/var/run/racoon/\*\.conf"~' /etc/racoon/racoon.conf
echo 'Resetting include path to /var/run/racoon/*.conf'

launchctl stop com.apple.racoon
launchctl start com.apple.racoon

fi
 
 
#################

if [ $1 = getcfg ]
        then
mv /var/run/racoon/*.conf /etc/racoon/remote/
echo 'Copying config files for active VPN connection from /var/run/racoon/'

sed -i -e 's/lifetime time 3600 sec/lifetime time 14400 sec/' /etc/racoon/remote/*.conf
echo 'Setting key lifetime to 4 hours'

sed -i -e 's/proposal_check obey;/proposal_check claim;/' /etc/racoon/remote/*.conf
echo 'Changing proposal_check from obey to claim'
 
launchctl stop com.apple.racoon
launchctl start com.apple.racoon
 
fi
 
#################
