##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# thread
##
case $1 in
"-h"|"--help")
	echo "多进程执行, 并控制进程数量"
	echo -e "$hand__cmd start [<max_thread> [<fd_value>]]"
	echo -e "                          \t# start multi thread session"
	echo -e "$hand__cmd stop           \t# stop multi thread session"
	echo -e "$hand__cmd lock           \t# consume a thread"
	echo -e "$hand__cmd unlock         \t# release a thread"
	echo -e "$hand__cmd test [<max_thread=5> [<task_count=10>]]"
	echo -e "                          \t# test"
	echo -e "$hand__cmd -h/--help      \t# show help"
	;;
"start")
	shift
	local max=5
	if [ "$1" != "" ]; then
		max=$1
	fi

	local tmp_fifofile="/tmp/$$.fifo"
	mkfifo $tmp_fifofile      # 新建一个fifo类型的文件
	exec 6<>$tmp_fifofile     # 将fd6指向fifo类型
	rm $tmp_fifofile    #删也可以

	for ((i=0;i<${max};i++));do
		echo
	done >&6

	hand echo green "[$$] Multi-thread init. max_thread=$max"
	hand work setprop thread.count.$$ 0 -- pure
	;;
"lock")
	read -u6
	hand work modprop thread.count.$$ +1 -- pure
	local count=`hand work getprop thread.count.$$ -- pure`
	hand echo green "[+] Runing: $count"
	;;
"unlock")
	echo >&6
	hand work modprop thread.count.$$ -1 -- pure
	local count=`hand work getprop thread.count.$$ -- pure`
	hand echo green "[-] Runing: $count"
	;;
"stop")
	wait
	exec 6>&-
	hand echo green "[$$] Multi-thread COMPLETED!"
	hand work setprop thread.count.$$ -- pure
	;;
"test")
	shift
	hand time start "testing thread"
	hand thread start $1
	shift
	local test_count=10
	if [ ! -z $1 ]; then
		test_count=$1
	fi

	while [ $test_count -gt 0 ] ; do
		((test_count-=1))
		local random=$RANDOM
		hand thread lock
		(
			hand echo do sleep $((random/6000))
			# hand echo do sleep 0.2222
			hand thread unlock
		) &
	done

	hand thread stop
	hand time end
	;;
*)
	hand echo error "$sub unsupported"
	;;
esac
