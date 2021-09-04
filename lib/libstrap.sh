#!/bin/bash

strap_msg() {
  printf " >>>> %s\n" "$1"
}

strap_msg_red() {
  printf "\e[31m >>>> %s \n\e[0m" "$1"
}

strap_msg_green() {
  printf "\e[32m >>>> %s \n\e[0m" "$1"
}

# Download file using curl.
strap_filedownload() {
  local url="$1"
  local file="$2"

  # Check if file exists
  if [ -f "$file" ]; then
    strap_msg_green "File $file already exists"
    return 0
  fi

  strap_msg "Downloading $url"

  if curl -L --fail --ftp-pasv --retry 3 --retry-delay 3 -o $file "$url"; then
    strap_msg "Download complete for $url"
    return 0
  else
    strap_msg_red "Download failed for $url"
    return 1
  fi
}

# Unpack file using tar or bsdtar.
strap_fileunpack() {
  local file="$1"
  local dir="$2"
  local prog=tar
  [ $(command -v bsdtar) ] && prog=bsdtar

  case $file in
    *.tar | *.tar.gz | *.tar.Z | *.tgz | *.tar.bz2 | *.tar.lz | *.tbz2 | *.tar.xz | *.txz | *.tar.lzma | *.zip | *.rpm)
      strap_msg "Unpacking: $file into $dir"
      $prog -p -o -C $dir -xf $file
      ;;
    *)
      strap_msg "Copying: $file into $dir"
      cp $file $dir
      ;;
  esac

  [ $? = 0 ] || {
    strap_msg_red "Unpacking/Copying failed: $file"
    exit 1
  }
}
