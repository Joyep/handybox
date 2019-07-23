

function hand_cd_repo()
{
	path=$(hand repo gettop)
	if [ $? -ne 0 ]; then
		echo $path
		hand echo error "hand repo gettop error!"
		return 1
	fi

	# echo $path

	# path=`echo $path | awk -F " " '{print $NF}'`
	path=`hand__get_lastline $path`

	if [ ! -d "$path" ]; then
		hand echo red "repo dir not found!"
		return 1
	fi

	cd $path
}


# cd_repo "$@"
