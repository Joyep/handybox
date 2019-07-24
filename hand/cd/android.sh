
# cd android [sub_module_name]
function hand_cd_android()
{

	# just cd to android root path
	if [ $# -eq 0 ]; then
		cd_android_root
		return
	fi

	# cd to android sub path
	# sub path come from sub_module_name
	# get from `hand android getpath [sub_module_name]`
	path=`hand --silence android getpath $1`
	if [ $? -ne 0 ]; then

		echo $path

		# sub path not found
		# maybe sub_module_name is a path
		path=$1
	fi

	# echo $path

	# if path is an absolute dir
	if [ "${path:0:1}" == "/" ]; then
        cd $path
        return
    fi

    # path is related to android root path
    cd_android_root $path

}

cd_android_root()
{
	local aroot

	aroot=`hand --silence android gettop`
	if [ $? -ne 0 ]; then
		# echo $aroot
		hand echo error "android dir not found!"
		hand echo error "please change directory to android dir, or lunch first"
		return 1
	fi

    if [ ! -d $aroot/$1 ]; then
    	hand echo error "$aroot/$1 is not a dir!"
    	return 1
    fi

	cd $aroot/$1
}
