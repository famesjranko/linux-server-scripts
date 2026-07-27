###################################################################################
## This script creates a backup to usb, with a record of all installed packages  ##
## and essential directories from server.                                    ##
##                                                                               ##
## Docker containers are stopped before backup begins to help prevent file       ##
## corruption, and are restarted on completion.                                  ##
##                                                                               ##
## All directories are backed up, except those excluded below.                   ##
##                                                                               ##
###################################################################################

#!/bin/bash

# NOTE: public template. Review /mnt/backup_usb, /srv/media, exclusions, and Docker
# behavior before use. This stops all Docker containers.

echo "== running backup script =="

## collect a list of installed packages
##
echo
echo "== getting installed package list =="

dpkg --get-selections > /mnt/backup_usb/server_install-list.txt

## stop containers
##
echo
echo "== stopping docker containers =="

docker stop $(docker ps -a -q)

## run rsync backup command
##
echo
echo "== running rsync backup =="
sleep 3

sudo rsync -aAXHS --info=progress2 --numeric-ids --one-file-system --delete  \
--exclude=/dev/ \
--exclude=/proc/ \
--exclude=/sys/ \
--exclude=/tmp/ \
--exclude=/run/ \
--exclude=/mnt/ \
--exclude=/media/ \
--exclude=/data/ \
--exclude=/swapfile \
--exclude=/lost+found \
--exclude=/srv/media/.cache \
--exclude=/srv/media/downloads/ \
--exclude=/srv/media/torrents/downloads/ \
--exclude=/srv/media/torrents/incomplete/ \
--exclude=/srv/media/torrents/watch/ \
--exclude=/srv/media/torrents/backup/ \
--exclude=/docker/ \
--exclude=/var/cache/ \
--exclude=/var/lib/containerd/ \
--exclude=/var/lib/docker-engine/ \
--exclude=/var/lib/docker/ \
--exclude=/var/log/ \
--exclude=/var/run/ \
--exclude=/var/spool/ \
--exclude=/var/tmp/ \
/ /mnt/backup_usb/server/

## restart containers
##
echo
echo "== restarting docker containers =="
sleep 3

docker start $(docker ps -a -q -f status=exited)

## exit
##
echo
echo "== backup test complete =="

exit 0
