#!/bin/bash
# Kill, and update and restart starbound server
echo "Will kill the running server in starbound screen if any"
screen -X -S starbound kill
echo "Starbound screen and server killed"
TOOLS_PATH=/home/dimillian/starbound_tools/
STARBOUND_PATH=/home/dimillian/starbound/linux64
echo "Will check for update using steamCMD..."
cd $TOOLS_PATH
./steamcmd.sh +runscript update.txt
echo "Server updated"
cd $STARBOUND_PATH
echo "Starting Starbound server in it's own screen..."
screen -S starbound -d -m ./launch_starbound_server.sh
sleep 1
screen -d -R starbound
echo "Server started"
