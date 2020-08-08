#
# 当前work名字 --- 从文件读取
# hand work on  --- 设置到文件
# hand work temp --- 设置到环境
# hand work setprop --- 设置到文件
# hand work getprop --- 从文件读取

# work.sh --work=abc getprop test.abc
# work.sh --work=abc setprop test.abc xxx

# if [ "$1" = "temp" ] || [ "$1" = "on" ] ; then
#     # update work name
#     hand_work__name=$2
# fi
# bash $hand__cmd_dir/work.sh --work=$hand_work__name --hand__config_path=$hand__config_path $*

hand_work__help()
{
	echo "handybox工作区"
	echo -e "$1                \t--- 展示所有工作区"
	echo -e "$1 on <name>      \t--- 切换工作区"
	echo -e "$1 temp <name>    \t--- 临时切换工作区"
	echo -e "$1 remove <name>  \t--- 删除工作区"
	echo -e "$1 getprop <name> \t--- 获取属性"
	echo -e "$1 setprop <name> \t--- 设置属性"
}


# 'hand work'
# 用于改变handybox环境中属性(hand prop)配置
# 必须配合 hand prop 使用

## Used Variables:
# hand_work__name ---  current workspace name

## Usage
# hand work --- show workspaces
# hand work on <name>  --- switch to <name> workspace
# hand work [--work=?] getprop/setprop <propname> [<propvalue>]
hand_work()
{
	# echo $*
	## --work=?
	## --hand__config_path=?
	# hand_work__name="$hand_work__name"
	# hand__config_path="$hand__config_path"
	# while [ true ]; do
	# 	# if [ "$1" == "" ]; then
	# 	# 	break
	# 	# fi
	# 	if [ "${1%=*}" = "--work" ]; then
	# 		hand_work__name=${1#--work=}	
	# 	elif [ "${1%=*}" = "--hand__config_path" ]; then
	# 		hand__config_path=${1#--hand__config_path=}
	# 	else
	# 		break
	# 	fi
	# 	shift
	# done

    # determin work name
	if [ "$hand_work__name" = "" ]; then
        # try read from current file
        hand_work__on `cat $current_file`
	    if [ "$hand_work__name" = "" ]; then
		    hand_work__on "default"
        fi
	fi
	
	# no param
	if [ $# -eq 0 ]; then
		# only show current work
		hand_work__show
		return
	fi

	
	
	# handle sub command
	local sub=$1
	shift
	local ret
	case $sub in
	"on")
		hand_work__on $1
		hand_work__show
		;;
	"temp")
		hand_work__temp_on $1
		hand_work__show
		;;
	"getprop")
		hand_work_getprop $*
		;;
	"setprop")
		hand_work_setprop $*
		;;
	"remove")
		hand_work_remove $*
		hand_work__show
		;;
	*)
		hand echo error "$sub not support"
		;;
	esac
}

# work on a workspace, only effect in current shell environment
hand_work__temp_on()
{
    if [ $# -eq 0 ]; then
        hand echo error "no work name"
        return 1
    fi
    hand_work__name=$1
}

# work on a workspace and write work to file
hand_work__on()
{
	if [ $# -eq 0 ]; then
        hand echo error "no work name"
        return 1
    fi

    hand_work__temp_on $1

	# write current work name to file
	echo $hand_work__name > $hand__config_path/current_work
	
	# touch prop file
	touch $hand__config_path/${hand_work__name}.props	
}

# remove a workspace
hand_work_remove()
{
	if [ $# -eq 0 ]; then
        hand echo error "no work name"
        return 1
    fi

	rm 	$hand__config_path/${1}.props
    if [ "$hand_work__name" = "$1" ]; then
        hand_work__on default
    fi
}

hand_work__show()
{
	# local default_name='default'
	# local current_file="$hand__config_path/current_work"

	# get current hand work name
	# if [ ! "$hand_work__name" ]; then
	# 	echo "\$hand_work__name is empty, read from $current_file"
	# 	hand_work__name=`cat $current_file`
	# fi

	# if [ ! "$hand_work__name" ]; then
	# 	echo "work file $current_file is empty! so use $default_name as default"
	# 	hand_work__name=$default_name
	# fi

	# update it
	# if [ ! "$hand_work__name" ]; then
	# 	hand_work__on $default_name
	# fi

	echo "work space:"
	for i in `ls $hand__config_path/*.props`
	do
		local name=${i##*\/}
		name=${name%.*}

		if [[ ! ${name//_*} ]]; then
			continue
		fi

		if [ "$hand_work__name" = "$name" ]; then
			echo "  *  "$name
		else
			echo "     "$name
		fi
	done
}

# get prop
hand_work_getprop()
{
	local SED="sed"
	if [ `uname` = "Darwin" ]; then
		SED="gsed"
	fi

    # get global props file name
	local g_props_file="$hand__config_path/_global.props"
	if [ ! -f "$g_props_file" ]; then
		touch $g_props_file
	fi

	# get current props file name
	local props_file="$hand__config_path/${hand_work__name}.props"
	if [ ! -f "$props_file" ]; then
		touch $props_file
	fi

	local key=$1
	if [ "$key" = "" ]; then
		# show all props
		# hand echo do cat $props_file
		hand echo green "--- $hand_work__name ---"
		cat $props_file
		hand echo green "--- global ---"
		cat $g_props_file
	else
		# cat $props_file | grep $1 | $SED 's/.*=//g'
		local value=`grep ${key}= $props_file | $SED 's/.*=//g'`
		if [[ $value = "" ]]; then
			# hand echo warn "prop $key not defined, hand prop set $key [value]"
			local value=`grep ${key}= $g_props_file | $SED 's/.*=//g'`
			if [[ $value = "" ]] && [[ $props_file != $g_props_file ]]; then
				hand echo warn "prop $key not defined"
				# hand echo warn "use 'hand prop set [-g] $key [value]' to set"
				return 1
			fi
		fi
		echo $value
	fi
	return 0
}

# setprop [-g] key value
hand_work_setprop()
{
    local SED
	if [ `uname` = "Darwin" ]; then
		SED="gsed"
	else
        SED="sed"
    fi

	local set_file
	if [ "$1" = "-g" ]; then
		# set global prop
	    set_file="$hand__config_path/_global.props"
		shift
	else
	    set_file="$hand__config_path/${hand_work__name}.props"
    fi

    if [ $# -eq 0 ]; then
        hand echo error "no key"
        return 1
    fi

	local key=$1
	if [ "$key" = "" ]; then
		hand echo error "key is null"
		return 1
	fi
    

	local value=$2

	# search key in props file, get line number
	local line=`$SED -n -e "/${key}=/=" $set_file`
	if [[ ! $line ]]; then
		# echo key line not found
		if [[ $value ]]; then
			# new prop
			echo "${key}=${value}" >> $set_file
		fi
	else
		# echo key line found
		if [[ ! $value ]]; then
			# echo empty value, should remove this prop
			$SED -i "${line}d" $set_file  
		else
			# echo set prop value
			$SED -i "${line}c ${key}=${value}"  $set_file
		fi
	fi

	return 0

}