

#cmd <type> <files...>
function hand_adb_push()
{
    hand adb detect
    [[ $? -ne 0 ]] && return 1
    
    local sub=$1
    shift
	case $sub in
	"chmod")
		hand_adb_push__chmod $* 
		;;
	"lib")
		hand_adb_push__chmod 644 system/lib $*
		;;
	"lib64")
		hand_adb_push__chmod 644 system/lib64 $*
		;;
	"libhw")
		hand_adb_push__chmod 644 system/lib/hw $*
		;;
	"lib64hw")
		hand_adb_push__chmod 644 system/lib64/hw $*
		;;
	"bin")
		hand_adb_push__chmod 755 system/bin $*
		;;
	"system")
		hand_adb_push__chmod 755 system $*
		;;
    "app")
        hand_adb_push__chmod null system/app $*
        ;;
    "path")
        local path=$1
        shift
        hand_adb_push__chmod null $path $*
        ;;
	*)
		hand echo error "push $sub not support"
		;;
	esac
}

#push file to device path with chmod
#push $file $path $mod
function hand_adb_push__file()
{
    local f=$1
    local path=$2
    local mod=$3

    hand echo yellow "push file $f to $path ..."
    #echow "adb push $f $path"
    hand echo do adb push $f $path
    [ $? -ne 0 ] && hand echo error "$file ---x $path failed" && return 1
    
    hand echo green "$file ---> $path ok"

    if [ "$mod" != "" ]; then
        #hand echo info "chmod $mod of $file..."
        hand echo do adb shell "chmod $mod $path/${f##*/}"
        hand echo do adb shell "ls $path/${f##*/} -al"
    fi

    return 0
}

#push dir to device path with chmod
#push $dir $path $mod
function hand_adb_push__dir()
{
    local d=${1%/}
    local path=${2%/}
    local mod=$3

    local dname=${d##*/}

    if [ "$dname" == "" ]; then
        echor "dname is valid"
        return 1
    fi
    
    hand echo yellow "push dir $d to $path ..."

    #echow "adb shell mkdir $path/$d"
    hand echo do adb shell mkdir $path/${dname}
    [ $? -ne 0 ] && hand echo error "mkdir failed" && return 1

    local file=
    for file in `ls $d`
    do
        #echo ">>>" $file
        local filepath=$d/$file
        if [ -d $filepath ]; then
            hand_adb_push__dir $filepath $path/$dname $mod
        elif [ -L $filepath ]; then
            hand echo warn "$file is a symbolic link, ignore!"
            continue
        elif [ -f $filepath ]; then
            hand_adb_push__file $filepath $path/$dname $mod
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
function hand_adb_push__chmod()
{
    local mod=""
    if [ "$1" != "null" ]; then
        mod=$1
    fi
    local path=$2
    shift
    shift

    echo path=$path
    echo mod=$mod
    echo files=$*

    local file=
    for file in $*
    do
        if [ ! -e $file ]; then
            hand --load android gettop
            file=$(hand_android_gettop)/$file
            if [ ! -e $file ]; then
                hand echo error "$file not found!"
                continue
            fi
        fi

        if [ -d $file ] ; then
            hand_adb_push__dir $file $path $mod
        elif [ -L $file ]; then
            hand echo warn "$file is a symbolic link, ignore"
            continue
        elif [ -f $file ] ; then
            hand_adb_push__file $file $path $mod
        else
            hand echo error "$file is not a file or directory!"
        fi
        if [ $? -ne 0 ]; then
            return $?
        fi
    done

    return 0
}
