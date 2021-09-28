#!/bin/true

name=binutils
version=2.37
source1="https://ftp.gnu.org/gnu/binutils/binutils-${version}.tar.bz2"

set -e

. $(dirname $(realpath -s $0))/../lib/libstep.sh

step_load_target $1

step_filedownload "$source1" "$STRAP_SOURCES"/"$(basename "$source1")"
step_fileunpack "$STRAP_SOURCES"/"$(basename "$source1")" "$STRAP_BUILD" 

cd ${STRAP_BUILD}/binutils-${version}

step_msg "Setting up enviroment variables..."

export PATH="${STRAP_INSTALL}/usr/bin:$PATH"
export CC="gcc"
export CXX="g++"
export CFLAGS="-O2"
export CXXFLAGS="-O2"

step_msg "Configuring binutils"

mkdir build && cd build
../configure --prefix=/usr/binutils \
  --target="${STRAP_TRIPLET_FULL}" \
  --with-sysroot="${STRAP_INSTALL}" \
  --libdir=/usr/lib \
  --includedir=/usr/include \
  --disable-multilib \
  --enable-deterministic-archives \
  --enable-plugins \
  --enable-lto \
  --disable-shared \
  --enable-static \
  --enable-ld=default \
  --enable-secureplt \
  --enable-64-bit-bfd || step_fail "Configure binutils"

step_msg "Building ${name}"
make -j "${STRAP_BUILD_JOBS}" tooldir=/usr/binutils || step_fail "Build binutils"

step_msg "Installing ${name}"
make -j "${STRAP_BUILD_JOBS}" tooldir=/usr/binutils install DESTDIR="${STRAP_INSTALL}" || step_fail "Install binutils"