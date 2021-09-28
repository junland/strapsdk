#!/bin/bash -e

step_msg() {
  printf " >>>> %s\n" "$1"
}

step_msg_red() {
  printf "\e[31m >>>> %s \n\e[0m" "$1"
}

step_msg_green() {
  printf "\e[32m >>>> %s \n\e[0m" "$1"
}

step_display_env() {
  step_msg "Current strap enviroment variables for step..."

  local env=$(env | grep "STRAP" | sort | sed 's/=/ set as: /g' | sed 's/^/ ==> /g')

  echo "$env"
}

step_fail() {
  step_msg_red "Failed: $1"
  exit 1
}

# Download file using curl.
step_filedownload() {
  local url="$1"
  local file="$2"

  # Check if file exists
  if [ -f "$file" ]; then
    step_msg_green "File $file already exists"
    return 0
  fi

  step_msg "Downloading $url"

  if curl -L --fail --ftp-pasv --retry 3 --retry-delay 3 -o $file "$url"; then
    step_msg "Download complete for $url"
    return 0
  else
    step_msg_red "Download failed for $url"
    return 1
  fi
}

# Unpack file using tar or bsdtar.
step_fileunpack() {
  local file="$1"
  local dir="$2"
  local prog=tar

  case $file in
    *.tar | *.tar.gz | *.tar.Z | *.tgz | *.tar.bz2 | *.tar.lz | *.tbz2 | *.tar.xz | *.txz | *.tar.lzma | *.zip | *.rpm)
      step_msg "Unpacking: $file into $dir"
      LANG=C $prog -p -o -C $dir -xf $file
      ;;
    * | *.nounpack | *.noextract)
      step_msg "Copying: $file into $dir"
      cp $file $dir
      ;;
  esac

  [ $? = 0 ] || {
    step_msg_red "Unpacking/Copying failed: $file"
    exit 1
  }
}

# Load target file
step_load_target() {
  local tgt="$1"
  # Check if file exists
  if [ ! -f ${STRAP_TARGET_DIR}/$tgt.tgt ]; then
    step_msg_red "Target file for $tgt does not exist"
    return 1
  fi

  step_msg "Loading target: $tgt"
  . ${STRAP_TARGET_DIR}/$tgt.tgt

  step_display_env
}

umask 022

unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

export PATH="/usr/bin:/bin/:/sbin:/usr/sbin"
export LANG="C"
export LC_ALL="C"
export STRAP_PATH=$PATH
export STRAP_LANG=$LANG
export STRAP_LC_ALL=$LC_ALL
export STRAP_CWD="$(dirname $(dirname $(realpath -s ${BASH_SOURCE[0]})))"
export STRAP_PATCHES=$STRAP_CWD/patches
export STRAP_SOURCES=$STRAP_CWD/sources
export STRAP_BUILD=$STRAP_CWD/build
export STRAP_INSTALL=$STRAP_CWD/install
export STRAP_BUILD_JOBS=${STRAP_BUILD_JOBS:-$(nproc)}
export STRAP_TARGET_DIR=${STRAP_CWD}/target