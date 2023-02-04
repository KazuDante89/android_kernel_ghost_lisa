#!/bin/bash

TC_DIR="/home/kazu/toolchains/clang"
export PATH="$TC_DIR/bin:$PATH"
SRC_DIR="/home/kazu/android_kernel_ghost_lisa"
DEFCONFIG_DIR="/home/kazu/android_kernel_ghost_lisa/arch/arm64/configs/"
DEFCONFIG="lisa_defconfig"
MAKE_PARAMS="O=out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- LD=ld.lld LLVM=1 LLVM_IAS=1 \
CROSS_COMPILE=$TC_DIR/bin/llvm-"
outdef="/home/kazu/android_kernel_ghost_lisa/out/.config"


make $MAKE_PARAMS $DEFCONFIG
cp $outdef "$DEFCONFIG_DIR"/$DEFCONFIG
echo -e "\nSuccessfully regenerated defconfig at $DEFCONFIG"

rm -rf $SRC_DIR/out
