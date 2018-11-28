#react native


function hand_rn()
{
	local sub=$1
	shift
	case $sub in
	"release")
		hand_rn__release $*
		;;
	"run")
		hand_rn__run $*
		;;
	*)
		hand echo error "$sub unsupported"
		;;
	esac
}


hand_rn__gradlew_clean()
{
	cd android
	gradlew clean
	cd ..
}

function hand_rn__release()
{
	if [ "$hand_rn__platform" == "android" ]; then
		cd android
		[[  $? -ne 0 ]] && hand echo error "cd android failed!" && return 1
		./gradlew assembleRelease
	else
		hand echo error "$hand_rn__platform not support!"
	fi
}

function hand_rn__run()
{
	react-native run-$hand_rn__platform $*
}

function hand_rn__workspace_default()
{
	if [ "$hand_rn__platform" == "" ]; then
		hand_rn__platform="android"
	fi
}

hand work --load hand_rn
