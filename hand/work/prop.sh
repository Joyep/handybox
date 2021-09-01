#!/bin/bash

#
# Depend on files:
#       $hand__config_path/_global.props
#       $hand__config_path/<work_name>.props
#
#


#
# params: get/set [-g] <key> [<value>]
#
main() {
    if [ $# -lt 1 ]; then
        return
    fi

	local SED="sed"
	if [ `uname` = "Darwin" ]; then
		SED="gsed"
	fi

    # prepare all props files
	local g_props_file="$hand__config_path/_global.props"
	local g_props_file_base="$hand__config_path/../$hand__base_config/_global.props"
	local props_file="$hand__config_path/${hand_work__name}.props"
	local props_file_base="$hand__config_path/../$hand__base_config/${hand_work__name}.props"

    local sub=$1
    shift

	# parse options
	local modify=0
	local base=0
	local global=0
	local options=
	while true; do
		if [ "$1" = "-g" ]; then
			options="-g"
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

	# determin dest props file
	local dest_file=
	if [ $base -eq 1 ]; then
		if [ $global -eq 1 ]; then
			dest_file=$g_props_file_base
		else
			dest_file=$props_file_base
		fi
	else
		if [ $global -eq 1 ]; then
			dest_file=$g_props_file
		else
			dest_file=$props_file
		fi
	fi

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
	if [ "$dest_file" = "$props_file" ]; then
		if [ "$1" = "-g" ]; then
			filelist="$g_props_file $g_props_file_base"
			shift
		else
			filelist="$props_file $props_file_base $g_props_file $g_props_file_base"
		fi
	else
		# determined a dest file
		filelist=$dest_file
	fi
	local key=$1
	local file=
	if [ "$key" = "" ]; then
		for file in $filelist ; do
			if [ ! -f $file ]; then
				continue
			fi
			hand echo green "--- ${file//*\/} ---"
			cat $file
		done
	else
		local value=
		for file in $filelist ; do
			if [ ! -f $file ]; then
				file=
				continue
			fi
			value=`grep -e "^${key}=" $file | $SED 's/.*=//g'`
			if [[ "$value" != "" ]]; then
				break
			fi
			file=
		done

		if [ "$file" != "" ]; then
			if [ $hand__debug_disabled -eq 0 ]; then
				echo "[ < ]" $file
			fi
			echo $value
		else
			hand echo warn "prop \"$key\" not defined"
			return 1
		fi
	fi
	return 0
}

# setprop <key> <value>|<operation>
hand_work_setprop()
{
	if [ $# -eq 0 ]; then
        hand echo error "no key"
        return 1
    fi
	local key=$1
	local value=$2

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
				hand echo error "modprop: key \"$key\" not found"
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
			echo "[ > ]" $dest_file
			echo "set $key = $value"
		fi
		# sleep 5
	# } 200<>$dest_file
	} 200<>$hand__config_path/current_work

	return 0

}


main "$@"
