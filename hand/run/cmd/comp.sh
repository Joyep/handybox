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

if [ $# -eq 0 ]; then
	comp_provide_files
else
	local comp_dir=`dirname $1`
	local compfile=$comp_dir/comp.sh
	shift
	if [ -f $compfile ]; then
		source $compfile
	fi
fi
