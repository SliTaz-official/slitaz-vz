#!/bin/sh
# /etc/init.d/local.sh - Local startup commands.
#
# All commands here will be executed at boot time.
#
. /etc/init.d/rc.functions

#~ (°-  { Documentation dans /usr/share/doc. Utiliser 'less -EM' pour,
#~ //\    lire des fichiers, devenir root avec 'su' et éditer avec 'nano'.
#~ v_/_   Taper 'startx' pour lancer une session X. }


echo "Starting local startup commands... "

echo  "SliTaz GNU/Linux (`cat /etc/slitaz-release`)" > /etc/motd
echo >> /etc/motd
echo "(°-  { Documentation dans /usr/share/doc. Utiliser 'less -EM' pour," >> /etc/motd
echo "//\    lire des fichiers, devenir root avec 'su' et éditer avec 'nano'." >> /etc/motd
echo "v_/_   Acces au panel : http://<adresse_ip>:3000 }" >> /etc/motd
echo >> /etc/motd
echo "Kernel    : `uname -r`" >> /etc/motd
echo "hostname  : `hostname`" >> /etc/motd
echo "ip        : $(ifconfig br0 | grep inet | \
 cut -d ':' -f2 | cut -d ' ' -f1)" >> /etc/motd
echo >> /etc/motd

echo  "SliTaz GNU/Linux $(cat /etc/slitaz-release) ($(ifconfig br0 | grep inet | \
 cut -d ':' -f2 | cut -d ' ' -f1))" > /etc/issue
echo >> /etc/issue

echo " * Settings Kernel parameters" 
/sbin/sysctl -w -p /etc/sysctl.conf > /dev/null 2>&1

# Setting up owp and VZ in Live mode
if [ ! -f /var/lib/slitaz-vz ]; then
	# vzquota doesn't work in live mode ( http://labs.slitaz.org/issues/380 )
	sed -i s/DISK_QUOTA=yes/DISK_QUOTA=no/ /etc/vz/vz.conf
	
        /usr/bin/ruby /usr/share/ovz-web-panel/utils/hw-daemon/hw-daemon.rb stop > /dev/null 2>&1
                                                                                                 
        echo " * Settings hw-daemon"                                                             
        echo "address = 127.0.0.1" > /usr/share/ovz-web-panel/utils/hw-daemon/hw-daemon.ini      
        echo "port = 7767" >> /usr/share/ovz-web-panel/utils/hw-daemon/hw-daemon.ini  
		           
        export RAND_KEY=`head -c 200 /dev/urandom | md5sum | awk '{ print \$1 }'`                
        echo "key = $RAND_KEY" >> /usr/share/ovz-web-panel/utils/hw-daemon/hw-daemon.ini         
                                                                                                 
        # Add localhost in server list                                                           
        echo " * Adding localhost to the list of controlled servers..."                          
        #/usr/bin/ruby /usr/share/ovz-web-panel/script/runner -e production "HardwareServer.new(:host => 'localhost', :auth_key => '"$(echo  $RAND_KEY)"').co
        sqlite3  /usr/share/ovz-web-panel/db/production.sqlite3 "insert into hardware_servers(host,auth_key) values('localhost','"$(echo $RAND_KEY)"')"      
        /usr/bin/ruby /usr/share/ovz-web-panel/utils/hw-daemon/hw-daemon.rb start 
	
	# Create slitaz-vz will prevent this configs. 
	date > /var/lib/slitaz-vz
fi
