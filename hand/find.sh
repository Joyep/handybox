
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

# find $path -name "$name"
function hand_find_name()
{

    local path=$2

    if [ ! "$path" ]; then
        path="."
    fi

    find $path -name "$1"
}

# hand_find "$@"
