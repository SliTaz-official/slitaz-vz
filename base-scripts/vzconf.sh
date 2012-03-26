#!/bin/sh
# Set network bridge for OpenVZ server
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#
#  20011 - Eric Joseph-Alexandre <erjo@slitaz.org>


CONFIG_DIR=/var/lib/slitaz-vz

# Get real network device name from stored config if exists. 
if [ -f $CONFIG_DIR/network/interfaces ]; then
	BRIDGE=$(grep ^BRIDGE $CONFIG_DIR/network/interfaces | sed 's/.*"\(.*\)"/\1/')
	IFACE=$(grep ^INTERFACE $CONFIG_DIR/network/interfaces | sed 's/.*"\(.*\)"/\1/')
else
	BRIDGE=br0
	IFACE=$(grep ^INTERFACE /etc/network.conf | sed 's/.*"\(.*\)"/\1/')
	
	# Store interface info for the next boot in hd mode
	mkdir -p $CONFIG_DIR/network
	echo "BRIDGE=\"$BRIDGE\"" > $CONFIG_DIR/network/interfaces
	echo "INTERFACE=\"$IFACE\"" >> $CONFIG_DIR/network/interfaces
fi

# Set Bridge configuration
if [ -x /usr/sbin/brctl ]; then
	if (/usr/sbin/brctl addbr $BRIDGE); then
		/sbin/ifconfig $IFACE down
		/sbin/ifconfig $IFACE 0
		/usr/sbin/brctl addif $BRIDGE $IFACE
		
		# Update INTERFACE in /etc/network.conf
		grep ^INTERFACE /etc/network.conf | grep -q $BRIDGE \
			|| sed -i "s/^INTERFACE=\"\(.*\)\"/INTERFACE=\"$BRIDGE\"/" /etc/network.conf
	else
		echo "Unable to set netwok bridge"
	fi
else
	echo "Can't find brctl. Make sure you have installed brctl-utils"
fi
