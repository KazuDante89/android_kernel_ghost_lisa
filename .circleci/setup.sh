#!/usr/bin/env bash

BASE_DIR="#(pwd)"
KERNEL_SRC="$BASE_DIR"/Kernel
AK3_DIR="$BASE_DIR"/AnyKernel3
TC_DIR="$BASE_DIR"/clang
OUTPUT="$KERNEL_SRC"/out

# Helper function for cloning: gsc = git shallow clone
gsc() {
	git clone --depth=1 -q $@
}

# Clone Neutron Clang
echo "Downloading Neutron Clang"
mkdir $TC_DIR
cd $TC_DIR
bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S=latest
cd ../..

# Clone Kernel Source
echo "Downloading Kernel Source"
mkdir $KERNEL_SRC
gsc https://github.com/KazuDante89/android_kernel_ghost_lisa.git -b Proton_R0.3 $KERNEL_SRC
echo "Kernel Source Completed"

echo "Cloning AnyKernel3"
mkdir $AK3_DIR
gsc https://github.com/ghostrider-reborn/AnyKernel3.git -b lisa $AK3_DIR
echo "AnyKernel3 Completed"

# Copy script over to source
cd $KERNEL_SRC
bash build.sh
