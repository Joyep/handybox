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
# hand sh [params...]
##


if [ ${#} -eq 0 ]; then
    if [ "${comp_editing: 0: 1}" = "-" ]; then
        comp_provide_values "--zsh --bash --env"
        return
    fi
fi

comp_provide_files
