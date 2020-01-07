
function hand_find()
{
	local sub=$1
	shift
	case $sub in
	"name")
		hand_find_name "$@"
		;;
	*)
		hand echo error "$sub unsupported"
		;;
	esac
}

# find $path1 -name "$name"
function hand_find_name()
{

    local path1=$2

    if [ ! "$path1" ]; then
        path1="."
    fi

    find $path1 -name "$1"
}

# hand_find "$@"
