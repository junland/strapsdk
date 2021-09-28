#!/bin/bash -e

stage_msg() {
  printf " >>>> %s\n" "$1"
}

stage_msg_red() {
  printf "\e[31m >>>> %s \n\e[0m" "$1"
}

stage_msg_green() {
  printf "\e[32m >>>> %s \n\e[0m" "$1"
}

stage_msg_failed() {
  stage_msg_red "$1"
  exit 1
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