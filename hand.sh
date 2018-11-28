#!/bin/bash

#hand main script


hand__version="1.2.1_20181126"
hand__timestamp=`date +"%s"`
hand__debug=0


function hand__get_file_timestamp()
{
	if [ `uname` == "Darwin" ]; then
		stat -r $1 | awk '{print $(NF-6)}'
	else
		ls -l --time-style=+%s $1 |  awk '{print $(NF-1)}'
	fi
}

function hand__check_function_exist()
{
	declare -f -F $1 > /dev/null
	return $?
}

function hand__get_computer_name()
{
	local computer=`whoami`_`hostname`
	echo ${computer%.*}
    #echo "example"
}

function hand__check_param_exist()
{
	#echo "p1=$*"
	if [ "$1" == "" ]; then
		return 1
	else
		return 0
	fi
}

function hand__help()
{
	echo "============================"
	echo "Welcome to use Handybox!"
	echo "version: $hand__version"
	#echo "timestamp: $hand__timestamp"
	echo "path: $HAND_PATH"
	echo "config: $hand__config_path"
	echo "============================"
}

function hand__echo_debug()
{
	if [ "$hand__debug" == "1" ]; then
		echo $*
	fi
}
#parse $search_path $cmds...
#return function name
function hand__parse_function()
{
	local file=$1
	local p=
	local func="hand"
	shift
	for p in $*
	do
		shift
		echo $p
		func="${func}_${p}"
		file="$file/$p"
		if [ ! -d $file ]; then
			break;
		fi
	done

	if [ -f $file.sh ]; then
		echo $func $file.sh
	else
		echo $file.sh is not a file
	fi
}

function hand__test_start()
{
	hand__start_ms=$[$(date +%s%N)/1000000]
}
#end $label $info
function hand__test_end()
{
	hand__end_ms=$[$(date +%s%N)/1000000]
	echo "[$1] using " $[hand__end_ms-hand__start_ms] "ms, for $2"
	hand__test_start
}
#load and do a function
#hand --load : only load the function
#
# WARNING: 
#	DO NOT call hand function in this function!
#   This function should not depend on any hand function
#
function hand()
{
	#empty cmd
	if [ $# -eq 0 ]; then
		hand__help
		return
	fi

	#hand__test_start

	#special options
	while [ true ];
	do
		if [ "$1" == "--load" ]; then
			shift
			local only_load=1
			continue;
		elif [ "$1" == "--silence" ]; then
			shift
			if [ "$hand__debug" != "0" ]; then # if debug enabled
				local save_debug_state=$hand__debug
				#echo "set hand__debug=0"
				hand__debug=0	
			fi
			continue;
		elif [ "$1" == "--show" ]; then
			shift
			local show_func_define=1
		fi
		break;
	done

	#parse func
	local func="hand"
	local file="$HAND_PATH/hand"
	local file2="$hand__config_path/hand"
    local p=
	for p in $*
	do
		shift
		#echo "p=$p"
		func="${func}_${p}"
		file="$file/$p"
		file2="$file2/$p"
		#echo file=$file
		#echo file2=$file2

		if [ -d $file ]; then
			#file2=$file
			continue
		fi
		if [ -d $file2 ]; then
			#file=$file2
			continue
		fi

		#file/file2 is not a dir
		#it should be a file
		#if [ -f $file2.sh ]; then
		#	file=$file2
		#fi
		break
	done
	if [ -f $file2.sh ]; then
		file=$file2
	fi
	file=$file.sh
	#echo $file

	#check cmd is a short?
	if [ ! -f $file ]; then
		#echo "$file not found"
		hand__echo_debug "try do \$__$func"
		eval hand__echo_debug '$__'$func $*
		eval hand__check_param_exist '$__'$func 
		if [ $? -eq 1 ]; then
			echo "\$__$func not found!"
			return 1
		fi

		#hand__test_end "short" "$func"

		eval '$__'$func $*
		return $?
	fi

	#hand__test_end "search" "$func"

	#echo "-------"
	#echo file=$file
	#echo func=$func
	#echo params=$*

	#load file if need
	#hand__check_function_exist $func
	local func_date=`eval echo '$'${func}__timestamp`
	if [ "$func_date" == "" ]; then
		# func not exist, source it
		hand__echo_debug "source $file"
		hand__echo_debug "[+] $func"
		source $file
		eval ${func}__timestamp=`date +%s`
		#touch $file
	else
		#if file too old, source and touch it
		#local file_date=`hand__get_file_timestamp $file`
		#local func_date=`eval echo '$'${func}__timestamp`
		#echo HAND TIMESTAMP=$hand__timestamp
		#echo File TIMESTAMP=$file_date
		if [ $func_date -lt $hand__timestamp ] ; then
			hand__echo_debug "source $file"
			hand__echo_debug "[u] $func"
			source $file
			eval ${func}__timestamp=`date +%s`
			#touch $file
			#echo new timestamp= `hand__get_file_timestamp $file` $file
		fi
	fi

	#hand__test_end "update" "$func"

	#echo "${func}__timestamp="
	#eval echo '$'${func}__timestamp

	#only load if need
	if [ "$only_load" == "1" ]; then
		return 0
	fi

	if [ "$show_func_define" ]; then
		type $func
		return 0
	fi

	#do func
	#if [ "$hand__debug" == "1" ]; then
	#	echo "do $func $*"
	#fi
	$func $*
	local result=$?
	if [ "$save_debug_state" ]; then
		#echo "set hand__debug=$save_debug_state"
		hand__debug=$save_debug_state
	fi
	
	return $result
}

#load custom config
hand__config_path=$HAND_PATH/config/$(hand__get_computer_name)
if [ ! -d $hand__config_path ]; then
	cp -r $HAND_PATH/config/example $hand__config_path
fi
hand echo do "source $hand__config_path/custom.sh"


#load completions
hand__completion_prebuild=$hand__config_path/completions.sh
hand echo do "source $HAND_PATH/hand-completions.bash"