#!/bin/bash
# This is a helpful tool to start a Starbound server. It will daemonize,
# clean up the server's output, send output to a log file and try to restart
# the server if it shuts down.
#
# LICENSE
# MIT License, see the file:
# https://github.com/lmas/starbound_server/blob/master/LICENSE
################################################################################

TIME="%Y-%m-%d_%H:%M:%S"
TIMEOUT=60

SERVER_PATH="/starbound"
ARCH="linux64"
LOG_FILE="$SERVER_PATH/server.log"
CRASH_LOG="$SERVER_PATH/crash.log"

################################################################################

set -e # stop immediately on errors

function filter_log {
        # "Prettify" the server's spammy output..

        echo "$LINE" | grep "Info:" | \
        awk -v time="$(date +"$TIME")" '{$1=""; print time, $0}' \
        >> "$LOG_FILE"
}

function run_server {
        # Obviously runs the starbound server

        echo "$(date +"$TIME") Now starting Starbound..." >> "$LOG_FILE"

        cd "$SERVER_PATH/$ARCH"
        LD_LIBRARY_PATH=./ ./starbound_server | \
        while read LINE; do filter_log $LINE; done

        echo "$(date +"$TIME") Starbound has stopped!" >> "$LOG_FILE"
        echo "------------------------------" >> "$LOG_FILE"
        return "1" # simple hack, so the until loop will run...
}

function wrapper {
        # Run server and try restart it again if it stops

        until $(run_server); do
                # Test if the server should stop for good
                if [ -f "$SERVER_PATH/stop" ]; then
                        rm "$SERVER_PATH/stop"
                        exit 0
                fi

                echo "$(date +"$TIME") Starbound stopped, restarting in $TIMEOUT seconds." \
                >> "$CRASH_LOG"

                # Let things settle down a bit before restarting
                sleep $TIMEOUT
        done
}

################################################################################

# daemonize
nohup $(wrapper) 0<&- &>/dev/null &
