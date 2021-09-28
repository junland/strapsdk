#!/bin/true

. $(dirname $(realpath -s $0))/../lib/libstep.sh

step_load_config $1

name=headers
version=5.13.6
source1="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${version}.tar.xz"

stage_filedownload "$source1" "$STRAP_SOURCES"/"$(basename "$source1")"
stage_fileunpack "$STRAP_SOURCES"/"$(basename "$source1")" "$STRAP_BUILD" 

cd ${STRAP_BUILD}/linux-*

step_msg "Configuring headers"

export ARCH="${STRAP_TARGET_KARCH}"
make ARCH="${STRAP_TARGET_KARCH}" mrproper
make ARCH="${STRAP_TARGET_KARCH}" headers

step_msg "Post-configure headers cleanup"

find ./usr/include -name '.*' -delete
rm -vf ./usr/include/Makefile

step_msg "Installing headers"

install -D -d -m 00755 "${STRAP_INSTALL}/usr/include"
cp -Rv usr/include "${STRAP_INSTALL}/usr/."

