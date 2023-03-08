TC_DIR="/home/kazu/Neutron-17"
TC_BIN_DIR="$TC_DIR/bin"
export PATH="$TC_DIR/bin:$PATH"
SRC_DIR="/home/kazu/android_kernel_ghost_lisa"
output="$SRC_DIR/out"
DEFCONFIG="lisa_defconfig"
MAKE_PARAMS="O=out ARCH=arm64 CC=$TC_BIN_DIR/clang CLANG_TRIPLE=$TC_BIN_DIR/bin/aarch64-linux-gnu- LD=$TC_BIN_DIR/ld.lld LLVM=1 LLVM_IAS=1 \
CROSS_COMPILE=$TC_BIN_DIR/bin/llvm-"


make $MAKE_PARAMS mrproper
make $MAKE_PARAMS $DEFCONFIG
cp "$output"/.config "/home/kazu/android_kernel_ghost_lisa/arch/arm64/configs/lisa_defconfig"
echo -e "\nSuccessfully regenerated $DEFCONFIG"

rm -rf $SRC_DIR/out
