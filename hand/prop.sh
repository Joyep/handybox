# get or set prop

# hand prop set name value
# hand prop get name
# hand prop set -g name value

# echo "prop.sh: props_file=$props_file"
hand_prop()
{
	# get global props file name
	local g_props_file="$hand__config_path/_global.props"
	if [ ! -f "$g_props_file" ]; then
		touch $g_props_file
	fi

	# get current work name
	local props_file=
	if [ "$hand_work__name" ]; then
		
		# get props file name by work name
		local props_file="$hand__config_path/${hand_work__name}.props"
		if [ ! -f "$props_file" ]; then
			touch $props_file
		fi
	else
		echo "\$hand_work__name not defined!!!"
		return 1
	fi
	
	local sub=$1	

	## start to get
	if [ "get" = "$sub" ]; then
		local key=$2
		if [ "$key" = "" ]; then
			# show all props
			# hand echo do cat $props_file
			hand echo green "--- $hand_work__name ---"
			cat $props_file
			hand echo green "--- global ---"
			cat $g_props_file
		else
			# cat $props_file | grep $1 | sed 's/.*=//g'
			local value=`grep ${key}= $props_file | sed 's/.*=//g'`
			if [[ $value = "" ]]; then
				# hand echo warn "prop $key not defined, hand prop set $key [value]"
				local value=`grep ${key}= $g_props_file | sed 's/.*=//g'`
				if [[ $value = "" ]] && [[ $props_file != $g_props_file ]]; then
					hand echo warn "prop $key not defined"
					hand echo warn "use 'hand prop set [-g] $key [value]' to set"
					return 1
				fi
			fi
			echo $value
		fi
		return 0

	# start to set
	elif [ "set" = "$sub" ]; then
		set_file=$props_file
		if [[ $2 = '-g' ]]; then
			# set global prop
			set_file=$g_props_file
			shift
		fi

		local key=$2

		if [ "$key" = "" ]; then
			# echo "key is null"
			return 1
		fi

		local value=$3

		# if [ "$value" = "" ]; then
		# 	# echo "value is null"
		# 	return 1
		# fi

		# if [ ! -f "$props_file" ]; then
		# 	# create props file
		# 	touch $props_file
		# fi

		# echo set_file=$set_file

		# search key in props file, get line number
		local line=`sed -n -e "/${key}=/=" $set_file`
		if [[ ! $line ]]; then
			# key line not found
			if [[ $value ]]; then
				# new prop
				echo "${key}=${value}" >> $set_file
			fi
		else
			# key line found
			if [[ ! $value ]]; then
				# empty value, should remove this prop
				sed -i "${line}d" $set_file  
			else
				# set prop value
				sed -i "${line}c ${key}=${value}" $set_file
				# if [[ $set_file = $g_props_file ]]; then
				# 	# when set global delete prop from current work prop file
				# 	sed -i "${line}d" $props_file 
				# fi
			fi
		fi

		return 0
	fi

	# unsupport sub command
	# some error occurs
	return 1
}

# hand_prop "$@"