
help()
{
	echo "切换到当前目录所在的repo根目录"
}

hand_cd_repo()
{
	local path1
	path1=`hand --pure repo gettop`
	if [ $? -ne 0 ]; then
		echo $path1
		hand echo error "hand repo gettop error!"
		return 1
	fi

	if [[ ! -d "$path1" ]]; then
		hand echo red "repo dir not found!"
		return 1
	fi

	cd $path1
}

# entry
if [ "$1" = "--help" ]; then
	shift
	help $*
else
	hand_cd_repo
fi

