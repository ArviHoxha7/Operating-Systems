#!/bin/bash

# Function to check if directory is provided and exists
check_directory() {
    if [ -z "$1" ]; then
        echo "No directory provided. Usage: $0 <directory>"
        exit 1
    fi

    if [ ! -d "$1" ]; then
        echo "Directory not found: $1"
        exit 1
    fi
}

# Function to display the top 5 largest files in the directory
top_files() {
    echo "Top 5 largest files in $1:"
    find "$1" -type f -exec du -h {} + | sort -hr | head -n 5
    echo
}

# Function to find files with more than one hard link
hard_links() {
    echo "Files with more than one hard link in $1:"
    find "$1" -type f -links +1
    echo
}

# Function to find files without read permission
no_read_permission() {
    echo "Files without read permission in $1:"
    find "$1" -type f ! -perm -u=r
    echo
}

# Main script execution
DIR="$1"
check_directory "$DIR"
top_files "$DIR"
hard_links "$DIR"
no_read_permission "$DIR"
