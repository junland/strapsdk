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

step_display_strap_env() {
  step_msg "Displaying current strap enviroment variables..."

  local env=$(env | grep "STRAP" | sort | sed 's/=/ set as: /g')

  echo "$env"
}

step_fail() {
  step_msg_red "Failed: $1"
  exit 1
}