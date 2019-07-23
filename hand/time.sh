
function hand_time()
{
	local sub=$1
	shift
	case $sub in
	"start")
		hand_time__start $*
		;;
	"end")
		hand_time__end $*
		;;
	*)
		hand echo error "$sub unsupported"
		;;
	esac
}


hand_time__start()
{
	hand_time__record=`date '+%s%N'`
	hand_time__thing=$1
}

hand_time__end()
{
	local now=`date '+%s%N'`

	local delta=0

	((delta=(now-hand_time__record)))
	
	# echo "delta=$delta"
	echo "================"
	if [ $hand_time__thing ]; then
		hand echo red "TIME USED for $hand_time__thing:"
	else
		hand echo red "TIME USED:"
	fi
	local length=${#delta}
	if [ $length -lt 9 ]; then
		delta="0$delta"
	fi
	((index=length-9))
	hand echo red "${delta:0:-9}.${delta:index} seconds"
	echo "================"
}


# hand_time "$@"