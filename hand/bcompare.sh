
function hand_bcompare()
{
	local sub=$1
	shift
	case $sub in
	"register")
		hand_bcomapre__register
		;;
	*)
		hand echo error "$sub unsupported"
		;;
	esac
}


function hand_bcomapre__register() {
	if [ $(uname) == "Darwin" ]; then
		registry_file="${HOME}/Library/Application Support/Beyond Compare/registry.dat"
	else
		registry_file="${HOME}/.config/bcompare/registry.dat"
	fi

	# for windows, you should do as below
	#reg delete "HKEY_CURRENT_USER\Software\Scooter Software\Beyond Compare 4" /v CacheID /f
	
	if [ ! -f "$registry_file" ]; then
		hand echo error "File Not Found! $registry_file"
		return 1
	fi
	rm "$registry_file"
	hand echo green "delete $registry_file done!"
}

# hand_bcompare "$@"




