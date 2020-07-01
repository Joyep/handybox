

function hand_cd_git()
{
	local path1
	path1=`hand --pure git gettop`
	if [ $? -ne 0 ]; then
		echo $path1
		hand echo error "hand git gettop error!"
		return 1
	fi
	# echo path1=$path1
	# path1=`hand__get_last $path1`
	if [[ ! -d "$path1" ]]; then
		hand echo red "git dir not found!"
		return 1
	fi

	cd $path1
}

hand_cd_git__help()
{
	echo "切换到当前目录所在的git根目录"
}
