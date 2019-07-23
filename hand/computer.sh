

function hand_computer()
{
	local sub=$1
	shift
	case $sub in
	"hostname")
		computer_hostname "$@"
		;;
	esac
}

function computer_hostname()
{
	local computer=`whoami`_`hostname`
	echo ${computer%.*}
}

# computer "$@"


