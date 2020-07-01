#hand main script
hand__version="2.1.0"
hand__timestamp=`date +"%s"`
hand__debug=0

# hand main entry
# hand [command] [options...]
hand()
{
	#empty cmd
	if [ $# -eq 0 ]; then
		hand__help
		return
	fi

	#special options
	local show_func_define=0
	local show_help=0
	local saved_debug_state=$hand__debug
	while [ true ];
	do
		if [ "$1" = "--show" ]; then
			shift
			 show_func_define=1
			continue;
		elif [ "$1" = "--silence" ]; then
			shift
			hand__debug=0
			continue;
		elif [ "$1" = "--help" ]; then
			shift
			# echo "should show help!!"
			show_help=1
			continue;
		fi
		break;
	done

	# find shell dest file
	local func="hand"
	local file2="$hand__path/hand"
	local file="$hand__config_path/hand"
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

		if [ -e $file ]; then
			#file2=$file
			continue
		fi
		if [ -e $file2 ]; then
			#file=$file2
			continue
		fi

		break
	done
	if [ -e $file2.sh ]; then
		file=$file2
	fi
	file=$file.sh
	# echo "file="$file

	local lost=
	if [ ! -e $file ]; then
		local file2=${file%/*}.sh
		if [ "${file2##*/}" = "hand.sh" ]; then
			echo "$file not found!"
			return 1
		fi
		if [ ! -e $file2 ]; then
			echo "$file not found!"
			echo "$file2 not found!"
			return 1
		else
			lost=${func##*_}
			func=${func%_*}
			file=$file2
		fi
	fi

	# hand__check_function_exist $func
	# if [ $? -ne 0 ]; then
	# 	# load
	# 	echo "[+] $func"
	# 	source $file
	# fi

	# record func timestamp
	local func_date=`eval echo '$'hand__timestamp_${func}`

	if [ "$func_date" = "" ]; then
		# func not exist, first load file
		hand__load_file $file $func
		# hand__echo_debug "source $file"
		# hand__echo_debug "[+] $func"
		# source $file
		# eval ${func}__timestamp=`date +%s`
	else
		local file_date
		file_date=`hand__get_file_timestamp $file`

		# echo $file
		# echo func_date=$func_date
		# echo file_date=$file_date
		# echo hand_time=$hand__timestamp

		if [[ $file_date -gt $func_date ]]; then
			# func has modified, reload file
			hand__load_file  $file $func 'u'
			# hand__echo_debug "source $file"
			# hand__echo_debug "[u] $func"
			# source $file
			# eval ${func}__timestamp=`date +%s`

		# elif [ $hand__timestamp -gt $func_date ] ; then
		# 	# hand updated, force reload file
		# 	hand__echo_debug "source $file"
		# 	hand__echo_debug "[u] $func"
		# 	source $file
		# 	eval ${func}__timestamp=`date +%s`

		fi
	fi

	# echo fun=$func	

	# show func define
	if [ $show_func_define = 1 ]; then
		echo "file: $file"
		type $func
		which $func
		return 0
	fi

	if [[ $show_help -eq 1 ]]; then
		local cmd="${func//_/ }"
		hand__check_function_exist ${func}__help
		if [[ $? -ne 0 ]]; then
			hand echo warn "Helper for \"$cmd\" not found."
			hand echo warn "Please define in ${func}__help"
			return 1
		fi
		hand echo green "---- $cmd 帮助文档 ----"
		${func}__help "$cmd" "$loast $@"
		return 0
	fi

	# provide help function
	# hand__help "${func}__help" "$lost $*" 
	# [[ $? -eq 0 ]] && return 0
	
	# excute
	# echo ">>" $func $lost "$@"
	# echo $lost
	$func $lost "$@"
	ret=$?

	# restore debug state
	hand__debug=$saved_debug_state

	return $ret

}

# prefer run hand in standalone process
hand__hub()
{
	case $1 in
	"cd"|"update"|"work"|"prop"|"--show"|"time")
	    hand "$@"
	    ;;
	*)
		$HOME/bin/hand "$@"
		;;
	esac
}

# do a commond and get last word, if error return 1
hand__pure_do()
{
	local value=
	# echo cmd="$*"
	value=`$@`
	# echo ret=$value
	if [ $? -ne 0 ]; then
		echo $value
		return 1
	fi

	if [[ ! $value ]]; then
		return 0
	fi

	hand__get_last $value
}


# get current shell, name as: sh/bash/zsh...
hand__shell_name()
{
	local name=`ps | grep $$  | awk 'NR==1' | awk '{print $4}'`
	echo ${name#-}
}

# load a function from file
# params: $file $func $symbol
hand__load_file()
{
	local file=$1
	local func=$2
	local symbol=$3
	if [ ! $symbol ]; then
		symbol="+"
	fi
	# hand__echo_debug "source $file -- from "
	hand__echo_debug "[$symbol] $func  <-- $file"
	source $file
	eval hand__timestamp_${func}=`date +%s`
}

hand__get_file_timestamp()
{
	if [ "`uname`" = "Darwin" ]; then
		stat -r $1 | awk '{print $(NF-6)}'
	else
		ls -l --time-style=+%s $1 |  awk '{print $(NF-1)}'
	fi
}

# use time 280ms
hand__get_computer_name()
{
	local computer=`whoami`_`hostname`
	echo ${computer%.*}
    #echo "example"
}

hand__help()
{
	echo "============================"
	echo "Handybox $hand__version"
	echo "path: $hand__path"
	echo "config: $hand__config_path"
	echo "shell:" `hand__shell_name`
	echo "============================"
}

hand__check_function_exist()
{
	declare -f -F $1 > /dev/null
	return $?
}

hand__echo_debug()
{
	if [ "$hand__debug" = "1" ]; then
		echo $*
	fi
}

# get last line
hand__get_lastline()
{

	# echo ret=$?
		# echo ret=$pipestatus

	if [[ ! $# -eq 0 ]]; then
		# echo get last line from params
		echo $* | awk 'END {print}'
		return 0
	fi

	# echo parmas is empty
	# echo status=$PIPESTATUS[@]



	# exit if last cmd error
	# [[ $ret -ne 0 ]] && return 1

	# try read from pipe
	local lastline
	while read line ; do
		lastline=$line
	done
	echo $lastline
}

# get first line
hand__get_firstline()
{
	# echo -E "$@" | awk 'START {print}'
	if [[ ! $# -eq 0 ]]; then
		# echo "get first line from params =$@="
		echo $* | awk 'NR==1'
		return 0
	fi

	# echo parmas is empty, try read from pipe
	local line
	read line
	echo $line
}

# get last word
hand__get_last()
{
	hand__get_lastline $* | awk -F " " '{print $NF}'

	# echo -E "$@" | awk 'END {print}' | awk -F " " '{print $NF}'
}

# get first word
hand__get_first()
{
	hand__get_firstline $* | awk -F " " '{print $NF}'
	# echo -E "$@" | awk 'START {print}' | awk -F " " '{print $1}'
}



# -------------------------
# Init flow
# -------------------------


# get custom config path
hand__config_path=$hand__path/config/`hand__get_computer_name`
if [ ! -d $hand__path/config  ]; then
    mkdir $hand__path/config
fi
if [ ! -d $hand__config_path ]; then
	cp -r $hand__path/example $hand__config_path
fi

# completions prebuild file
# hand__completion_prebuild=$hand__config_path/.completions.sh

# init workspace
if [ -f $hand__config_path/current_work ]; then
	hand_work__name=`cat $hand__config_path/current_work`
fi
if [[ ! $hand_work__name ]]; then
	hand_work__name='default'
fi

# load custom sh
source $hand__config_path/custom.sh
