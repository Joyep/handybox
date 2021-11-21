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


# local RED='\e[1;31m'       # 红
# local GREEN='\e[1;32m'   # 绿
# local YELLOW='\e[1;33m'  # 黄
# local BLUE='\e[1;34m'    # 蓝
# local PINK='\e[1;35m'    # 粉红
# local SKY='\e[96m'       # Sky
# local RES='\e[0m'        # 清除颜色

local sub=$1
shift
case $sub in
"-h"|"--help")
	echo "Enhance the function of echo, support show color and tag"
	echo -e "`hand__color cyan $hand__cmd` `hand__color yellow do \<cmd\>`          \t# Show and excute <cmd>"
	echo -e "`hand__color cyan $hand__cmd` `hand__color yellow \"info <content>\"`  \t# Print <content> with info format"
	echo -e "`hand__color cyan $hand__cmd` `hand__color yellow \"error <content>\"` \t# Print <content> with error format"
	echo -e "`hand__color cyan $hand__cmd` `hand__color yellow debug`           \t# Print <content> when debug enabled"
	echo -e "`hand__color cyan $hand__cmd` `hand__color yellow \"[-b|-i|-bg|-li] <color> [<bgcolor>] <content>\"`"
	echo -e "                 \t\t# Print <content> with <color>"
	echo -e "                 \t\t#   -b: bold"
	echo -e "                 \t\t#   -i: italic"
	echo -e "                 \t\t#   -bg: with background color"
	echo -e "                 \t\t#   -li: low intensity color"
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
		hand__color yellow "[do] $cmd"
	    # echo -e "\033[33m[do] $cmd\033[0m"
	    eval $cmd
    else
		hand__color yellow "[FAKE DO] $cmd"
	    # echo -e "\033[33m[FAKE DO] $cmd\033[0m"
    fi
	;;
"error")
	hand__color red "[ERROR] $*"
	;;
"info")
     echo "[INFO] $*"
	;;
"warn")
	hand__color yellow "[WARN] $*"
    #  echo -e "\033[33m[WARN] $*\033[0m"
	;;
"debug")
	# echo hand__debug_disabled: $hand__debug_disabled
	if [ ! $hand__debug_disabled -ge 1 ]; then
		echo $*
	fi
	;;
*)
	# echo -e "\033[31m$hand__cmd: \"$sub\" not support\033[0m"
	echo -e `hand__color $sub $*`
esac