#!/usr/bin/env bash

set -e

. $(dirname $(realpath -s $0))/../lib/libstep.sh
. $(dirname $(realpath -s $0))/../lib/libstage.sh

STEPS=(
    "headers"
    "binutils"
    "llvm"
    "compiler-rt"
    "gcc"
)

export BUILD_TARGET="$1"
export STEPS_DIR=$(dirname $(realpath -s $0))

# Check if the target variable is set
test ! -z "$BUILD_TARGET" || stage_msg_failed "Build target is not set"

stage_msg "Building stage0..."

stage_msg "Creating needed directories..."
mkdir -vp "${STRAP_BUILD}" "${STRAP_INSTALL}" "${STRAP_SOURCES}"

for step in ${STEPS[@]} ; do
    /usr/bin/env -S -i STRAP_TARGET_FILE="${TARGET_FILE}" \
             bash --norc --noprofile "${STEPS_DIR}/${step}.sh" "${BUILD_TARGET}" || stage_msg_failed "Building ${step} failed"
    stage_msg "Cleaning up build directory..."
    rm -rf "${STRAP_BUILD}"/*
done
