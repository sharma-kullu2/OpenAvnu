#!/bin/bash
# Start all daemons

if [ "$1" == "-h" ]; then
    echo "Usage: $0 <network interface>"
    echo "   eg: $0 eth1"
    echo ""
    echo "If you are using IGB, call \"sudo ./run_igb.sh\" before running this script."
    echo ""
    exit
fi

if [ "$1" == "" ]; then
    echo "Please enter network interface name as parameter. For example:"
    echo "sudo $0 eth1"
    echo ""
    echo "If you are using IGB, call \"sudo ./run_igb.sh\" before running this script."
    echo ""
    exit -1
fi

nic=$1

if [ "$2" == "-d" ]; then
    set -x  # Enable debugging
    log_file="script.log"
    echo "Starting script at $(date)" >> "$log_file"
else
    log_file="/dev/null"  # Redirect logs to /dev/null if not debugging
fi

# Function to log messages conditionally
log() {
    if [ "$2" == "-d" ]; then
        echo "$1" >> "$log_file"
    fi
}

log "Starting daemons on $nic" "$2"

# Check and recreate PTP group
if getent group ptp > /dev/null 2>&1; then
    log "PTP group already exists. Removing..." "$2"
    groupdel ptp >> "$log_file" 2>&1
    if [ $? -ne 0 ]; then
        log "Error: Failed to remove existing 'ptp' group" "$2"
        exit 1
    fi
fi

log "Creating new PTP group..." "$2"
groupadd ptp >> "$log_file" 2>&1
if [ $? -ne 0 ]; then
    log "Error: Failed to create 'ptp' group" "$2"
    exit 1
fi

# Function to run commands in the background
run_with_log() {
    local cmd="$1"
    log "Running: $cmd" "$2"
    eval "$cmd" >> "$log_file" 2>&1 &
    local pid=$!
    log "Started background process: PID=$pid, Command=$cmd" "$2"
}

# Run daemons in the background
#run_with_log "daemons/gptp/gptp $nic"
run_with_log "daemons/mrpd/mrpd -mvsd -i $nic"
run_with_log "daemons/maap/linux/build/maap_daemon -i $nic -d /dev/null"
run_with_log "daemons/shaper/shaper_daemon -d"

# Wait for all background processes to finish (optional)
if [ "$2" == "-d" ]; then
  wait
  log "All background processes have completed." "$2"
  log "Script finished at $(date)" "$2"
fi