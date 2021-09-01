##
# Handybox subcommand completion script
# V2.3
#
# Environment Functions:
#           comp_provide_values [$complist...]
#           comp_provide_files
#
# Environment Varivables
#            comp_editing  # Editing word
#            comp_params   # command params
#            comp_dir      # command dir
# Params:    
#            comp_params
##

##
# hand [params...]
##

# comp_dump

# hand -- options
if [ ${#} -ge 1 ] && [ ${@: -1} = "--" ]; then
	comp_provide_values "test pure source help cd where edit"
	return 0
fi

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
	# provide dir list as completion values
	local dir
	local has_value=0
	local config_path=
	if [ -d $hand__config_path/../$hand__base_config/hand ]; then
		config_path=$hand__config_path/../$hand__base_config
	else
		config_path=$hand__config_path
	fi
	# echo config_path: $config_path
	# echo subcmd_path: $subcmd_path
	for dir in "${config_path}/${subcmd_path}" "${hand__path}/$subcmd_path"; do
		if [ -d $dir ]; then
			# echo "oh, $dir is a dir"
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
	return 0
fi

# echo subcmd_handdir: $subcmd_handdir
# echo subcmd_path: $subcmd_path
# echo subcmd_params: $@

# call comp.sh to provide completion info
if [ -f $comp_dir/comp.sh ]; then
	source $comp_dir/comp.sh
fi
