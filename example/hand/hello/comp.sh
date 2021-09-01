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
# hand hello
##

if [ $# -eq 0 ]; then
    comp_provide_values "world earth"
fi