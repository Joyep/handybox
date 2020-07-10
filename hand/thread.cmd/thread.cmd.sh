
function hand_thread()
{
	local sub=$1
	shift
	case $sub in
	"up")
		hand_thread_up $*
		;;
	"down")
		hand_thread_down $*
		;;
	"init")
		hand_thread_init $*
		;;
	"clean")
		hand_thread_clean $*
		;;
	*)
		hand echo error "$sub unsupported"
		;;
	esac
}

hand_thread_up()
{
	echo >&6
}

hand_thread_down()
{
	read -u6
}

hand_thread_clean()
{
	wait
	exec 6>&-
	hand echo green "multi thread with fifo COMPLETED!"
}


# init multi thread
# $1 max thread
# $2 fd number
hand_thread_init()
{
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

	hand echo green "multi thread with fifo INIT! fd=6 max_thread=$max"
}

# hand_thread "$@"