

function hand_echo()
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
	"debug"):
		hand_echo__debug "$@"
		;;
	*)
		hand_echo__error "$sub not support"
	esac
	return $?
}

function hand_echo__debug()
{
	if [ "$hand__debug" == "1" ]; then
		echo $*
	fi
}

function hand_echo__do()
{
	echo -e "\033[33m[do] $@\033[0m"
    "$@"
    return $?
}
function hand_echo__error()
{
    echo -e "\033[31m[ERROR] $*\033[0m"
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

