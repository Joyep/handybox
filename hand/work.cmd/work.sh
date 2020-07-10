
# 'hand work'
# 用于改变handybox环境中属性(hand prop)配置
# 必须配合 hand prop 使用

## Used Variables:
# work_name ---  current workspace name

## Usage
# hand work --- show workspaces
# hand work on <name>  --- switch to <name> workspace
# hand work [--work=?] getprop/setprop <propname> [<propvalue>]
hand_work()
{
	# echo $*
	## --work=?
	## --config_dir=?
	work_name=""
	config_dir=""
	while [ true ]; do
		# if [ "$1" == "" ]; then
		# 	break
		# fi
		if [ "${1%=*}" = "--work" ]; then
			work_name=${1#--work=}	
		elif [ "${1%=*}" = "--config_dir" ]; then
			config_dir=${1#--config_dir=}
		else
			break
		fi
		shift
	done

	if [ "$work_name" = "" ]; then
		work_name="default"
	fi
	
	# no extra param
	if [ $# -eq 0 ]; then
		# only show current work
		hand_work__show
		return
	fi

	# get global props file name
	g_props_file="$config_dir/_global.props"
	if [ ! -f "$g_props_file" ]; then
		touch $g_props_file
	fi

	# get current work name
	props_file="$config_dir/${work_name}.props"
	if [ ! -f "$props_file" ]; then
		touch $props_file
	fi
	
	# handle sub command
	local sub=$1
	shift
	local ret
	case $sub in
	"on")
		hand_work__on "$1"
		ret=$?
		if [ $ret -ne 0 ]; then
			return $ret 
		fi
		hand_work__show
		;;
	"temp")
		work_name=$1
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

# work on a workspace and write work to file
hand_work__on()
{
	if [ "$1" == "" ]; then
		hand echo error "no work name!"
		return 1
	fi

	work_name=$1

	# write current work name to file
	local current_file="$config_dir/current_work"
	echo $work_name > $current_file
	
	# touch prop file
	touch $config_dir/${work_name}.props	
}

hand_work_remove()
{
	if [ "$1" == "" ]; then
		hand echo error "no work name!"
		return 1
	fi

	rm 	$config_dir/${1}.props

	hand_work__on default
}

hand_work__show()
{
	local default_name='default'
	local current_file="$config_dir/current_work"

	# get current hand work name
	if [ ! "$work_name" ]; then
		echo "\$work_name is empty, read from $current_file"
		work_name=`cat $current_file`
	fi

	# if [ ! "$work_name" ]; then
	# 	echo "work file $current_file is empty! so use $default_name as default"
	# 	work_name=$default_name
	# fi

	# update it
	if [ ! "$work_name" ]; then
		hand_work__on $default_name
	fi

	echo "work space:"
	for i in `ls $config_dir/*.props`
	do
		local name=${i##*\/}
		name=${name%.*}

		if [[ ! ${name//_*} ]]; then
			continue
		fi

		if [ "$work_name" = "$name" ]; then
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

	local key=$1
	if [ "$key" = "" ]; then
		# show all props
		# hand echo do cat $props_file
		hand echo green "--- $work_name ---"
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
	local SED="sed"
	if [ `uname` = "Darwin" ]; then
		SED="gsed"
	fi

	local set_file=$props_file
	if [[ $1 = '-g' ]]; then
		# set global prop
		set_file=$g_props_file
		shift
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

hand_work $*