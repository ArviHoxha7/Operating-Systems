#!/bin/bash

# Function to check SSL certificate expiration
check_ssl_expiry() {
    local website=$1
    echo "Checking SSL certificate expiration date for $website..."

    # Using openssl to get the expiration date of the SSL certificate
    local ssl_info=$(echo | openssl s_client -servername $website -connect $website:443 2>/dev/null | openssl x509 -noout -enddate)
    if [ -z "$ssl_info" ]; then
        echo "Failed to retrieve SSL information for $website."
        return 1
    fi

    # Extracting the expiration date and converting it to a date format
    local expiry_date=$(echo $ssl_info | sed 's/notAfter=//')
    local expiry_date_formatted=$(date -d "$expiry_date" '+%Y-%m-%d %H:%M:%S')
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')

    echo "Current date and time: $current_date"
    echo "SSL certificate expiration date and time: $expiry_date_formatted"

    # Comparing the current date with the expiration date
    if [ "$(date -d "$current_date" '+%s')" -gt "$(date -d "$expiry_date" '+%s')" ]; then
        echo "The SSL certificate for $website has expired."
    else
        echo "The SSL certificate for $website is valid."
    fi
}

# Main execution
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <website>"
    exit 1
fi

check_ssl_expiry "$1"
