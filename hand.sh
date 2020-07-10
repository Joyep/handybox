# hand command entry
# hand [command] [options...]

hand__help()
{
	echo -e "hand [options...] [<subcmd> [<params...>]]"
	echo -e "            \t\tRun a subcommand"
	echo
	echo -e "hand --help \t\tHelp"
	echo -e "hand --pure \t\tCall hand but not print debug info"
	echo -e "hand --show \t\tShow source code"
	echo -e "hand update \t\tUpdate handybox script"
	echo -e "hand update completions Update handybox completions"
	echo -e "hand cd \t\tChange dir to handybox home path"
	echo -e "hand cd config \t\tChange dir to handybox config path"
}

hand()
{
	local origin_cmd=$*
	# empty cmd
	if [ $# -eq 0 ]; then
		hand__show_version
		return
	fi

	# parse special options
	local show_func_define=0
	local show_help=0
	local saved_debug_state=$hand__debug
	while [ true ];
	do
		if [ "$1" = "--show" ]; then
			shift
			 show_func_define=1
			continue;
		elif [ "$1" = "--pure" ]; then
			shift
			hand__debug=0
			continue;
		elif [ "$1" = "--help" ]; then
			shift
			show_help=1
			continue;
		fi
		break;
	done

	# only hand cmd ?
	if [ "$*" = "" ]; then
		if [ $show_help = 1 ]; then
			hand__help
		fi
		return 0
	fi

	# find shell file and function name of this sub command
	local func="hand"  # hand_a_b_c_...
	local cmdpath="hand" # 相对路径
	local p=
	for p in $*
	do	
		shift
		func="${func}_${p}"
		cmdpath="$cmdpath/$p"
		# echo func=$func
		if [ -d $hand__config_path/$cmdpath ] || [ -d $hand__path/$cmdpath ]; then
			# echo "continue"
			continue
		fi
		break
	done

	# find dest cmd.sh file
	local lost=""   # get lost params
	local file=""
	local f
	while [ true ]; do
		# echo
		# echo func=$func
		# echo cmdpath=$cmdpath
		# echo params=$lost $*
		
		if [ "${cmdpath}" = "hand" ]; then
			# echo "cmd not found"
			break
		fi
		
		f=$hand__config_path/$cmdpath.cmd.sh
		if [ -f $f ]; then
			# xxx.cmd.sh found 1
			file=$f
			break
		fi
		# echo $f not found
		
		f=$hand__path/$cmdpath.cmd.sh
		if [ -f $f ]; then
			# xxx.cmd.sh found 2
			file=$f
			break
		fi
		# echo $f not found

		f=$hand__config_path/$cmdpath.cmd
		if [ -d $f ] ; then
			# xxx.cmd found 1
			file=$f/${cmdpath##*/}.cmd.sh
			break
		fi
		# echo $f not found

		f=$hand__path/$cmdpath.cmd
		if [ -d $f ] ; then
			# xxx.cmd found 2
			file=$f/${cmdpath##*/}.cmd.sh
			break
		fi
		# echo $f not found

		# fallback to upper level
		
		cmdpath=${cmdpath%/*}  # up level cmdpath
		if [ "$lost" = "" ]; then
			lost="${func##*_}"
		else
			lost="${func##*_} $lost"
		fi
		func=${func%_*}
	done

	# echo
	# echo func=$func
	# echo file=$file
	# echo params=$lost $*

	if [ ! -f "$file" ]; then
		echo file=$file
		hand echo error "hand $origin_cmd not found in handybox!"
		return 1
	fi

	# ok, xxx.cmd.sh file found!
	# echo file=$file
	hand__cmd_dir=`dirname $file`
	# file=$file/${file##*/}.sh

	# show func define
	if [ $show_func_define = 1 ]; then
		echo ">> $file"
		cat $file
		# type $func
		# which $func
		return 0
	fi

	# go on execute cmd file
	if [[ $show_help -eq 1 ]]; then
		# show help
		local cmd="${func//_/ }"
		# hand__check_function_exist ${func}__help
		# if [[ $? -ne 0 ]]; then
		# 	hand echo warn "Helper for \"$cmd\" not found."
		# 	hand echo warn "Please define in ${func}__help"
		# 	return 1
		# fi
		hand echo green "---- $cmd 帮助文档 ----"
		# ${func}__help "$cmd" "$loast $@"
		# return 0
		# if [ "$hand__path/hand" = "$hand__cmd_dir" ]; then
		# 	hand__help "$cmd" "$lost $@"
		# 	return 0
		# fi
		source $file --help "$cmd" "$lost $@"
	else
		# call sub command function
		# echo file2=$file
		source $file $lost $*
	fi
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

# get current shell name, such as: sh, bash, or zsh...
hand__shell_name()
{
	local name=`ps | grep $$  | awk 'NR==1' | awk '{print $4}'`
	# handle case: "-zsh" "/bin/bash"
	name=${name#-}  		# Delete left -
	echo ${name##*/} 		# Delete left path
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

# get config name using usename_hostname
hand__get_config_name()
{
	local computer=`whoami`_`hostname`
	echo ${computer%.*}
}

hand__show_version()
{
	echo "============================"
	echo "Handybox $hand__version"
	echo "path:   $hand__path"
	echo "config: $hand__config_path"
	echo "shell:  `hand__shell_name`"
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


# ==============
# script entry
# ==============

hand__version="3.0"
hand__debug=0

# init custom config path
hand__config_path=$hand__path/config/`hand__get_config_name`
if [ ! -d $hand__path/config  ]; then
	mkdir $hand__path/config
fi
if [ ! -d $hand__config_path ]; then
	cp -r $hand__path/example $hand__config_path
fi

# init workspace
if [ -f $hand__config_path/current_work ]; then
	hand_work__name=`cat $hand__config_path/current_work`
fi
if [[ ! $hand_work__name ]]; then
	hand_work__name='default'
fi

# load custom sh
source $hand__config_path/custom.sh
