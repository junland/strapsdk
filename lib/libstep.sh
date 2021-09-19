#!/bin/bash

step_msg() {
  printf " >>>> %s\n" "$1"
}

step_display_strap_env() {
  step_msg "Displaying current strap enviroment variables..."

  local env=$(env | grep "STRAP" | sort | sed 's/=/ set as: /g')

  echo "$env"
}