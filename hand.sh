
hand()
{
	local origin_cmd=$*
	# echo "----------> " hand $origin_cmd

	# show version info
	if [ $# -eq 0 ]; then
		set -- -h
	fi

	# show help
	if [ $# -eq 1 ]; then
		case $1 in
			"-h"|"--help")
				echo "============================"
				echo "Handybox V$hand__version"
				echo "path:   $hand__path"
				echo "config: $hand__config_path"
				echo "shell:  `hand__shell_name`"
				echo "============================"
				echo -e "hand [<subcmd> [<params...>]] [-- options...]"
				echo -e "                     \t\t# Run a subcmd with params"
				echo -e "hand [subcmd] -- help   \t# Show Help of subcmd"
				echo -e "hand [subcmd] -- pure   \t# Call subcmd but not print debug info"
				echo -e "hand [subcmd] -- source \t# Show source code of subcmd"
				echo -e "hand [subcmd] -- test   \t# Test Runing the subcmd"
				echo -e "hand [subcmd] -- where  \t# Show path of subcmd"
				echo -e "hand [subcmd] -- edit   \t# Edit subcmd cmd.sh"
				echo -e "hand [subcmd] -- cd     \t# Go to path of subcmd"
				echo -e "hand update      \t\t# Update handybox main script"
				echo -e "hand cd          \t\t# Change dir to handybox home dir"
				echo -e "hand cd config   \t\t# Change dir to handybox config dir"
				return
			;;
		esac
	fi

	# parse special handybox options
	local show_func_define=0
	local show_help=0
	local ignore_debug=0
	local cd_to_cmddir=0
	local show_cmd_location=0
	local edit_cmd=0
	if [ $# -ge 2 ]; then
		local option_sign=""
		if [ "$ZSH_NAME" != "" ]; then
			option_sign="${@: -2: -1}"
		else
			option_sign="${@: -2: 1}"
		fi
		if [ "$option_sign" = "--" ]; then
			case "${@: -1}" in
			"where")
				show_cmd_location=1
				;;
			"edit")
				edit_cmd=1
				;;
			"source")
				show_func_define=1
				# echo show func define
				;;
			"help")
				show_help=1
				# echo show help
				;;
			"pure")
				ignore_debug=1
				((hand__debug_disabled+=1))
				# echo ignore debug info
				;;
			"cd")
				cd_to_cmddir=1
				;;
			"test")
				hand__echodo_disabled=1
				local expand_cmd=`type $1`
				#echo expand_cmd=$expand_cmd
				if [[ ! "$expand_cmd" =~ "hand" ]]; then
					#hand echo error "\"$@\" is not a hand command! can't show in Test mode!"
					expand_cmd="hand $@"
				else
					expand_cmd="$@"
				fi

				hand echo warn "Test command: $expand_cmd"

				eval ${expand_cmd//-- */}
				local ret=$?
				hand__echodo_disabled=0
				return $ret
				;;
			*)
				# echo Option not support, ignore!
				hand echo error "option \"-- ${@: -1}\" is not support!"
				return 1
				;;
			esac
			# reset params
			if [ "$ZSH_NAME" != "" ]; then
				set -- ${@: 1: -2}
			else
				set -- ${@: 1: (($#-2))}
			fi
		fi
	fi

	# show help by -- help option
	if [ $# -eq 0 ]; then
		echo -e "\033[32m---- hand ----\033[0m"
		hand -h
		return 0
	fi

	#
	# now, we should find, load and call sub command
	#
	local subcmd_handdir
	local subcmd_path
	local subcmd_param_shift_times=0
	hand__find_subcmd $@
	if [ $? -ne 0 ]; then
		echo "\"hand $origin_cmd\" not found in handybox!"
		return 1
	fi
	# echo subcmd_param_shift_times=$subcmd_param_shift_times
	while [ $subcmd_param_shift_times -gt 0 ]; do
		shift
		((subcmd_param_shift_times-=1))
	done
	# echo subcmd_handdir=$subcmd_handdir
	# echo subcmd_path=$subcmd_path
	# echo subcmd_params=$@
	# return 0

	file=$subcmd_handdir/$subcmd_path/cmd.sh
	cmdpath=$subcmd_path
	func=${subcmd_path//\//_}

	# show where is the sub cmd
	if [ $show_cmd_location -eq 1 ]; then
		echo $file
		return 0
	fi

	if [ $edit_cmd -eq 1 ]; then
		vim $file
		return 0
	fi

	# cd to dir of the sub cmd
	if [ $cd_to_cmddir -eq 1 ]; then
		cd `dirname $file`
		return 0
	fi

	local hand__cmd="${cmdpath//\// }"
	local hand__cmd_dir=`dirname $file`

	# 3. load sub command file (cmd.sh)
	if [ "$hand__lazy_load" = "1" ]; then
		# lazy load func by comparing timestamp
		local func_date=`eval echo '$'hand__timestamp_${func}`
		if [ "$func_date" = "" ]; then
			# func not exist, first load file
			hand__load_file $file $func
		else
			# func exist
			# local file_date
			# file_date=`hand__get_file_timestamp $file`
			if [ $hand__timestamp -gt $func_date ] || [ `hand__get_file_timestamp $file` -gt $func_date ] ; then
				# func has modified, reload file
				hand__load_file $file $func 'u'
			fi
		fi
	else
		# echo "[+] $file"
		function hand__cmd_func {
			source $file
		}
		func=hand__cmd_func
	fi

	# 4. show func definition
	if [ $show_func_define = 1 ]; then
		echo "file: $file"
		# cat $file
		if [ "$hand__lazy_load" = "1" ]; then
			type $func
			which $func
		else
			cat $file
		fi
		return 0
	fi

	# 5. show help
	if [[ $show_help -eq 1 ]]; then
		echo -e "\033[32m---- $hand__cmd ----\033[0m"
		$func --help
		return 0
	fi

	# 6. call sub command
	local ret=
	$func "$@"
	ret=$?

	# 7. restore debug state
	if [ "${ignore_debug}" = '1' ]; then
		((hand__debug_disabled-=1))
	fi

	# 8. return result
	return $ret

}

# 
# hand subcmd... params... ---> $subcmd_handdir/$subcmd_path/cmd.sh $subcmd_params...
# output: subcmd_handdir, subcmd_path, subcmd_param_shift_times
#
hand__find_subcmd() {
	local off=0
	local config_path=
	if [ -d $hand__config_path/../$hand__base_config/hand ]; then
		config_path=$hand__config_path/../$hand__base_config
	else
		config_path=$hand__config_path
	fi


	# 1. get func and cmdpath of sub command 
	local cmdpath="hand" # sub cmd related path. eg: hand/a/b/c
	local par=
	for par in $*
	do	
		if [ -d $config_path/$cmdpath/$par ] || [ -d $hand__path/$cmdpath/$par ]; then
			((off=off+1))
			cmdpath="$cmdpath/$par"
			continue
		fi
		break
	done
	subcmd_path=$cmdpath
	# echo subcmd_path: $subcmd_path
	# local func=${cmdpath//\//_}  # sub cmd function name. eg: hand_a_b_c

	# echo func=$func
	# echo cmdpath=$cmdpath

	# 2. find dest cmd.sh file
	# local lost=""   # get lost params
	local file=""   # file path of cmd.sh
	while [ true ]; do
		# echo
		# echo func=$func
		# echo cmdpath=$cmdpath
		# echo params=$lost $*
		
		if [ "${cmdpath}" = "hand" ]; then
			# echo "cmd not found"
			return 1
		fi
		
		file=$config_path/$cmdpath/cmd.sh
		if [ -f $file ]; then
			# cmd.sh found in config path
			subcmd_handdir=$config_path
			break
		fi
		file=
		
		file=$hand__path/$cmdpath/cmd.sh
		if [ -f $file ]; then
			# cmd.sh found in main path
			subcmd_handdir=$hand__path
			break
		fi
		file=

		# fallback to upper level
		cmdpath=${cmdpath%/*}  # up level cmdpath
		((off=off+1))
	done

	subcmd_path=$cmdpath
	subcmd_param_shift_times=$off
}

# prefer run hand in standalone process
hand__hub()
{
	case $1 in
	"cd"|"update"|"work"|"prop"|"-s"|"time")
		hand "$@"
		;;
	*)
		$HOME/bin/hand "$@"
		;;
	esac
}

# do a commond and get last word, if error return
hand__pure_do()
{
	local value=
	# echo cmd="$*"
	local ret
	value=`$@`
	ret=$?
	# echo ret=$value
	if [ $ret -ne 0 ]; then
		echo $value
		return $ret
	fi

	if [[ ! $value ]]; then
		return 0
	fi

	hand__get_last $value
}

# get current shell name, such as: sh, bash, or zsh...
hand__shell_name()
{
	if [ "$ZSH_NAME" != "" ]; then
		echo "zsh"
	else
		echo "bash"
	fi
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
	# echo define $func
	local temp=$( mktemp )
	echo "$func() {" > $temp
	cat $file >> $temp
	echo -e "\n}" >> $temp
	. $temp
	rm ${temp}
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

hand__check_function_exist()
{
	declare -f -F $1 > /dev/null
	return $?
}

hand__echo_debug()
{
	if [ $hand__debug_disabled -eq 0 ]; then
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
# script loading entry
# ==============

hand__version="3.3.2"
hand__timestamp=`date +%s`

# init custom config path
hand__config_path=$hand__path/config/`hand__get_config_name`
if [ ! -d $hand__path/config  ]; then
	mkdir $hand__path/config
fi
if [ ! -d $hand__config_path ]; then
	cp -r $hand__path/example $hand__config_path
	if [ -f $hand__config_path/init_config.sh ]; then
		source $hand__config_path/init_config.sh
	fi
fi

# load user's custom script
source $hand__config_path/custom.sh
if [ -z $hand__debug_disabled ]; then
	hand__debug_disabled=1
fi
if [ -z $hand__lazy_load ]; then
	hand__lazy_load=1
fi

# load cmd completion script
if [ ! "$hand__load_completion" = "0" ]; then
	source $hand__path/completions/complete.sh
fi
