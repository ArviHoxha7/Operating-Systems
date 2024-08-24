#!/bin/bash

# Check if the syslog file exists
syslog_file="/var/log/syslog"
if [ ! -f "$syslog_file" ]; then
    echo "Syslog file not found at $syslog_file"
    exit 1
fi

# Process the syslog file to count events per day
echo "Events per day in syslog:"
awk '{print $1, $2}' "$syslog_file" |  uniq -c 
