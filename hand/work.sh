
function hand_work()
{
	#no param
	if [ $# -eq 0 ]; then
		hand_work__show
		return $?
	fi

	#more params
	local sub=$1
	shift
	case $sub in
	"--load")
		hand_work__load $*
		;;
	*)
		hand_work__on $sub
		hand_work__show
		;;
	esac
}

function hand_work__show()
{
	echo "work space:"
	for i in ${hand_work__list[@]};
	do 
		if [ "$hand_work__workspace" == "$i" ]; then
			echo "  *  "$i
		else
			echo "     "$i
		fi
	done
}

function hand_work__exist()
{
	for i in ${hand_work__list[@]};
	do
		if [ "$i" == "$1" ]; then
			return 0
		fi
	done
	return 1
}

#load $cmd
function hand_work__load()
{
	${1}__workspace_default
}


function hand_work__on()
{
	if [ "$1" == "" ]; then
		hand echo error "give me a workspace name"
		return 1
	fi
	
	if [ "$hand_work__workspace" == "$1" ]; then
		hand echo warn "already on workspace $1"
		hand_work__workspace_$1
		return 0
	fi

	hand_work__exist $1
	if [ $? -ne 0 ]; then
		hand echo error "workspace not found! ($1)"
		return 1
	fi
	hand_work__workspace_$1
	hand_work__workspace=$1
	return 0
}

#init workspace
source $hand__config_path/workspace.sh
