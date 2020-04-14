#
# 1. 跳转到编译目录
# 2. 根据传入的编译信息进行编译
#
hand_android_make()
{
	local sub=$1
    shift

    # echo 1=$1
    # echo 2=$2
    # echo 3=$3
    # echo 4=$4

	case $sub in
	"kernel")
		hand_android_make__kernel "$@"
		;;
	"uboot")
		hand_android_make__uboot "$@"
		;;
	esac
}


#make $arch $defconfig $img [-f]
hand_android_make__kernel()
{
	# local cur_path=`pwd`;
	hand cd android kernel;
    if [ $? -ne 0 ]; then
    	hand echo error "kernel dir not found! exit make"
        return 1
    fi

	local arch=$1;
    local defconfig=$2;
    local img=$3;
    local force=$4;

    if [ "$force" = "-f" ]; then
        hand echo do make mrproper;
    fi;
    hand echo do make ARCH=$arch $defconfig;
    hand echo do make ARCH=$arch $img -j8;

    # cd $cur_path
}

#make $arch $defconfig $func [-f]
hand_android_make__uboot()
{
	# local cur_path=`pwd`;
	hand cd android uboot
    if [ $? -ne 0 ]; then
    	hand echo error "uboot dir not found! exit make"
        return 1
    fi
    # echo 111

	local arch=$1;
    local defconfig=$2;
    local func=$3
    local force=$4;
   
    if [ "$force" = "-f" ]; then
        hand echo do make mrproper;
    fi;
    hand echo do make $defconfig;
    if [[ $arch != "" ]]; then
        hand echo do make ARCHV=$arch -j8;
    else
        hand echo do $func
    fi
    

    # cd $cur_path
}


# hand_android_make "$@"