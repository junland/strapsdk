#!/bin/bash

strap_msg() {
    printf " >>>> %s\n" "$1"
}

strap_msg_red() {
    printf "\e[31m >>>> %s \n\e[0m" "$1"
}

# Download file using curl
strap_filedownload() {
    local url="$1"
    local file="$2"
    local retries="$3"
    local retry_delay="$4"
    local retry_count=0

    strap_msg "Downloading $url"
    
    while [ $retry_count -lt $retries ]; do
        if curl -s -o $dir/$filename "$url"; then
            strap_msg "Download complete for $url into $file"
            return 0
        fi
        retry_count=$((retry_count + 1))
        sleep $retry_delay
    done

    strap_msg_red "Failed to download $url"
    
    return 1
}
