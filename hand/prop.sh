# get or set prop

# hand prop set test hello
# hand prop get test

# echo "prop.sh: props_file=$props_file"
hand_prop()
{
	# get current work name
	if [ ! "$hand_work__name" ]; then
		echo "\$hand_work__name not defined!!!"
		return 1
	fi

	# get props file name by work name
	local props_file="$hand__config_path/${hand_work__name}.props"
	if [ ! -f "$props_file" ]; then
		touch $props_file
	fi

	local sub=$1
	local key=$2

	## start to get
	if [ "get" == "$sub" ]; then

		if [ "$key" == "" ]; then
			# show all props
			# hand echo do cat $props_file
			cat $props_file
		else
			# cat $props_file | grep $1 | sed 's/.*=//g'
			local value=`grep $key $props_file | sed 's/.*=//g'`
			if [ "$value" == "" ]; then
				hand echo warn "prop $key not defined, hand prop set $key [value]"
				return 1
			fi
			echo $value
		fi
		return 0

	# start to set
	elif [ "set" == "$sub" ]; then

		if [ "$key" == "" ]; then
			# echo "key is null"
			return 1
		fi

		local value=$3

		# if [ "$value" == "" ]; then
		# 	# echo "value is null"
		# 	return 1
		# fi

		if [ ! -f "$props_file" ]; then
			# create props file
			touch $props_file
		fi

		# search key in props file, get line number
		local line=`sed -n -e "/${key}=/=" $props_file`

		# modify props file
		if [ "$line" == "" ]; then
			# echo "new prop 2"
			echo "${key}=${value}" >> $props_file
		else
			# echo "line=$line"
			sed -i "${line}c ${key}=${value}" $props_file
		fi

		return 0
	fi

	# some error occurs
	return 1
}

# hand_prop "$@"