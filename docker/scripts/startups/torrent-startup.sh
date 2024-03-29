#!/bin/bash

# ===========================
# Author: Andrew J. McDonald
# Date: 2023-03-22
## =====================================================================
## DOCKER CONTAINER WAIT FOR NETWORK/MOUNT POINT START SCRIPT
##
## Description:
## This script is used to check for the availability of a mapped drive
## and network connection before starting docker container.
##
## The script will run until either the drive and network are available,
## at which point it will start the container, or the loop limit is
## reached.
##
## The drive and network availability is determined by the stat command
## and ping command, respectively.
##
## The script will also check if the container is already running and
## exit the loop if it is.
## =====================================================================

script_name="TORRENT STARTUP"

# set mount point and testfile
drive_mount=/data/torrents/
drive_mount_testfile=/data/torrents/testfile

# set container name
container=rutorrent #deluge qbittorrent

# Set network test option and ping address
check_network=true
network_address=8.8.8.8

# Set max loop iterations and wait time (60x10secs=~10mins)
# Set to 0 to disable the loop limit.
loop_limit=60
wait_time=10

mounted=false
networked=false
loop_count=0

while true; do
    (( loop_count++ ))
    
    # Check for the availability of the mapped drive
    if [[ "$mounted" == "false" ]]; then
        stat $drive_mount_testfile &> /dev/null
        if [[ $? -eq 0 ]]; then
            echo $(date '+%y-%m-%d %T')" ["$script_name"]: "$drive_mount" is available!"
            mounted=true
        fi
    fi

    # Check the network status
    if [[ "$check_network" == "true" ]]; then
        if [[ "$networked" == "false" ]]; then
            ping -q -c 1 -W 5 $network_address >/dev/null
            if [[ $? -eq 0 ]]; then
                echo $(date '+%y-%m-%d %T')" ["$script_name"]: Network is up!"
                networked=true
            fi
        fi
    else
        networked=true
        check_network=false
    fi

    # Check if the container is running and exit if true
    if [[ $(docker inspect --format='{{.State.Running}}' $container) == "true" ]]; then
        echo $(date '+%y-%m-%d %T')" ["$script_name"]: "$container" is up!"
        break
    fi

    if [[ "$mounted" == "true" && "$networked" == "true" ]]; then
        # Start the container
        echo $(date '+%y-%m-%d %T')" ["$script_name"]: Starting "$container"..."
        docker start $container > /dev/null 2>&1
    fi
    
    # exit if more than 10mins elapsed and some/all containers won't start
    if [[ $loop_limit -ne 0 && $loop_count -gt $loop_limit ]]; then
        echo -n $(date +"%y-%m-%d %T")" ["$script_name"]: Exiting after hitting loop limit..."
		echo -n "mounted="$mounted
		echo -n ",networked="$networked
		echo ",$container="$(docker inspect --format='{{.State.Running}}' $container)
        break
    fi

    sleep $wait_time
done
