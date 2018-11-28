

function hand_cd_android()
{

	if [ $# -eq 0 ]; then
		hand_cd_android__root
		return
	fi

	local path=`hand --silence android getpath $1`
	if [ "$path" == "" ]; then
		#hand echo warn "path ($1) not defined, prefer to hand/android/getpath.sh"
		hand_cd_android__root $1
		return
	fi

    if [ "${path:0:1}" == "/" ]; then
        cd $path
        return
    fi

	hand_cd_android__root $path
}

hand_cd_android__root()
{
	local path
    if [ -z $TARGET_PRODUCT ]; then
    	path=$(hand --silence android gettop)
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

#path $pathname
hand_cd_android__path()
{
	local path=`hand --silence android getpath $1`
	if [ "$path" == "" ]; then
		hand echo error "path ($1) not defined, prefer to hand/android/getpath.sh"
		return 1
	fi
	hand_cd_android__root $path
}

hand_cd_android__kernel()
{
	local kernelpath=`hand --silence android getpath kernel`
	if [ "$kernelpath" == "" ]; then
		hand echo error "kernel path not defined, prefer to hand/android/getpath.sh"
		return 1
	fi
	hand_cd_android__root $kernelpath
}
hand_cd_android__defconfig()
{
	local archpath=`hand --silence android getpath defconfig`
	if [ "$archpath" == "" ]; then
		hand echo error "arch path not defined, prefer to hand/android/getpath.sh"
		return 1
	fi
	hand_cd_android__root $archpath
}
hand_cd_android__dts()
{
	local path=`hand --silence android getpath dts`
	if [ "$path" == "" ]; then
		hand echo error "arch path not defined, prefer to hand/android/getpath.sh"
		return 1
	fi
	hand_cd_android__root $path
}
hand_cd_android__device()
{
	hand_cd_android__root device/tablet/${TARGET_PRODUCT#*full_}
}
