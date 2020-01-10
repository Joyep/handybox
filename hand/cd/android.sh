
# cd android [sub_module_name]
function hand_cd_android()
{

	# just cd to android root path1
	if [ $# -eq 0 ]; then
		cd_android_root
		return
	fi

	# cd to android sub path1
	# sub path1 come from sub_module_name
	# get from `hand android getpath1 [sub_module_name]`
	path1=`hand --silence android getpath $1`
	if [ $? -ne 0 ]; then

		echo $path1

		# sub path1 not found
		# maybe sub_module_name is a path1
		path1=$1
	fi

	# echo $path1

	# if path1 is an absolute dir
	if [ "${path1:0:1}" = "/" ]; then
        cd $path1
        return
    fi

    # path1 is related to android root path1
    cd_android_root $path1

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
