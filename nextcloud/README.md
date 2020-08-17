armhf-alpine-nextcloud
======================
A Docker for the armhf architecture running nextcloud in 
Based on https://github.com/Wonderfall/dockerfiles/tree/master/nextcloud/10.0

Changes
=======
Based on hypriot/rpi-alpine-scratch
Added s6_overlay to get s6
Use php5 instead of php7
Removed acpu and opcache (could not get the packages installed)

Build
=====
./build.sh

Start
=====
A database is needed. For that I use my own mariadb docker (pietervandereems/armhf-alpine-mariadb)
What I do:

#create directories for the volumes
mkdir -p /mnt/nextcloud/mariadb
mkdir /mnt/nextcloud/data
mkdir /mnt/nextcloud/config
mkdir /mnt/nextcloud/apps
#create docker network to connect db and nextcloud
docker network create nc
#start mariadb container CHANGE THE PASSWORDS FROM THIS EXAMPLE (and probably the database user and databasename as well)!
docker run --network=nc --name nc-maria -e "MYSQL_ROOT_PASSWORD=CHANGE_ME" -e "MYSQL_DATABASE=change_dbname" -e "MYSQL_USER=change_username" -e "MYSQL_PASSWORD=CHANGE_ME_TOO" -v "/mnt/nextcloud/mariadb:/var/lib/mysql" pietervandereems/armhf-alpine-mariadb
#start nextcloud, not sure if the mysql password environment variables need to be set, they can be set on the nextcloud setup page as well
docker run --name nc --network=nc -p 80:8888 -e UID=1000 -e GID=1000 -v "/mnt/nextcloud/data:/data" -v "/mnt/nextcloud/config:/config" -v "/mnt/nextcloud/apps:/apps2" -e "MYSQL_ROOT_PASSWORD=CHANGE_ME" -e "MYSQL_PASSWORD=CHANGE_ME" pietervandereems/armhf-alpine-nextcloud
