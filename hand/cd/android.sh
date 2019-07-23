
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
	path=`hand android getpath $1`
	if [ $? -ne 0 ]; then

		hand android getpath $1
		
		# sub path not found
		# maybe sub_module_name is a path
		path=$1

		# cd to android root path
		# hand echo warn "no sub path found by $1"
		# cd_android_root
		# return
	else 
		# last line is sub path
		# path=`echo $path | awk -F " " '{print $NF}'`
		path=`hand__get_lastline $path`
	fi

	# echo $path

	# if [ ! -d $path ]; then
	# 	hand echo warn "$path is not a dir!"
	# 	cd_android_root
	# 	return
	# fi

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
	local path
    if [ -z $TARGET_PRODUCT ]; then
    	# path=$(hand android gettop)
    	# path=`hand android gettop | awk -F " " '{print $NF}'`
    	path=`hand android gettop`
    	if [ $? -ne 0 ]; then
    		# gettop failed
    		echo $path
    		path=""
    	fi
    	# path=`echo $path | awk -F " " '{print $NF}'`
    	path=`hand__get_lastline $path`
    else
    	path=${OUT%out*}
    fi
	if [ "$path" == "" ]; then
		hand echo error "android dir not found!"
		hand echo error "please change directory to android dir, or lunch first"
		return 1
	fi

	cd $path/$1
}

# cd_android "$@"
