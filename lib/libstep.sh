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

step_display_step_env() {
  step_msg "Displaying current strap enviroment variables..."

  local env=$(env | grep "STRAP" | sort | sed 's/=/ set as: /g')

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
  local file="$1"
  # Check if file exists
  if [ ! -f "$file" ]; then
    step_msg_red "Target file $file does not exist"
    return 1
  fi

  step_msg "Loading target file: $file"
  . $file
}

umask 022

unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

export PATH="/usr/bin:/bin/:/sbin:/usr/sbin"
export LANG="C"
export LC_ALL="C"
export step_PATH=$PATH
export step_LANG=$LANG
export step_LC_ALL=$LC_ALL
export step_CWD="$(dirname $(dirname $(realpath -s ${BASH_SOURCE[0]})))"
export step_PATCHES=$step_CWD/patches
export step_SOURCES=$step_CWD/sources
export step_BUILD=$step_CWD/build
export step_INSTALL=$step_CWD/install
export step_TARGET_ARCH=${step_TARGET_ARCH:-x86_64}
export step_BUILD_JOBS=${step_BUILD_JOBS:-$(nproc)}