#!/bin/sh
release="74"
make clean
ccache -c
rm -rf ../ramdisk_hammerhead/boot.img
make aosp_defconfig
export NUMBEROFCPUS=`grep 'processor' /proc/cpuinfo | wc -l`;
make -j$NUMBEROFCPUS CONFIG_NO_ERROR_ON_MISMATCH=y CONFIG_LOCALVERSION="-Crystal.Kernel-r$release"

cp arch/arm/boot/zImage-dtb ../ramdisk_hammerhead/

cd ../ramdisk_hammerhead/

echo "making ramdisk"
./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
echo "making boot image"
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot.img

rm -rf ramdisk.gz
rm -rf zImage-dtb
cd ../hammerhead/

zipfile="Crystal.Kernel-r$release.zip"

cp boot.img zip/
cd ./zip
rm -f *.zip
zip -r -9 $zipfile *
cd ..
