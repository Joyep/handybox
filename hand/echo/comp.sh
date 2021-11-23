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

# comp_dump
# echo params="$*"
# echo paramsnum="$#"
local with_bg=0
local options="-b -i -bg -hi"
local with_option=0
while true; do
    if [ "${1:0:1}" = "-" ]; then
        options=${options/$1/}
        if [ "$1" = "-bg" ]; then
            with_bg=1
        fi
        with_option=1
        shift
        continue
    fi
    break
done
if [ "${comp_editing: 0: 1}" = "-" ]; then
    comp_provide_values $options
    return
fi

local colors="red green yellow black cyan magenta white"
local actions="error info warn debug do"
if [ $# -eq 0 ]; then
    if [ $with_option -eq 1 ]; then
        comp_provide_values $colors
    else
        comp_provide_values $colors $actions 
    fi
elif [ $# -eq 1 ]; then
    if [ $with_bg -eq 1 ]; then
        comp_provide_values $colors
    fi
fi

