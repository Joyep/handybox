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
# hand work [params...]
##


if [ ${#} -eq 0 ]; then
    comp_provide_values "on temp getprop setprop modprop remove"
    return
fi

local will_provide_proplist=0
case ${1} in
"on"|"temp")
    shift
    local i= name=
    for i in `ls $hand__config_path/*.props; ls $hand__config_path/../$hand__base_config/*.props`
	do
		name=${i##*\/}
		name=${name%.*}
		if [[ ! ${name//_*} ]]; then
			continue
		fi
        comp_provide_values "$name"
    done
    ;;
# "modprop")
#     shift
#     if [ ${#} -eq 0 ]; then
#         will_provide_proplist=1
#     fi
#     ;;
"getprop"|"setprop"|"modprop")
    shift
    if [ ${#} -gt 2 ]; then
        return
    else
        if [ ${#} -eq 0 ] ; then
            if [ "${comp_editing: 0: 1}" = "-" ]; then
                comp_provide_values "-g -b"
            else
                will_provide_proplist=1
            fi
        elif [ ${#} -eq 1 ]; then
            if [ "${1: 0: 1}" = "-" ] ; then
                will_provide_proplist=1
            else
                comp_provide_files
            fi
        elif [ ${#} -eq 2 ]; then
            if [ "${1: 0: 1}" = "-" ] ; then
                comp_provide_files
            else
                return
            fi
        else
            return
        fi
    fi
    ;;
esac

if [ $will_provide_proplist -eq 1 ]; then
   # echo hand_path=$hand__path
    local files=(`find $hand__path -name comp_props.sh`)
    local file=
    local dir=
    for file in ${files[@]}
    do
        # echo file: $file
        dir=${file%\/*}
        # echo dir: $dir
        if [ -f "$dir/cmd.sh" ]; then
            # echo source $file
            # inn $dir ...
            source $file $dir
        fi
    done
    comp_provide_values $proplist
fi

