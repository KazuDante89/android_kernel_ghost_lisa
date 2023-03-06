#!/usr/bin/env bash

BASE_DIR="/root/project"

# Helper function for cloning: gsc = git shallow clone
gsc() {
	git clone --depth=1 -q $@
}

# Clone Neutron Clang
echo "Downloading Neutron Clang"
mkdir "$BASE_DIR"/clang
TC_DIR="$BASE_DIR"/clang
cd $TC_DIR
bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S=16012023
echo "$(pwd)"
cd ../..

# Clone Kernel Source
echo "Downloading Kernel Source"
mkdir $BASE_DIR/Kernel
KERNEL_SRC="$BASE_DIR"/Kernel
OUTPUT="$KERNEL_SRC"/out
gsc https://github.com/KazuDante89/android_kernel_ghost_lisa.git -b Proton_R0.3 $KERNEL_SRC
echo "Kernel Source Completed"

echo "Cloning AnyKernel3"
mkdir "$BASE_DIR"/AnyKernel3
AK3_DIR="$BASE_DIR"/AnyKernel3
gsc https://github.com/ghostrider-reborn/AnyKernel3.git -b lisa $AK3_DIR
echo "AnyKernel3 Completed"

# Copy script over to source
cd $KERNEL_SRC
echo "$(pwd)"
export TC_DIR KERNEL_SRC OUTPUT AK3_DIR
bash <(curl -s https://raw.githubusercontent.com/KazuDante89/android_kernel_ghost_lisa/Proton_R0.3/.circleci/build.sh)
