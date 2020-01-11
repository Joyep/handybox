#react native


function hand_rn()
{

	local platform
	platform=`hand__pure_do hand prop get rn.platform`
	if [ $? -ne 0 ]; then
		echo $platform
		return 1
	fi

	local sub=$1
	shift
	case $sub in
	"build")
		hand_rn__release $platform $*
		;;

	"run")
		hand_rn__run $platform $*
		;;

	"log")
		hand_rn__log $platform $*
		;;
	"clean")
		hand_rn__clean $platform $*
		;;
	*)
		hand echo error "$sub unsupported"
		;;
	esac
}


hand_rn__clean()
{
	local plat=$1
	shift
	if [ "$plat" = "android" ]; then
		cd android
		gradlew clean
		cd ..
	else
		hand echo error $plat not support!
	fi
	
}

function hand_rn__release()
{
	local plat=$1
	shift
	if [ "$plat" = "android" ]; then
		cd android
		# [[  $? -ne 0 ]] && hand echo error "cd android failed!" && return 1
		./gradlew $1
	else
		hand echo error "$plat not support!"
	fi
}

function hand_rn__run()
{
	local plat=$1
	shift
	react-native run-$plat $*
}

function hand_rn__log()
{
	local plat=$1
	shift
	if [ $# -eq 0 ]; then
		hand echo error "log for what project? please give your project name!"
		return 1
	fi
	if [ "$plat" = "android" ]; then
		react-native log-$plat $*
	elif [ "$plat" = "ios" ]; then
		react-native-log-ios $*
	fi
}
