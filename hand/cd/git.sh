

function hand_cd_git()
{
	local path
	path=$(hand git gettop)
	if [ $? -ne 0 ]; then
		echo $path
		hand echo error "hand git gettop error!"
		return 1
	fi

	# echo $path

	# path=`echo $path | awk -F " " '{print $NF}'`
	path=`hand__get_lastline $path`

	if [ ! -d "$path" ]; then
		hand echo red "git dir not found!"
		return 1
	fi

	cd $path
}

# cd_git "$@"
