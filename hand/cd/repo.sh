

function hand_cd_repo()
{
	local path1
	path1=`hand --pure repo gettop`
	if [ $? -ne 0 ]; then
		echo $path1
		hand echo error "hand repo gettop error!"
		return 1
	fi

	# path1=`echo $path1 | awk -F " " '{print $NF}'`
	# path1=`hand__get_lastline $path1`
	if [[ ! -d "$path1" ]]; then
		hand echo red "repo dir not found!"
		return 1
	fi

	cd $path1
}

hand_cd_repo__help()
{
	echo "切换到当前目录所在的repo根目录"
}
