hand_time()
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
	if [ "`uname`" = "Darwin" ]; then
		hand_time__record=`date '+%s000000000'`
	else
		hand_time__record=`date '+%s%N'`
	fi
	hand_time__thing=$1
}

hand_time__end()
{
	local now=
	if [ "`uname`" = "Darwin" ]; then
		now=`date '+%s000000000'`
	else
		now=`date '+%s%N'`
	fi

	local delta=0

	((delta=(now-hand_time__record)))
	
	# echo "delta=$delta"
	echo "================"
	if [ $hand_time__thing ]; then
		hand echo green "TIME USED for $hand_time__thing:"
	else
		hand echo green "TIME USED:"
	fi
	local length=${#delta}
	while [ $length -lt 10 ]; do
		delta="0$delta"
		length=${#delta}
	done
	((index=length-9))
	hand echo green "${delta:0:$index}.${delta:$index} seconds"
	echo "================"
}
