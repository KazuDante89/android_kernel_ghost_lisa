#!/bin/bash
#
# Compile script for QuicksilveR kernel
# Copyright (C) 2020-2021 Adithya R.

##----------------------------------------------------------##

tg_post_msg()
{
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="$chat_id" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"

}

tg_post_build()
{
	#Post MD5Checksum alongwith for easeness
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	#Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$chat_id"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=Markdown" \
	-F caption="$2 | *MD5 Checksum : *\`$MD5CHECK\`"
}

MODEL="Xiaomi 11 Lite 5G NE"
DEVICE="lisa"
ARCH=arm64
BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
BOT_BUILD_URL="https://api.telegram.org/bot$token/sendDocument"
CI="Circle CI"
COMMIT_HEAD=$(git log --oneline -1)
KV=$(make $MAKE_PARAMS1 kernelversion)
KBUILD_COMPILER_STRING=$("$TC_DIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export PATH="$TC_DIR/bin:$PATH"

##----------------------------------------------------------##

SECONDS=0 # builtin bash timer
TC_DIR="$BASE_DIR/clang"
AK3_DIR="$BASE_DIR/AnyKernel3"
DEFCONFIG="lisa_defconfig"
output="$BASE_DIR/Kernel/out"

BLDV="R0.3-v0.0.0"
ZIPNAME="Proton-$BLDV.zip"

MAKE_PARAMS="O=out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 \
	CROSS_COMPILE=$TC_DIR/bin/llvm-"

MAKE_PARAMS1="ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 \
	CROSS_COMPILE=$TC_DIR/bin/llvm-"

if [[ $1 = "-r" || $1 = "--regen" ]]; then
	make $MAKE_PARAMS $DEFCONFIG
	cp out/.config arch/arm64/configs/$DEFCONFIG
	echo -e "\nSuccessfully regenerated defconfig at $DEFCONFIG"
	exit
fi

if [[ $1 = "-c" || $1 = "--clean" ]]; then
	rm -rf out
	echo "Cleaned output folder"
fi

mkdir -p out
make $MAKE_PARAMS $DEFCONFIG

echo -e "\nStarting compilation...\n"
make -j$(nproc --all) $MAKE_PARAMS || exit $?
make -j$(nproc --all) $MAKE_PARAMS INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 modules_install

kernel="out/arch/arm64/boot/Image"
dtb="out/arch/arm64/boot/dts/vendor/qcom/yupik.dtb"
dtbo="out/arch/arm64/boot/dts/vendor/qcom/lisa-sm7325-overlay.dtbo"

if [ -f "$kernel" ] && [ -f "$dtb" ] && [ -f "$dtbo" ]; then
	echo -e "\nKernel compiled succesfully! Zipping up...\n"
fi
	cp $kernel $AK3_DIR
	cp $dtb $AK3_DIR/dtb
	python3 scripts/dtc/libfdt/mkdtboimg.py create $AK3_DIR/dtbo.img --page_size=4096 $dtbo
	cp $(find out/modules/lib/modules/5.4* -name '*.ko') $AK3_DIR/modules/vendor/lib/modules/
	cp out/modules/lib/modules/5.4*/modules.{alias,dep,softdep} $AK3_DIR/modules/vendor/lib/modules
	cp out/modules/lib/modules/5.4*/modules.order $AK3_DIR/modules/vendor/lib/modules/modules.load
	sed -i 's/\(kernel\/[^: ]*\/\)\([^: ]*\.ko\)/\/vendor\/lib\/modules\/\2/g' $AK3_DIR/modules/vendor/lib/modules/modules.dep
	sed -i 's/.*\///g' $AK3_DIR/modules/vendor/lib/modules/modules.load
	rm -rf out/arch/arm64/boot out/modules
	cd $AK3_DIR
	zip -r9 "$ZIPNAME" * -x .git README.md *placeholder
	echo "Zip: $ZIPNAME"
	tg_post_build "$ZIPNAME"
	cd ..
	rm -rf AnyKernel3
	echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
	exit 1
fi
