

#cmd <type> <files...>
function hand_adb_push()
{
    # detect if android device connected
    hand adb detect
    [[ $? -ne 0 ]] && return 1

    # remount before push
    adb remount

    local sub=$1
    shift
	case $sub in
	"chmod")
		push_and_chmod $* 
		;;
	"etc")
		push_and_chmod 644 system/etc $*
		;;
	"lib")
		push_and_chmod 644 system/lib $*
		;;
	"lib64")
		push_and_chmod 644 system/lib64 $*
		;;
	"libhw")
		push_and_chmod 644 system/lib/hw $*
		;;
	"lib64hw")
		push_and_chmod 644 system/lib64/hw $*
		;;
	"bin")
		push_and_chmod 755 system/bin $*
		;;
	"system")
		push_and_chmod 755 system $*
		;;
    "app")
        push_and_chmod null system/app $*
        ;;
    "privapp")
        push_and_chmod null system/priv-app $*
        ;;
    "path")
        local path1=$1
        shift
        push_and_chmod null $path1 $*
        ;;
    "i2c_test")
        hand adb push bin $hand__path/libs/libi2c/prebuild/arm/i2c_test
        ;;
	*)
		hand echo error "push $sub not support"
		;;
	esac
}

#push file to device path with chmod
#push $file $path1 $mod
function adb_push_file()
{
    local f=$1
    local path1=$2
    local mod=$3

    hand echo yellow "push file $f to $path1 ..."
    #echow "adb push $f $path1"
    hand echo do adb push $f $path1
    [ $? -ne 0 ] && hand echo error "$file ---x $path1 failed" && return 1
    
    hand echo green "$file ---> $path1 ok"

    if [ "$mod" != "" ]; then
        #hand echo info "chmod $mod of $file..."
        hand echo do adb shell "chmod $mod $path1/${f##*/}"
        hand echo do adb shell "ls $path1/${f##*/} -al"
    fi

    return 0
}

#push dir to device path1 with chmod
#push $dir $path1 $mod
function adb_push_dir()
{
    local d=${1%/}
    local path1=${2%/}
    local mod=$3

    local dname=${d##*/}

    if [ "$dname" = "" ]; then
        echor "dname is valid"
        return 1
    fi
    
    hand echo yellow "push dir $d to $path1 ..."

    #echow "adb shell mkdir $path1/$d"
    hand echo do adb shell mkdir $path1/${dname}
    [ $? -ne 0 ] && hand echo error "mkdir failed" && return 1

    local file=
    for file in `ls $d`
    do
        #echo ">>>" $file
        local filepath=$d/$file
        if [ -d $filepath ]; then
            adb_push_dir $filepath $path1/$dname $mod
        elif [ -L $filepath ]; then
            hand echo warn "$file is a symbolic link, ignore!"
            continue
        elif [ -f $filepath ]; then
            adb_push_file $filepath $path1/$dname $mod
        else
            hand echo error "$filepath is not a file or directory!"
        fi
        if [ $? -ne 0 ]; then
            #hand echo error "for $filepath failed!!"
            return 1
        fi
    done

    return 0
}

#push $mod $path $files...
function push_and_chmod()
{
    local mod=""
    if [ "$1" != "null" ]; then
        mod=$1
    fi
    local path1=$2
    shift
    shift

    echo path1=$path1
    echo mod=$mod
    echo files=$*

    local file=
    for file in $*
    do
        # if file not exist, try related to android top dir
        if [ ! -e $file ]; then
            hand echo warn "file not exist, try android path"
            android_top=`hand android gettop`
            if [ $? -ne 0 ]; then
                hand echo error "android path not found!"
                return 1
            fi
            file=$(android_top)/$file
            if [ ! -e $file ]; then
                hand echo error "$file not found!"
                continue
            fi
        fi

        if [ -d $file ] ; then
            # if file is a dir, then push dir
            adb_push_dir $file $path1 $mod
        elif [ -L $file ]; then
            # if file is a link, ignore!
            hand echo warn "$file is a symbolic link, ignore"
            continue
        elif [ -f $file ] ; then
            # if file is a file, then push file
            adb_push_file $file $path1 $mod
        else
            hand echo error "$file is not a file or directory!"
        fi
        if [ $? -ne 0 ]; then
            hand echo error "something wrong"
            return 1
        fi
    done

    return 0
}
