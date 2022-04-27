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

# [-f <cmd_file>] [cmd_params...]

#comp_dump

local should_provide_subcmd_comp=0
local file="cmd.sh"

if [ $# -eq 0 ] ; then
	comp_provide_values "-f"
	if [ -f $file ];  then
		# provide subcmd complitions
		should_provide_subcmd_comp=1
	fi
elif [ $# -eq 1 ] && [ "$1" = "-f" ]; then
	comp_provide_files
else
	if [ "$1" = "-f" ]; then
		file=$2
		shift
		shift
	fi
	# provide subcmd complitions
	should_provide_subcmd_comp=1
fi

if [ $should_provide_subcmd_comp -eq 1 ]; then
	local comp_dir=`dirname $file`
	local compfile=$comp_dir/comp.sh
	if [ -f $compfile ]; then
		source $compfile
	fi
fi
