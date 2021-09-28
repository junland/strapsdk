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