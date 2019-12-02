#!/bin/bash
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

# ver. 11.3 updates the script to support CentOS 6.5 et al and current locations
# gvtricks 5.5.2011
# updated HylaFax and AvantFax to latest releases
# updated to support CentOS 6.5 and Scientific Linux 6.5
# Ward Mundy & Associates LLC 04-03-2014
# customized for turnkey install with Incredible PBX 11
# Joe Roper 12.02.2009
# Based on a script written by Phone User
# http://pbxinaflash.com/forum/showthread.php?t=3093
# CHANGELOG 22nd September 2010
# Fixed misnaming of tgz file
# fixed installation directory
# removed test for Incredible
# Install Fax

# Josh North 2014-08-07 josh.north@point808.com
# Based on initial CentOS IncredibleFax script from Joe Roper and subsequent mods up to 11.3
# This is customized for Ubuntu 14.04 LTS systems with a fresh install of IncrediblePBX 
# 2014-08-12 - Rewrite HylaFAX portion to install from binary repository as HylaFAX+ build
# is not going to plan.  Fixed some other bugs.
# Added steps to install a custom FreePBX/AvantFAX link module that I wrote so that users can easily access AvantFAX ui

# Version control test - check and see if this is actually incrediblepbx 11.11, if not, exit
VERSION=`cat /etc/pbx/.version`
if [ -z "$VERSION" ]
then
 echo "Sorry. This installer requires Ubuntu PBX in a Flash and Incredible PBX 11.11."
fi
if [ "$VERSION" != "11.11" ]
then
 echo "Sorry. This installer requires Ubuntu PBX in a Flash and Incredible PBX 11.11."
fi

clear
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "This script installs Hylafax/Avantfax/IAXmodem on Ubuntu PIAF systems only!"
echo " "
echo "You first will need to enter the email address for delivery of incoming faxes." 
echo " "
echo "Thereafter, accept ALL the defaults except for entering your local area code. "
echo " "
echo "NEVER RUN THIS SCRIPT MORE THAN ONCE ON THE SAME SYSTEM!!!"
echo " "
echo "For the best chance of success, ensure you have fully updated your system with"
echo "apt-get update && apt-get upgrade -y BEFORE running this script. If you have "
echo "not yet done this, press crtl-C NOW to exit!!!"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
read -p "Press any key to continue or ctrl-C to exit"

clear
echo -n "Enter EMAIL address for delivery of incoming faxes: "
read faxemail
echo "FAX EMail Address: $faxemail"
read -p "If this is correct, press any key to continue or ctrl-C to exit"
clear

#Change passw0rd below for your MySQL asteriskuser password if you have changed it from the default.
MYSQLASTERISKUSERPASSWORD=amp109

#Set working directory for building
LOAD_LOC=/usr/src/

#Make a somewhat random password for the iaxmodems and put it in a temporary variable for use later
IAXPWD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c10`

# Upgrade all installed packages first
#apt-get update && apt-get upgrade -y
# REMOVED above upgrade line - this is a bad idea because now we don;t know what versions people have installed
# HOWEVER - leaving this line currently breaks working installations, and we can;t have that.
# FUTURE - I think we may have to go the source-installation route for production stability.  Depending on untested
# packages is great for bleeding-edge but isn't going to cut it for serious consideration as a stable build.
apt-get update

# Install all needed packages (all available at least) in one shot now.  I could split it up by section
# but why not knock it all out to save time.
apt-get install -y mgetty mgetty-voice hylafax-server iaxmodem ghostscript gsfonts hylafax-client libgs9 libgs9-common libnetpbm10 libpaper-utils libpaper1 libtiff-tools netpbm transfig php-mail-mime php-net-socket php-auth-sasl php-net-smtp php-mail php-mdb2 php-mdb2-driver-mysql tesseract-ocr imagemagick

# Create some directories and files for later use
touch /var/log/iaxmodem/iaxmodem.log

# PEAR has a NASTY bug or something where the upgrader won't recognize .tgz files.  So, we run upgrade
# to download the files, rename them, and then install manually until they get their act together.
# Bug track https://bugs.launchpad.net/ubuntu/+source/php5/+bug/1310552
#pear upgrade
#gunzip /build/buildd/php5-5.5.9+dfsg/pear-build-download/*.tgz
#pear upgrade /build/buildd/php5-5.5.9+dfsg/pear-build-download/*.tar

# Get ready to build!
cd $LOAD_LOC

# LOOP and install 4 IAXMODEMS 0->3
cd $LOAD_LOC
COUNT=0
while [ $COUNT -lt 4 ]; do
       echo "Number = $COUNT"
       touch /etc/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT
	touch /var/log/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT
# For each device, set up the IAX config file
       echo "
device /dev/ttyIAX$COUNT
owner uucp:uucp
mode 660
port 457$COUNT
refresh 300
server 127.0.0.1
peername iax-fax$COUNT
secret $IAXPWD
cidname Incredible PBX
cidnumber +0000000000$COUNT
codec ulaw
" > /etc/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT
# For each device, set up the Asterisk config file
echo "
[iax-fax$COUNT]
type=friend
host=dynamic
port=457$COUNT
context=from-fax
secret=$IAXPWD
requirecalltoken=no
disallow=all
allow=ulaw
jitterbuffer=no
qualify=yes
deny=0.0.0.0/0.0.0.0
permit=127.0.0.1/255.255.255.0
" >> /etc/asterisk/iax_custom.conf
# For each device, set up the HylaFAX config file
cp /usr/share/doc/iaxmodem/examples/config.ttyIAX /var/spool/hylafax/etc/config.ttyIAX$COUNT
# For each device, set up to start faxgetty and log on boot
echo "
t$COUNT:23:respawn:/usr/local/sbin/faxgetty ttyIAX$COUNT > /var/log/iaxmodem/iaxmodem.log
" >> /etc/inittab
# For each device, set permissions on HylaFAX config
chown uucp:uucp /var/spool/hylafax/etc/config.ttyIAX$COUNT
#End of the loop stuff
COUNT=$((COUNT + 1))
done
# LOOP END

# Set up FaxDispatch.  Can't add to loop without convoluted sed awk crap that is over my head.  No big deal.
echo "
case "$DEVICE" in
   ttyIAX0) SENDTO=your@email.address; FILETYPE=pdf;; # all faxes received on ttyIAX0
   ttyIAX1) SENDTO=your@email.address; FILETYPE=pdf;; # all faxes received on ttyIAX1
   ttyIAX2) SENDTO=your@email.address; FILETYPE=pdf;; # all faxes received on ttyIAX2
   ttyIAX3) SENDTO=your@email.address; FILETYPE=pdf;; # all faxes received on ttyIAX3
esac
" > /var/spool/hylafax/etc/FaxDispatch

# Set up Dial Plan.  Again, we could probably loop but too much hassle for now.
echo "
[custom-fax-iaxmodem]
exten => s,1,Answer
exten => s,n,Wait(1)
exten => s,n,SendDTMF(1)
exten => s,n,Dial(IAX2/iax-fax0/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax1/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax2/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax3/\${EXTEN})
exten => s,n,Busy
exten => s,n,Hangup
" >> /etc/asterisk/extensions_custom.conf

# Set up custom destination for fax in Asterisk and reload
RESULT=`/usr/bin/mysql -uasteriskuser -p$MYSQLASTERISKUSERPASSWORD <<SQL
use asterisk
INSERT INTO custom_destinations 
	(custom_dest, description, notes)
	VALUES ('custom-fax-iaxmodem,s,1', 'Fax (Hylafax)', '');
quit
SQL`
asterisk -rx "module reload"

# Notify user that they will have to manually input data in a moment!
clear
echo "ATTN: We now are going to run the Hylafax setup script."
echo "Except for your default area code which must be specified,"
echo "you can safely accept every default by pressing Enter."
read -p "Press the Enter key to begin..."
clear

# Cross your fingers and run HylaFAX faxsetup.  It will require user input for the area code, all other can be left default with enter.
faxsetup

# Get ready to install AvantFAX
mysql -uroot -ppassw0rd asterisk -e "DROP DATABASE avantfax"
cd $LOAD_LOC
wget http://incrediblepbx.com/avantfax-3.3.3.tgz
tar zxfv $LOAD_LOC/avantfax*.tgz
cd avantfax-3.3.3

# We need to set some preferences first and fix a package name error in their install script.
sed -i 's/ROOTMYSQLPWD=/ROOTMYSQLPWD=passw0rd/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's/www-data/asterisk/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's/fax.mydomain.com/pbx.local/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's/INSTDIR=\/var\/www\/avantfax/INSTDIR=\/var\/www\/html\/avantfax/g'  $LOAD_LOC/avantfax-3.3.3/debian-prefs.txt
sed -i 's|./debian-prefs.txt|/usr/src/avantfax-3.3.3/debian-prefs.txt|g'  $LOAD_LOC/avantfax-3.3.3/debian-install.sh
sed -i 's/apache2.2-common/apache2-data/g'  $LOAD_LOC/avantfax-3.3.3/debian-install.sh

# This will need future work to narrow the sed regex.  We have to change their file to get the correct field name for the IAX modem config files.  If they fix it, our script will break!
sed -i 's/6/4/g'  $LOAD_LOC/avantfax-3.3.3/debian-install.sh

# Run AvantFAX installation now that we cleaned up what we can
./debian-install.sh

# Cleanup unneccesary AvantFAX apache config and cleanup by restarting Apache and Asterisk
rm /etc/apache2/sites-enabled/000-default
service apache2 restart
asterisk -rx "module reload"

# Set email address for admin user in AvantFAX
mysql -uroot -ppassw0rd avantfax <<EOF
use avantfax;
update UserAccount set username="admin" where uid=1;
update UserAccount set can_del=1 where uid=1;
update UserAccount set wasreset=1 where uid=1;
update UserAccount set acc_enabled=1 where uid=1;
update UserAccount set email="$faxemail" where uid=1;
update Modems set contact="$faxemail" where devid>0;
EOF

# Set up custom extension for fax in Asterisk and reload
echo "
[from-fax]
exten => _x.,1,Dial(local/\${EXTEN}@from-internal)
exten => _x.,n,Hangup
" >> /etc/asterisk/extensions_custom.conf
sed -i 's|NVfaxdetect(5)|Goto(custom-fax-iaxmodem,s,1)|g' /etc/asterisk/extensions_custom.conf
asterisk -rx "dialplan reload"

# We need to tweak the HylaFAX modem configs for permissions, name, and some other variables.  Needs work - put into a loop to save time and code.
# BUT remember, this must run AFTER faxsetup command so it will have to be a second loop!!!
echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX0
sed -i "s/IAXmodem/IncredibleFax/g" /var/spool/hylafax/etc/config.ttyIAX0
sed -i "s/0600/0777/g" /var/spool/hylafax/etc/config.ttyIAX0
echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX1
sed -i "s/IAXmodem/IncredibleFax/g" /var/spool/hylafax/etc/config.ttyIAX1
sed -i "s/0600/0777/g" /var/spool/hylafax/etc/config.ttyIAX1
echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX2
sed -i "s/IAXmodem/IncredibleFax/g" /var/spool/hylafax/etc/config.ttyIAX2
sed -i "s/0600/0777/g" /var/spool/hylafax/etc/config.ttyIAX2
echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX3
sed -i "s/IAXmodem/IncredibleFax/g" /var/spool/hylafax/etc/config.ttyIAX3
sed -i "s/0600/0777/g" /var/spool/hylafax/etc/config.ttyIAX3

# AvantFAX has some directives that we want to modify, pagesize and email address.
sed -i "s/a4/letter/" /var/www/html/avantfax/includes/local_config.php
sed -i "s/root@localhost/$faxemail/" /var/www/html/avantfax/includes/local_config.php
sed -i "s/root@localhost/$faxemail/" /var/www/html/avantfax/includes/config.php

# AvantFAX distributes a cron file that is missing the root user directive.  Let's fix it now.
sed -i 's/\/var\/www\/html\/avantfax/root\ \/var\/www\/html\/avantfax/g' /etc/cron.d/avantfax

# AvantFAX throws a crapload of PHP errors.  Fix what we can here and hush the rest.  Will need future work.
sed -i 's/PEAR/@PEAR/g' /var/www/html/avantfax/includes/SQL.php
sed -i 's/PEAR/@PEAR/g' /var/www/html/avantfax/includes/MDBO.php
sed -i 's/db\ =\&\ MDB2/db\ =\ MDB2/g' /var/www/html/avantfax/includes/SQL.php
sed -i 's/result\ =\&\ /result\ =\ /g' /var/www/html/avantfax/includes/SQL.php
sed -i 's/res\ =\&\ /res\ =\ /g' /var/www/html/avantfax/includes/SQL.php
sed -i 's/aff\ =\&\ /aff\ =\ /g' /var/www/html/avantfax/includes/SQL.php

# AvantFAX has some hardcoded paths in it's setup script.  For now it is easier to hard-code the paths since we have a relatively stable build environment.  Will need future work.
sed -i "s/\$HYLAFAX_PREFIX.DIRECTORY_SEPARATOR.\x27sbin\x27.DIRECTORY_SEPARATOR.\x27/\x27/g" /var/www/html/avantfax/includes/config.php
sed -i "s/\$HYLAFAX_PREFIX.DIRECTORY_SEPARATOR.\x27bin\x27.DIRECTORY_SEPARATOR.\x27/\x27/g" /var/www/html/avantfax/includes/config.php
sed -i 's/\/usr\/local\/bin\/tesseract/\/usr\/bin\/tesseract/g' /var/www/html/avantfax/includes/local_config.php
sed -i 's/TIFF_TO_G4\t\t\t=\ false/TIFF_TO_G4\t\t\t=\ true/g' /var/www/html/avantfax/includes/local_config.php

# Tie up some loose ends with permissions and copy some other default HylaFAX config files
chown uucp:uucp /var/spool/hylafax/etc/FaxDispatch
chown -R asterisk:uucp /var/www/html/avantfax/tmp /var/www/html/avantfax/faxes
chmod -R 777 /var/spool/hylafax/recvq/
chmod -R 777 /var/www/html/avantfax
chown -R asterisk:asterisk /var/www/html/avantfax
chmod -R 0777 /var/www/html/avantfax/tmp /var/www/html/avantfax/faxes
chown -R asterisk:uucp /var/www/html/avantfax/tmp /var/www/html/avantfax/faxes
chmod 1777 /tmp
chmod 555 /
chown -R uucp:uucp /etc/iaxmodem/

# Required to start faxgetty for modems on startup.  Need to "Ubuntu-ize" it to use Upstart in the future.  Also look at putting it in a loop with other items.
sed -i '$i/usr/local/sbin/faxgetty -D ttyIAX0' /etc/rc.local
sed -i '$i/usr/local/sbin/faxgetty -D ttyIAX1' /etc/rc.local
sed -i '$i/usr/local/sbin/faxgetty -D ttyIAX2' /etc/rc.local
sed -i '$i/usr/local/sbin/faxgetty -D ttyIAX3' /etc/rc.local

# We want to use AvantFAX programs instead of built-in HylaFAX programs
rm /var/spool/hylafax/bin/faxrcvd*
rm /var/spool/hylafax/bin/notify*
rm /var/spool/hylafax/bin/dynconf*
ln -s /var/www/html/avantfax/includes/faxrcvd.php /var/spool/hylafax/bin/faxrcvd.php
ln -s /var/www/html/avantfax/includes/notify.php /var/spool/hylafax/bin/notify.php
ln -s /var/www/html/avantfax/includes/dynconf.php /var/spool/hylafax/bin/dynconf.php
rm /usr/share/misc/magic
rm /usr/share/misc/magic.mgc
ln -s /usr/share/file/magic* /usr/share/misc/

# This is in the old CentOS script.  I don't know what it is doing, for now I just put it here (instead of sysctl).
cd /etc/default
wget http://incrediblepbx.com/hylafax+
chmod 755 hylafax+

# Download the WebMin module for HylaFAX and install CGI.  User will have to manually install module themselves as noted in final notice
cd $LOAD_LOC
wget http://incrediblepbx.com/hylafax_mod-1.8.2.wbm.gz
perl -MCPAN -e 'install CGI'

# Download and install git so that we can clone the FreePBX module for the AvantFAX link.  Maybe later FreePBX or someone
# will modify and include the module or make a generic web link module but for now this was fastest/easiest
apt-get install -y git
cd /var/www/html/admin/modules
git clone https://github.com/joshnorth/FreePBX-AvantFAX avantfax
chown -R asterisk:asterisk avantfax
amportal a ma install avantfax
amportal a r

# Download the AvantFAX password change script
cd /root
wget --no-check-certificate https://raw.githubusercontent.com/joshnorth/UbuntuPIAF/master/avantfax-pw-change
chmod +x avantfax-pw-change

# clean up the pear problem for FreePBX
pear uninstall db
pear channel-update pear.php.net
pear install -Z db-1.7.14

ln -s /usr/sbin/faxgetty /usr/local/sbin/faxgetty

# patch for duplicate startup
sed -i 's|/usr/local/sbin/faxgetty|#/usr/local/sbin/faxgetty|' /etc/rc.local

# All done - notify user to reboot and exit!
cd /root
clear
echo " "
echo " "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Incredible FAX with IAXModem/Hylafax/Avantfax installation complete"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " "
echo "Avantfax is password-protected. Log in as admin with password \"password\" using"
echo "a browser pointed to http://serverIPaddress/avantfax or use the PIAF Admin GUI."
echo " "
echo "Fax detection is NOT supported. Incoming fax support requires a dedicated DID! "
echo "See this post if you have trouble sending faxes: http://nerd.bz/10MecwG"
echo " "
echo "Point a DID at the Custom Destination FAX (Hylafax) which has been created for"
echo "you in FreePBX. Outbound faxing will go out via the normal trunks as configured."
echo "You may also route a fax DID to extension 329 (F-A-X) to receive inbound faxes."
echo " "
echo "A Hylafax webmin module has been placed in /usr/src/hylafax_mod-1.8.2.wbm.gz"
echo "This is added via Webmin | Webmin Configuration | Webmin Modules | From Local File"
echo " "
echo "For a complete tutorial and video demo, visit: http://nerdvittles.com/?p=738"
echo " "
echo "You must Reboot now to bring Incredible Fax online."
echo " "
read -p "Press any key to reboot or ctrl-C to exit"
reboot

