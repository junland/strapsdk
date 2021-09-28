#!/bin/true

name=llvm
version=12.0.1
source1="https://github.com/${name}/${name}-project/releases/download/llvmorg-${version}/${name}-project-${version}.src.tar.xz"

set -e 

. $(dirname $(realpath -s $0))/../lib/libstep.sh

step_load_target $1

step_filedownload "$source1" "$STRAP_SOURCES"/"$(basename "$source1")"
step_fileunpack "$STRAP_SOURCES"/"$(basename "$source1")" "$STRAP_BUILD" 

cd ${STRAP_BUILD}/llvm-project-${version}.src/llvm

mkdir -vp build && pushd build

case ${STRAP_TARGET_LLVM_BACKEND} in
  X86)
    export CFLAGS="-fPIC -O2 -pipe"
    export CXXFLAGS="${CFLAGS}"
    ;;
  AArch64)
    export CFLAGS="-fPIC -O2 -pipe -mno-outline-atomics"
    export CXXFLAGS="${CFLAGS}"
    ;;
  *)
    step_msg "No LLVM target found for ${STRAP_TARGET_LLVM_BACKEND}"
    exit 1
    ;;
esac

step_display_stage_env

step_msg "Setting up configure options..."
export main_llvm_opts="-DDEFAULT_SYSROOT="${STRAP_INSTALL}" \
    -DLLVM_TARGET_ARCH="${STRAP_TARGET_ARCH}" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="${STRAP_TRIPLET_FULL}" \
    -DLLVM_TARGETS_TO_BUILD="${STRAP_TARGET_LLVM_BACKEND}" \
    -DCLANG_VENDOR="${STRAP_TARGET_VENDOR}" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DLLVM_ENABLE_PROJECTS='clang;compiler-rt;libcxx;libcxxabi;libunwind;lld;llvm' \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_LINKER=lld \
    -DCLANG_DEFAULT_OBJCOPY=llvm-objcopy \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
    -DLLVM_INSTALL_CCTOOLS_SYMLINKS=ON \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=OFF \
    -DCOMPILER_RT_USE_LIBCXX=ON \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_STATIC_LINK_CXX_STDLIB=ON \
    -DSANITIZER_CXX_ABI=libc++ \
    -DLIBCXX_INSTALL_SUPPORT_HEADERS=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=OFF \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=ON \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_BUILTINS=ON \
    -DLLVM_USE_SANITIZER=OFF \
    -DLLVM_ENABLE_UNWIND_TABLES=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_UTILS=OFF \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
    -DCLANG_BUILD_EXAMPLES=OFF \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_BUILD_TOOLS=OFF \
    -DCLANG_BUILD_TOOLS=OFF \
    -Wno-dev"

step_msg "Configuring ${name} (1 of 2)"
cmake -G Ninja ../ \
  ${main_llvm_opts} \
  -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_BUILD_LLVM_DYLIB=ON

step_msg "Building ${name} (1 of 3)"
ninja -j "${STRAP_BUILD_JOBS}" -v

step_msg "Building ${name} (2 of 3)"
ninja -j "${STRAP_BUILD_JOBS}" -v llvm-config

step_msg "Installing ${name} (1 of 2)"
DESTDIR="${STRAP_INSTALL}" ninja install -j "${STRAP_BUILD_JOBS}" -v

step_msg "Configuring ${name} (2 of 2)"
cmake -G Ninja ../ \
  ${main_llvm_opts} \
  -DLLVM_BUILD_LLVM_DYLIB=OFF -DLLVM_LINK_LLVM_DYLIB=OFF -DCLANG_LINK_CLANG_DYLIB=OFF

step_msg "Building ${name} (3 of 3)"
ninja -j "${STRAP_BUILD_JOBS}" -v lld clang

step_msg "Installing ${name} (2 of 2)"
cp -vr "${STRAP_BUILD}"/llvm-project-${version}.src/llvm/build/bin/* "${STRAP_INSTALL}/usr/bin/"

# Only install if binutils ld not already present
if [ ! -f "${STRAP_INSTALL}/usr/bin/ld" ]; then
  step_msg "Setting ld.lld as default ld"
  ln -svf ld.lld "${STRAP_INSTALL}/usr/bin/ld"
else
  step_msg "ld.lld already present, skipping"
fi

rm -rf ${STRAP_BUILD}/llvm-project-${version}.src

