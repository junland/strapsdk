#!/bin/true

name=gcc
version=11.2.0
mpfr_version=4.1.0
mpc_version=1.2.1
gmp_version=6.2.1
isl_version=0.24
source1="https://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.xz"
source2="https://ftp.gnu.org/gnu/mpfr/mpfr-${mpfr_version}.tar.xz"
source3="https://ftp.gnu.org/gnu/mpc/mpc-${mpc_version}.tar.gz"
source4="https://ftp.gnu.org/gnu/gmp/gmp-${gmp_version}.tar.xz"
source5="http://isl.gforge.inria.fr/isl-${isl_version}.tar.xz"

set -e

. $(dirname $(realpath -s $0))/../lib/libstep.sh

step_load_config $1

step_filedownload "$source1" "$STRAP_SOURCES"/"$(basename "$source1")"
step_fileunpack "$STRAP_SOURCES"/"$(basename "$source1")" "$STRAP_BUILD" 

step_filedownload "$source2" "$STRAP_SOURCES"/"$(basename "$source2")"
step_fileunpack "$STRAP_SOURCES"/"$(basename "$source2")" "$STRAP_BUILD" 

step_filedownload "$source3" "$STRAP_SOURCES"/"$(basename "$source3")"
step_fileunpack "$STRAP_SOURCES"/"$(basename "$source3")" "$STRAP_BUILD" 

step_filedownload "$source4" "$STRAP_SOURCES"/"$(basename "$source4")"
step_fileunpack "$STRAP_SOURCES"/"$(basename "$source4")" "$STRAP_BUILD" 

step_filedownload "$source5" "$STRAP_SOURCES"/"$(basename "$source5")"
step_fileunpack "$STRAP_SOURCES"/"$(basename "$source5")" "$STRAP_BUILD" 

cd ${STRAP_BUILD}/gcc-${version} || exit

step_msg "Symlinking needing libraries..."

ln -sv ../mpfr-${mpfr_version} mpfr
ln -sv ../mpc-${mpc_version} mpc
ln -sv ../gmp-${gmp_version} gmp
ln -sv ../isl-${isl_version} isl

step_msg "Setting variables..."
export PATH="${STRAP_INSTALL}/usr/binutils/bin:$PATH"
export CC="gcc"
export CXX="g++"
export CFLAGS="-O2"
export CXXFLAGS="-O2"

step_display_stage_env

step_msg "Configuring gcc"
mkdir build && cd build
../configure --prefix=/usr \
  --libdir=/usr/lib \
  --with-sysroot="${STRAP_INSTALL}" \
  --with-build-sysroot="${STRAP_INSTALL}" \
  --target="${STRAP_TRIPLET_FULL}" \
  --disable-multilib \
  --disable-bootstrap \
  --with-newlib \
  --disable-shared \
  --enable-lto \
  --disable-threads \
  --enable-initfini-array \
  --with-gcc-major-version-only \
  --enable-languages=c,c++ \
  LD="ld.bfd" || step_fail "Configure gcc"

step_msg "Building gcc compiler only"
make -j "${STRAP_BUILD_JOBS}" all-gcc || step_fail "Build standalone gcc compiler"

step_msg "Installing gcc"
make -j "${STRAP_BUILD_JOBS}" install-gcc DESTDIR="${STRAP_INSTALL}" || step_fail "Install gcc"

step_msg "Building target libgcc"
make -j "${STRAP_BUILD_JOBS}" all-target-libgcc || step_fail "Build target libgcc"

step_msg "Installing target libgcc"
make -j "${STRAP_BUILD_JOBS}" install-target-libgcc DESTDIR="${STRAP_INSTALL}" || step_fail "Install target libgcc"

step_msg "Installing default compiler links"
for i in "gcc" "g++"; do
  ln -sv "${STRAP_TRIPLET_FULL}-${i}" "${STRAP_INSTALL}/usr/bin/${i}"
done
