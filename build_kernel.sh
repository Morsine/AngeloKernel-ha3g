#!/bin/bash
# kernel build script by Tkkg1994 v0.6 (optimized from apq8084 kernel source)

export MODEL=ha3g
export ARCH=arm
export BUILD_CROSS_COMPILE=~/gcc-linaro-5/bin/arm-linux-gnueabi-
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
INCDIR=$RDIR/include

if [ $MODEL = chagalllte ]
then
	KERNEL_DEFCONFIG=ironstock_chagalllte_defconfig
else if [ $MODEL = chagallwifi ]
then
	KERNEL_DEFCONFIG=ironstock_chagallwifi_defconfig
else if [ $MODEL = ha3g ]
then
	KERNEL_DEFCONFIG=Angelo_defconfig
else if [ $MODEL = klimtlte ]
then
	KERNEL_DEFCONFIG=ironstock_klimtlte_defconfig
else [ $MODEL = klimtwifi ]
	KERNEL_DEFCONFIG=ironstock_klimtwifi_defconfig
fi
fi
fi
fi

FUNC_CLEAN_DTB()
{
	if ! [ -d $RDIR/arch/$ARCH/boot/dts ] ; then
		echo "no directory : "$RDIR/arch/$ARCH/boot/dts""
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $RDIR/arch/$ARCH/boot/dts/*.dtb
		rm $RDIR/arch/$ARCH/boot/dtb/*.dtb
		rm $RDIR/arch/$ARCH/boot/Image
		rm $RDIR/arch/$ARCH/boot/boot.img-dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-zImage
	fi
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_KERNEL"
        echo "=============================================="
        echo ""
        echo "build common config="$KERNEL_DEFCONFIG ""
        echo "build variant config="$MODEL ""

	FUNC_CLEAN_DTB

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
	
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

FUNC_BUILD_RAMDISK()
{
	mv $RDIR/arch/$ARCH/boot/zImage $RDIR/arch/$ARCH/boot/boot.img-zImage

	case $MODEL in
	chagalllte)
		rm -f $RDIR/ramdisk/SM-T805/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-T805/split_img/boot.img-zImage
		cd $RDIR/ramdisk/SM-T805
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	chagallwifi)
		rm -f $RDIR/ramdisk/SM-T800/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-T800/split_img/boot.img-zImage
		cd $RDIR/ramdisk/SM-T800
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	klimtlte)
		rm -f $RDIR/ramdisk/SM-T705/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-T705/split_img/boot.img-zImage
		cd $RDIR/ramdisk/SM-T705
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	ha3g)
		rm -f $RDIR/ramdisk/SM-N900/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-N900/split_img/boot.img-zImage
		cd $RDIR/ramdisk/SM-N900
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	klimtwifi)
		rm -f $RDIR/ramdisk/SM-T700/split_img/boot.img-zImage
		mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/ramdisk/SM-T700/split_img/boot.img-zImage
		cd $RDIR/ramdisk/SM-T700
		./repackimg.sh
		echo SEANDROIDENFORCE >> image-new.img
		;;
	*)
		echo "Unknown device: $MODEL"
		exit 1
		;;
	esac
}

# MAIN FUNCTION
rm -rf ./build.log
(
    START_TIME=`date +%s`

	FUNC_BUILD_KERNEL
	FUNC_BUILD_RAMDISK

    END_TIME=`date +%s`
	
    let "ELAPSED_TIME=$END_TIME-$START_TIME"
    echo "Total compile time is $ELAPSED_TIME seconds"
) 2>&1	 | tee -a ./build.log
