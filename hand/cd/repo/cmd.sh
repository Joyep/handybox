hand_cd_repo()
{
	local path1
	path1=`hand -p repo gettop`
	if [ $? -ne 0 ]; then
		# echo $path1
		hand echo error "get repo top failed!!"
		return 1
	fi

	if [[ ! -d "$path1" ]]; then
		hand echo red "repo dir ($path1) is invalid!"
		return 1
	fi

	cd $path1
}

hand_cd_repo__help()
{
	echo "切换到当前目录所在的repo根目录"
}
