##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# cmd: echo ${params...}
#           -h/--help          # show help
#           do $any_cmd...     # print and call a command
#           info $any_string   # print info
#           error              # print error
#           debug              # print debug
#           red/yellow/green   # print with color
##


local sub=$1
shift
case $sub in
"-h"|"--help")
	echo "增加echo功能, 能显示颜色和tag"
	echo -e "$hand__cmd do    \t--- 显示并执行某个命令"
	echo -e "$hand__cmd info  \t--- 信息"
	echo -e "$hand__cmd error \t--- 错误"
	echo -e "$hand__cmd debug \t--- 调试打开时打印"
	echo -e "$hand__cmd green \t--- 绿色"
	echo -e "$hand__cmd yellow\t--- 黄色"
	echo -e "$hand__cmd red   \t--- 红色"
	;;
"do")
	# echo $#
	# echo -e "\033[33m[do] $@\033[0m"
	#eval "$@"
	#$@
	local cmd="$1"
	shift
	local p
	for p in "$@" ; do
		cmd="$cmd \"$p\""
	done

	#echo $hand__echodo_disabled
	if [ "$hand__echodo_disabled" = "0" ] || [ "$hand__echodo_disabled" = "" ]; then
	    echo -e "\033[33m[do] $cmd\033[0m"
	    eval $cmd
    else
	    echo -e "\033[33m[FAKE DO] $cmd\033[0m"
    fi
	;;
"error")
    echo -e "\033[31m[ERROR] $*\033[0m"
	;;
"info")
     echo "[INFO] $*"
	;;
"warn")
     echo -e "\033[33m[WARN] $*\033[0m"
	;;
"red")
    echo -e "\033[31m$*\033[0m"
	;;
"green")
    echo -e "\033[32m$*\033[0m"
	;;
"yellow")
    echo -e "\033[33m$*\033[0m"
	;;
"white")
    echo -e $*
	;;
"debug")
	# echo hand__debug_disabled: $hand__debug_disabled
	if [ ! $hand__debug_disabled -ge 1 ]; then
		echo $*
	fi
	;;
*)
	echo -e "\033[31m$hand__cmd: \"$sub\" not support\033[0m"
esac