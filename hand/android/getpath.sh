
#get relative path of android root
function hand_android_getpath()
{
 	local sub=$1
    shift
	case $sub in
	"kernel")
		echo "$hand_android_getpath__kernelpath"
		;;
	"defconfig")
		echo "$hand_android_getpath__kernelpath"/arch/"$hand_android_getpath__arch"/configs
		;;
	"dts")
		echo "$hand_android_getpath__kernelpath"/arch/"$hand_android_getpath__arch"/boot/dts/"$hand_android_getpath__dtsdir"
		;;
	"device")
		echo "device/tablet/${TARGET_PRODUCT#*full_}"
        ;;
    "out")
        echo "$OUT"
        ;;
    "uboot")
		echo "$hand_android_getpath__ubootpath"
        ;;
	esac
}


hand_android_getpath__workspace_default()
{
	if [ ! "$hand_android_getpath__arch" ]; then
		hand_android_getpath__arch="arm"
	fi

	if [ ! "$hand_android_getpath__kernelpath" ]; then
		hand_android_getpath__kernelpath="kernel"
	fi
}


hand work --load hand_android_getpath
