##
# Handybox subcommand completion script
# V2.4
#
# Environment Functions:
#           comp_provide_values [$complist...]
#           comp_provide_files
#           comp_provide_cmddirs
#
# Environment Varivables
#            comp_editing  # Editing word
#            comp_params   # command params
#            comp_dir      # command dir
##

##
# hand [params...]
##

# comp_dump

# hand -- options
if [ ${#} -ge 1 ] && [ ${@: -1} = "--" ]; then
	comp_provide_values "test pure source help cd where edit editcomp new remove"
	return 0
fi

comp_provide_cmddirs()
{

	# provide dir list as completion values
	local dir
	local has_value=0

	# echo subcmd_path: $subcmd_path
	local cfg=""
	for cfg in ${hand__configs[@]} .. ; do
		dir=$hand__path/config/$cfg/$subcmd_path
		# echo dir=$dir
		if [ -d $dir ]; then
			# echo "oh, $cfg $dir is a dir"
			local values=`ls -F $dir/ | grep "/$" | sed 's/\/$//g'`
			if [ ! "$values" = "" ]; then
				comp_provide_values $values
				has_value=1
			fi
		fi
	done
	# echo "has_value: $has_value"
	if [ $has_value -eq 0 ]; then
		comp_provide_files
	fi

}

# handle completion for subcmd

local subcmd_handdir
local subcmd_path
local subcmd_param_shift_times=0
hand__find_subcmd $@
local ret=$?
while [ $subcmd_param_shift_times -gt 0 ]; do
	shift
	((subcmd_param_shift_times=subcmd_param_shift_times-1))
done

# provide help options
if [ ${#} -eq 0 ]; then
	if [ "${comp_editing: 0: 1}" = "-" ]; then
		comp_provide_values "-h --help"
	fi
fi

comp_dir=$subcmd_handdir/$subcmd_path
if [ $ret -ne 0 ] || [ ! -f "$comp_dir/comp.sh" ] ; then
	# echo "can't find comp.sh"
	if [ $# -eq 1 ]; then
		case $1 in
			"-h"|"--help")
			return 0
			;;
		esac
	fi
	comp_provide_cmddirs
	return 0
fi

# echo subcmd_handdir: $subcmd_handdir
# echo subcmd_path: $subcmd_path
# echo subcmd_params: $@

# call comp.sh to provide completion info
if [ -f $comp_dir/comp.sh ]; then
	source $comp_dir/comp.sh
fi
