##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand time
##
local sub=$1
shift
case $sub in
"-h"|"--help")
	echo "多进程执行, 并控制进程数量"
	echo -e "$hand__cmd start [<task_name>] \t# Mark start time, can append with a name"
	echo -e "$hand__cmd end            \t# Mark end time and show duration"
	echo -e "$hand__cmd -h/--help      \t# Show help"
	;;
"start")
	if [ "`uname`" = "Darwin" ]; then
		hand_time__record=`date '+%s000000000'`
	else
		hand_time__record=`date '+%s%N'`
	fi
	hand_time__thing="$1"
	;;
"end")
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
		hand echo green "TIME USED for task \"$hand_time__thing\":"
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
	;;
*)
	hand echo error "hand time: $sub unsupported"
	;;
esac
