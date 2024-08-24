#!/bin/bash

# Function to display CPU information
display_cpu_info() {
    echo "CPU: $(lscpu | grep 'Model name:' | awk -F ':' '{print $2}' | sed 's/^[ 	]*//')"
}

# Function to display memory information
display_memory_info() {
    mem_info=$(free -h | grep Mem)
    total=$(echo $mem_info | awk '{print $2}')
    used=$(echo $mem_info | awk '{print $3}')
    free=$(echo $mem_info | awk '{print $4}')
    echo "Memory: Total: $total Used: $used Free: $free"
}

# Function to display disk usage
display_disk_usage() {
    disk_usage=$(df -h --total | grep 'total')
    total=$(echo $disk_usage | awk '{print $2}')
    used=$(echo $disk_usage | awk '{print $3}')
    free=$(echo $disk_usage | awk '{print $4}')
    echo "Disk Usage: Total: $total Used: $used Free: $free"
}

# Display the menu and handle user input
while true; do
    echo "Choose an option to display system information:"
    select opt in "Hostname" "Kernel" "CPU" "Memory" "Disk-Usage" "Exit"; do
        case $opt in
            "Hostname")
                echo "Hostname: $(hostname)"
                break
                ;;
            "Kernel")
                echo "Kernel Version: $(uname -r)"
                break
                ;;
            "CPU")
                display_cpu_info
                break
                ;;
            "Memory")
                display_memory_info
                break
                ;;
            "Disk-Usage")
                display_disk_usage
                break
                ;;
            "Exit")
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
done
