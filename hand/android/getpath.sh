
#get relative path of android root
# 返回相对android主目录的路径
function hand_android_getpath()
{

	local PROP_KERNEL="android.path.kernel"
	local PROP_ARCH="android.path.arch"
	local PROP_UBOOT="android.path.uboot"
	local PROP_DTSDIR="android.path.dts"

 	local sub=$1
    shift
	case $sub in
	"kernel")
		kernel=`hand__pure_do hand prop get $PROP_KERNEL`
		if [ $? -ne 0 ]; then
			echo $kernel
			# hand echo error "prop $PROP_KERNEL not defined"
			return 1
		fi
		echo $kernel
		;;
	"defconfig")
		kernel=`hand__pure_do hand prop get $PROP_KERNEL`
		if [ $? -ne 0 ]; then
			echo $kernel
			# hand echo error "prop $PROP_KERNEL not defined"
			return 1
		fi
		arch=`hand__pure_do hand prop get $PROP_ARCH`
		if [ $? -ne 0 ]; then
			echo $arch
			# hand echo error "prop $PROP_ARCH not defined"
			return 1
		fi
		echo "$kernel"/arch/"$arch"/configs
		;;
	"dts")
		kernel=`hand__pure_do hand prop get $PROP_KERNEL`
		if [ $? -ne 0 ]; then
			echo $kernel
			# hand echo error "prop $PROP_KERNEL not defined"
			return 1
		fi
		arch=`hand__pure_do hand prop get $PROP_ARCH`
		if [ $? -ne 0 ]; then
			echo $arch
			# hand echo error "prop $PROP_ARCH not defined"
			return 1
		fi
		dtsdir=`hand__pure_do hand prop get $PROP_DTSDIR`
		if [ $? -ne 0 ]; then
			echo $dtsdir
			# dtsdir=""
			return 1
		fi
		echo "$kernel"/arch/"$arch"/boot/dts/"$dtsdir"
		;;
	"device")
		# echo "device/tablet/${TARGET_PRODUCT#*full_}"
		echo "device/tablet/${TARGET_PRODUCT%_*}"
        ;;
    "out")
        if [ ! "$OUT" ]; then
        	hand echo error "\$OUT not defined, please lunch android first"
            return 1
        fi
        echo "$OUT"
        ;;
    "uboot")
		uboot=`hand__pure_do hand prop get $PROP_UBOOT`
		if [ $? -ne 0 ]; then
			echo $uboot
			# hand echo error "prop $PROP_UBOOT not defined"
			return 1
		fi
		echo $uboot
		# echo "$android_getpath__ubootpath"
        ;;
    "ethernet")
		echo "framworks/opt/net/ethernet"
		;;
    *)
		hand echo error "android path ($sub) not defined"
		return 1
		;;
	esac
}


function android_getpath__workspace_default()
{
	# workspace variables
	# 1. arch
	# 2. kernelpath
	#
	if [ ! "$android_getpath__arch" ]; then
		android_getpath__arch="arm"
	fi

	if [ ! "$android_getpath__kernelpath" ]; then
		android_getpath__kernelpath="kernel"
	fi
}

# android_getpath "$@"
