#!/bin/bash
# This is a helpful tool to start a Starbound server. It will daemonize,
# clean up the server's output, send output to a log file and try to restart
# the server if it shuts down.

TIME="%Y-%m-%d_%H:%M:%S"
TIMEOUT=60

SERVER_PATH="/home/lmas/starbound"
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

        cd "$SERVER_PATH/$ARCH"
        LD_LIBRARY_PATH=./ ./starbound_server | \
        while read LINE; do filter_log $LINE; done

        return "1" # simple hack, so the until loop will run...
}

function wrapper {
        # Run server and try restart it again if it stops

        until $(run_server); do
                TMP=$(date +"$TIME")
                echo "$TMP Starbound has stopped!" >> "$CRASH_LOG"

                # Test if the server should stop for good
                if [ -f "$SERVER_PATH/stop" ]; then
                        rm "$SERVER_PATH/stop"
                        exit 0
                fi

                # Let things settle down a bit before restarting
                echo "$TMP Restarting Starbound in $TIMEOUT seconds." \
                >> "$CRASH_LOG"
                sleep $TIMEOUT
        done
}

################################################################################

# daemonize
nohup $(wrapper) 0<&- &>/dev/null &
