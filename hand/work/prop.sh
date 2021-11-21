#!/bin/bash

#
# Depend on files:
#       $hand__path/config/$hand__configs[*]/_global.props
#       $hand__path/config/$hand__configs[*]/<work_name>.props
#
# Depend on global variable:
#       $hand_work__name

#
# params: getprop|setprop|modprop [-g|-b] <key> [<value>]
#
main() {
    if [ $# -lt 1 ]; then
        return
    fi

	local SED="sed"
	if [ `uname` = "Darwin" ]; then
		SED="gsed"
	fi

	hand__configs=($hand__configs)
    local sub=$1
    shift

	# parse options
	local modify=0
	local base=0
	local global=0
	while true; do
		if [ "$1" = "-g" ]; then
			global=1
			shift
			continue
		elif [ "$1" = "-b" ]; then
			shift
			base=1
			continue
		fi
		break
	done

    case $sub in
        "getprop")
            hand_work_getprop $@
            ;;
        "setprop")
			hand_work_setprop $@
            ;;
		"modprop")
			modify=1
			hand_work_setprop $@
            ;;
    esac
}


# getprop <key>
hand_work_getprop()
{
	local filelist=
	local file=
	local config=

	if [ $base -eq 1 ]; then
		if [ $global -eq 1 ]; then
			# get from base global
			# search: all base global props
			for config in ${hand__configs[@]:1}; do
				file=$hand__path/config/$config/_global.props
				if [ -f $file ]; then
					filelist="$filelist $file"
				fi
			done
		else
			# get from base work
			# search: all base current work props
			for config in ${hand__configs[@]:1}; do
				file=$hand__path/config/$config/$hand_work__name.props
				if [ -f $file ]; then
					filelist="$filelist $file"
				fi
			done
		fi
	else
		if [ $global -eq 1 ]; then
			# get from user global
			# search: all global props
			for config in ${hand__configs[@]}; do
				file=$hand__path/config/$config/_global.props
				if [ -f $file ]; then
					filelist="$filelist $file"
				fi
			done
		else
			# get from user work
			# search: all current work and global props
			for config in ${hand__configs[@]}; do
				file=$hand__path/config/$config/$hand_work__name.props
				if [ -f $file ]; then
					filelist="$filelist $file"
				fi
			done
			for config in ${hand__configs[@]}; do
				file=$hand__path/config/$config/_global.props
				if [ -f $file ]; then
					filelist="$filelist $file"
				fi
			done
		fi
	fi
	
	# echo search ${filelist}
	local key=$1
	if [ "$key" = "" ]; then
		echo key is empty!
		for file in $filelist ; do
			# if [ ! -f $file ]; then
			# 	continue
			# fi
			echo "--- ${file//*\/} ---"
			cat $file
		done
	else
		local value=
		for file in $filelist ; do
			# if [ ! -f $file ]; then
			# 	file=
			# 	continue
			# fi
			value=`grep -e "^${key}=" $file | $SED 's/.*=//g'`
			if [[ "$value" != "" ]]; then
				break
			fi
			file=
		done

		if [ "$file" != "" ]; then
			if [ $hand__debug_disabled -eq 0 ]; then
				echo "[ * ]" $file
			fi
			echo $value
		else
			echo "WARN: prop \"$key\" not defined"
			return 1
		fi
	fi
	return 0
}

# setprop <key> <value>|<operation>
hand_work_setprop()
{
	if [ $# -eq 0 ]; then
        echo "ERROR: no key"
        return 1
    fi
	local key=$1
	local value=$2

	local file=
	local config=
	local dest_file=
	if [ $base -eq 1 ]; then
		if [ $global -eq 1 ]; then
			# set base global
			# search: all base global props
			dest_file=$hand__path/config/${hand__configs[1]}/_global.props
			for config in ${hand__configs[@]:1}; do
				file=$hand__path/config/$config/_global.props
				if [ -f $file ]; then
					dest_file=$file
					break
				fi
			done
		else
			# set base work
			# search: all base current work props
			dest_file=$hand__path/config/${hand__configs[1]}/$hand_work__name.props
			for config in ${hand__configs[@]:1}; do
				file=$hand__path/config/$config/$hand_work__name.props
				if [ -f $file ]; then
					dest_file=$file
					break
				fi
			done
		fi
	else
		if [ $global -eq 1 ]; then
			# set user global
			# search: user global props
			dest_file=$hand__config_path/_global.props
		else
			# set user work
			# search: user work props
			dest_file=$hand__config_path/$hand_work__name.props
		fi
	fi

	if [ ! -f "$dest_file" ]; then
		touch $dest_file
	fi

	# lock to set property
	{
		flock 200
		# echo "ready to set prop..."
		if [ $modify -eq 1 ]; then
			local old_value=
			old_value=`grep ${key}= $dest_file | $SED 's/.*=//g'`
			if [ "$old_value" = "" ]; then
				echo "ERROR: modprop: key \"$key\" not found"
				return 1
			fi
			# echo old_value: $old_value
			value=`eval echo "\$((${old_value}$value))"`
			# echo "new_value=$value"
		fi

		# echo "will set $key = $value"
		# sleep 5

		# search key in props file, get line number
		local line=`$SED -n -e "/${key}=/=" $dest_file`
		# echo line: $line
		if [[ ! $line ]]; then
			# echo key line not found
			if [[ $value ]]; then
				# new prop
				echo "${key}=${value}" >> $dest_file
			fi
		else
			# echo key line found
			if [[ ! $value ]]; then
				# echo empty value, should remove this prop
				$SED -i "${line}d" $dest_file  
			else
				# echo set prop value
				$SED -i "${line}c ${key}=${value}" $dest_file
			fi
		fi
		if [ $hand__debug_disabled -eq 0 ]; then
			echo "[ * ]" $dest_file
			echo "set $key = $value"
		fi
		# sleep 5
	# } 200<>$dest_file
	} 200<>$hand__config_path/.current_work

	return 0

}


main "$@"
