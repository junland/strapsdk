#!/usr/bin/env bash

set -e

. $(dirname $(realpath -s $0))/../lib/libstep.sh
. $(dirname $(realpath -s $0))/../lib/libstrap.sh

STEPS=(
    "headers"
    "binutils"
    "llvm"
    "compiler-rt"
    "gcc"
)

export TARGET_FILE="$1"
export STEPS_DIR=$(dirname $(realpath -s $0))

# Check if the target file exists
test -f "$TARGET_FILE" || { stage_msg_failed "Target file not found: $TARGET_FILE"; }

stage_msg "Creating needed directories..."
mkdir -vp "${STRAP_BUILD}" "${STRAP_INSTALL}" "${STRAP_SOURCES}"

for step in ${STEPS[@]} ; do
    /usr/bin/env -S -i STRAP_TARGET_FILE="${TARGET_FILE}" \
             bash --norc --noprofile "${STEPS_DIR}/${step}.sh ${TARGET_FILE}" || stage_msg_failed "Building ${step} failed"
    stage_msg "Cleaning up build directory..."
    rm -rf "${STRAP_BUILD}"/*
done
