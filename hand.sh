
hand()
{
	local origin_cmd=$*
	# echo "----------> " hand $origin_cmd

	# show version info
	if [ $# -eq 0 ]; then
		# set -- -h

		echo "======================================"
		echo -e "           `hand__color -b cyan Handybox` `hand__color -i white v$hand__version`"
		echo
		echo -e "    `hand__color cyan Script:` $hand__path"
		echo -e "    `hand__color cyan Binary:` `whereis hand | awk '{print $2}'`"
		echo -e "   `hand__color cyan Configs:` ${hand__configs[@]}"
		echo -e "     `hand__color cyan Shell:` `hand__shell_name`"
		echo -e "  `hand__color cyan Get help:` hand -h"
		echo "======================================"
		return
	fi

	# show help
	if [ $# -eq 1 ]; then
		case $1 in
			"-h"|"--help")
				local colored_hand=`hand__color cyan hand`
				echo -e "$colored_hand `hand__color yellow \<subcmd\> \[\<params...\>\]` `hand__color magenta \[\-\- \<option\>]`"

				echo -e "                     \t# Run a subcmd with params"
				echo -e "option:"
				echo -e "\t`hand__color magenta -- help`     \t# Show Help of subcmd"
				echo -e "\t`hand__color magenta -- pure`     \t# Call subcmd but not print debug info"
				echo -e "\t`hand__color magenta -- source`   \t# Show source code of subcmd"
				# echo -e "\t`hand__color magenta -- test`    \t# Test Runing the subcmd"
				echo -e "\t`hand__color magenta -- where`    \t# Show path of subcmd"
				echo -e "\t`hand__color magenta -- cd`       \t# Go to path of subcmd"
				echo -e "\t`hand__color magenta -- edit`     \t# Edit subcmd cmd.sh"
				echo -e "\t`hand__color magenta -- editcomp` \t# Edit subcmd comp.sh"
				echo -e "\t`hand__color magenta -- new\|new-python\|new-swift`      \t# Create a new shell|python|swift subcmd project"
				echo -e "\t`hand__color magenta -- remove`   \t# Remove an exist subcmd"
				echo -e "\nExample:"
				echo -e "$colored_hand `hand__color yellow update`      \t# Update handybox main script"
				echo -e "$colored_hand `hand__color yellow cd`          \t# Go to path of handybox home dir"
				echo -e "$colored_hand `hand__color yellow cd config`   \t# Go to path of handybox config dir"
				# echo -e "\nAll subcommands:"
				# local config=
				# local dirs=
				# local cmds=`ls $hand__path/hand`
				# for config in ${hand__configs[@]}; do
				# 	if [ -d $hand__path/config/$config/hand ]; then
				# 		cmds="$cmds `ls $hand__path/config/$config/hand`"
				# 	fi
				# done
				# local cmd=
				# local array=(${(u)=cmds})
				# # array=${(u)array}
				# local index=1
				# for cmd in $array; do
				# 	echo -e -n "`hand__color yellow $cmd`\t"
				# 	if [ $((index%8)) -eq 0 ]; then
				# 		echo
				# 	fi
				# 	((index+=1))
				# done
				# echo
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
	local edit_dir=0
	local edit_comp=0
	local new_subcmd=0
	local new_py_subcmd=0
	local remove_subcmd=0
	if [ $# -ge 2 ]; then
		local option_sign=""
		if [ "$ZSH_NAME" != "" ]; then
			option_sign="${@: -2: -1}"
		else
			option_sign="${@: -2: 1}"
		fi
		if [ "$option_sign" = "--" ]; then
			case "${@: -1}" in
			"new")
				new_subcmd=1
				;;
			"new-python")
				new_subcmd=1
				new_py_subcmd=1
				;;
			"remove")
				remove_subcmd=1
				;;
			"where")
				show_cmd_location=1
				;;
			"edit")
				edit_cmd=1
				;;
			"editdir")
				edit_dir=1
				;;
			"editcomp")
				edit_comp=1
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

	# handle special options for hand
	if [ $# -eq 0 ]; then

		local file=$hand__path/hand.sh
		if [ $show_cmd_location -eq 1 ]; then
			echo $file
			return 0
		fi
		if [ $edit_cmd -eq 1 ]; then
			vim $file
			echo $file
			return 0
		fi
		if [ $edit_comp -eq 1 ]; then
			vim $hand__path/completions/comp.sh
			echo $hand__path/completions/comp.sh
			return 0
		fi
		if [ $cd_to_cmddir -eq 1 ]; then
			cd `dirname $file`
			return 0
		fi
		if [ $new_subcmd -eq 1 ]; then
			echo -e "Command \"hand\" already exist!"
			return 0
		fi
		if [ $remove_subcmd -eq 1 ]; then
			echo -e "Can't remove command \"hand\"!"
			return 0
		fi
		echo -e `hand__color green "Helper for \"hand\""`
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
		if [ $new_subcmd -eq 1 ]; then
			# create a new subcmd using tamplete
			local subcmd_path="hand $@"
			local index=0
			if [ "$ZSH_NAME" != "" ]; then
				index=1
			fi
			subcmd_handdir=$hand__path/config/${hand__configs[index]}
			local subcmd_path="$subcmd_handdir/${subcmd_path// //}"
			mkdir -p $subcmd_path
			if [ $new_py_subcmd -eq 1 ]; then
				cp $hand__path/templete/python-project/* $subcmd_path/
			else
				cp $hand__path/templete/shell-project/* $subcmd_path/
			fi
			echo "Command \"hand $@\" created in $subcmd_path"
			return 0
		fi
		echo "\"hand $@\" is not a subcommand!"
		return 1
	fi

	# subcommand found

	local cmdpath=$subcmd_path
	local hand__cmd="${cmdpath//\// }"
	if [ $new_subcmd -eq 1 ]; then
		echo "Command \"hand $hand__cmd\" already exist!"
		return 1
	fi

	if [ $remove_subcmd -eq 1 ]; then
		echo "Remove command \"$hand__cmd\" from $subcmd_handdir/$subcmd_path (Yes/no)?"
		local confirm_remove
		read confirm_remove
		if [ "$confirm_remove" = "Yes" ]; then
			rm -r $subcmd_handdir/$subcmd_path
			echo "Removed"
		else
			echo "Cancelled"
		fi
		return 0
	fi

	local file=$subcmd_handdir/$subcmd_path/cmd.sh
	local func=${subcmd_path//\//_}
	# echo subcmd_param_shift_times=$subcmd_param_shift_times
	while [ $subcmd_param_shift_times -gt 0 ]; do
		shift
		((subcmd_param_shift_times-=1))
	done
	# echo subcmd_handdir=$subcmd_handdir
	# echo subcmd_path=$subcmd_path
	# echo subcmd_params=$@
	# return 0

	# show where is the sub cmd
	if [ $show_cmd_location -eq 1 ]; then
		echo $file
		return 0
	fi

	if [ $edit_cmd -eq 1 ]; then
		vim $file
		echo $file
		return 0
	fi
	if [ $edit_dir -eq 1 ]; then
		vim $subcmd_handdir/$subcmd_path
		return 0
	fi
	if [ $edit_comp -eq 1 ]; then
		file=$subcmd_handdir/$subcmd_path/comp.sh
		if [ ! -f $file ]; then
			cp $hand__path/templete/shell-project/comp.sh $file
		fi
		vim $file
		echo $file
		return 0
	fi

	# cd to dir of the sub cmd
	if [ $cd_to_cmddir -eq 1 ]; then
		cd `dirname $file`
		return 0
	fi


	local hand__cmd_dir=`dirname $file`

	# 3. load sub command file (cmd.sh)
	if [ "$hand__cache_load" = "1" ]; then
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
		if [ "$hand__cache_load" = "1" ]; then
			type $func
			which $func
		else
			cat $file
		fi
		return 0
	fi

	# 5. show help
	if [[ $show_help -eq 1 ]]; then
		echo -e `hand__color green "Helper for \"$hand__cmd\""`
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

# hand__color [-b|-i|-bg|-hi] <color> [<bgcolor>] <content>
# -b: bold
# -i: italic
# -bg: with background color
# -hi: high Intensity color
hand__color()
{
	# local COLOR_BLACK=0
	# local COLOR_RED=1
	# local COLOR_GREEN=2
	# local COLOR_YELLOW=3
	# local COLOR_BLUE=4
	# local COLOR_MAGENTA=5
	# local COLOR_CYAN=6
	# local COLOR_WHITE=7

	# local FOREGROUND=3
	# local BACKGROUND=4
	# local FOREGROUND_HIGH_INTENSITY=9
	# local BACKGROUND_HIGH_INTENSITY=10

	# local OPTION_NONE=0
	# local OPTION_BOLD=1
	# local OPTION_TINT=2
	# local OPTION_ITALIC=3

	local option=0
	local color=0
	local bgcolor=-1
	local with_bg=0
	local foreground=3
	local background=4
	while true; do
		if [ "-b" = "$1" ]; then
			option=1
			shift
			continue
		fi
		if [ "-i" = "$1" ]; then
			option=3
			shift
			continue
		fi
		if [ "-bg" = "$1" ]; then
			with_bg=1
			shift
			continue
		fi
		if [ "-hi" = "$1" ]; then
			foreground=9
			background=10
			shift
			continue
		fi
		if [ "-" = "${1:0:1}" ]; then
			shift
			continue
		fi
		break
	done

	# format text with color
	local i=
	for i in  1 2 ; do
		case $1 in
		"black")
			shift
			if [ $i -eq 1 ]; then
				color=0
			else
				bgcolor=0
			fi
			;;
		"red")
			shift
			if [ $i -eq 1 ]; then
				color=1
			else
				bgcolor=1
			fi
			;;
		"green")
			shift
			if [ $i -eq 1 ]; then
				color=2
			else
				bgcolor=2
			fi
			;;
		"yellow")
			shift
			if [ $i -eq 1 ]; then
				color=3
			else
				bgcolor=3
			fi
			;;
		"blue")
			shift
			if [ $i -eq 1 ]; then
				color=4
			else
				bgcolor=4
			fi
			;;
		"magenta")
			shift
			if [ $i -eq 1 ]; then
				color=5
			else
				bgcolor=5
			fi
			;;
		"cyan")
			shift
			if [ $i -eq 1 ]; then
				color=6
			else
				bgcolor=6
			fi
			;;
		"white")
			shift
			if [ $i -eq 1 ]; then
				color=7
			else
				bgcolor=7
			fi
			;;
		*)
			shift
			echo $*
			return
			;;
		esac
		if [ $with_bg -eq 1 ]; then
			continue
		fi
		break
	done
	
	if [ $bgcolor -ne -1 ]; then
		bgcolor="${background}$bgcolor;"
	else
		bgcolor=""
	fi
	echo -e "\033[${option};${bgcolor}${foreground}${color}m$*\033[0m"
}

# 
# hand subcmd... params... ---> $subcmd_handdir/$subcmd_path/cmd.sh $subcmd_params...
# output: subcmd_handdir, subcmd_path, subcmd_param_shift_times
#
hand__find_subcmd() {
	local off=0

	# 1. get func and cmdpath of sub command 
	local cmdpath="hand" # subcmd related path. eg: hand/a/b/c
	local par=
	for par in $* ; do	
		local matched=0
		local cfg=""
		for cfg in ${hand__configs[@]} $hand__path/$cmdpath/$par; do
			if [ -d $hand__path/config/$cfg/$cmdpath/$par ]; then
				matched=1
			fi
		done
		if [ $matched -ne 1 ]; then
			if [ -d $hand__path/$cmdpath/$par ]; then
				matched=1
			fi
		fi
		if [ $matched -eq 1 ]; then
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
		
		local cfg=""
		for cfg in ${hand__configs[@]}; do
			file=$hand__path/config/$cfg/$cmdpath/cmd.sh
			if [ -f $file ]; then
				# cmd.sh found in config path
				subcmd_handdir=$hand__path/config/$cfg
				break 2
			fi
			file=
		done
		
		file=$hand__path/$cmdpath/cmd.sh
		if [ -f $file ]; then
			# cmd.sh found in main path
			subcmd_handdir=$hand__path
			break
		fi
		file=

		# fallback to upper level
		cmdpath=${cmdpath%/*}  # up level cmdpath
		((off=off-1))
	done

	subcmd_path=$cmdpath
	subcmd_param_shift_times=$off
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
	
	# define $func
	local temp=$( mktemp )
	echo "$func() {" > $temp
	cat $file >> $temp
	echo -e "\n}" >> $temp
	source $temp
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

hand__init() {
	# echo Loading handybox...
	hand__version="3.4.1"
	hand__timestamp=`date +%s`

	# get user config name
	local cfg=""
	if [ "$hand__custom_config" != "" ]; then
		cfg=$hand__custom_config
	else
		cfg=`hand__get_config_name`
	fi
	hand__config_path=$hand__path/config/$cfg
	# echo hand__config_path=$hand__config_path
	# init config path
	local file=$hand__path/config
	if [ ! -d $file  ]; then
		mkdir $file
	fi
	local config_path=$hand__config_path
	if [ ! -d $config_path ]; then
		cp -r $hand__path/templete/default-config $config_path
		file=$config_path/init_config.sh
		if [ -f $file ]; then
			source $file
			rm $file
		fi
	fi

	# default configuration
	hand__debug_disabled=1
	hand__cache_load=1

	# load user's configuration
	hand__configs=( $cfg )
	local index=1
	if [ "$ZSH_NAME" != "" ]; then
		index=2
	fi
	local _base_name=
	while true; do
		# echo parse config: cfg
		file=$hand__path/config/$cfg/base.config.txt
		if [ -f $file ]; then
			_base_name=`cat $file`
			# echo in cfg, _base_name is $_base_name
			if [ "$_base_name" != "" ] && [ -d $hand__path/config/$_base_name ]; then
				cfg=$_base_name
				hand__configs[index]=$_base_name
				((index+=1))
				continue
			fi
		fi
		break
	done
	# echo all configs: $hand__configs[@]
	# echo index=$index
	local from=$((index-1))
	local to=0
	if [ "$ZSH_NAME" != "" ]; then
		to=1
	fi
	local i
	for ((i=from; i>=to; i--)) do
		# echo load config: ${hand__configs[i]}
		file=$hand__path/config/${hand__configs[i]}/config.sh
		if [ -f $file ]; then
			source $file
		fi
		file=$hand__path/config/${hand__configs[i]}/alias.sh
		if [ -f $file ]; then
			source $file
		fi
	done

	# load cmd completion script
	if [ ! "$hand__load_completion" = "0" ]; then
		source $hand__path/completions/complete.sh
	fi
}

hand__init

