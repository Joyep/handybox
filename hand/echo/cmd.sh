hand_echo__help()
{
	echo "增加echo功能, 能显示颜色和tag"
	echo -e "$1 do    \t--- 显示并执行某个命令"
	echo -e "$1 info  \t--- 信息"
	echo -e "$1 error \t--- 错误"
	echo -e "$1 green \t--- 绿色"
	echo -e "$1 yellow\t--- 黄色"
	echo -e "$1 red   \t--- 红色"


}

hand_echo()
{
	local sub=$1
    shift
	case $sub in
	"do")
		hand_echo__do "$@"
		;;
	"error"):
		hand_echo__error "$@"
		;;
	"info"):
		hand_echo__info "$@"
		;;
	"warn"):
		hand_echo__warn "$@"
		;;
	"red"):
		hand_echo__red "$@"
		;;
	"green"):
		hand_echo__green "$@"
		;;
	"yellow"):
		hand_echo__yellow "$@"
		;;
	"white"):
		hand_echo__white "$@"
		;;
	"debug"):
		hand_echo__debug "$@"
		;;
	*)
		hand_echo__error "$sub not support"
	esac
	# return $?
}

function hand_echo__debug()
{
	if [ "$hand__debug_disabled" = "1" ]; then
		echo $*
	fi
}

function hand_echo__do()
{
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

	echo -e "\033[33m[do] $cmd\033[0m"

	eval $cmd
}
function hand_echo__error()
{
    echo -e "\033[31m[ERROR] $*\033[0m"
}

function hand_echo__white()
{
    echo -e $*
}

function hand_echo__green()
{
    echo -e "\033[32m$*\033[0m"
}

function hand_echo__info()
{
     echo "[INFO] $*"
}

function hand_echo__red()
{
    echo -e "\033[31m$*\033[0m"
}

function hand_echo__warn()
{
     echo -e "\033[33m[WARN] $*\033[0m"
}

function hand_echo__yellow()
{
    echo -e "\033[33m$*\033[0m"
}
