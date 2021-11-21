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
"on"|"temp"|"remove")
    shift
    local i= name=
    local config=
    for config in ${hand__configs[@]} ; do
        for i in `ls $hand__path/config/$config/*.props` ; do
            # echo i=$i
            name=${i##*\/}
            name=${name%.*}
            if [[ ! ${name//_*} ]]; then
                continue
            fi
            comp_provide_values "$name"
        done
    done
    ;;
# "modprop")
#     shift
#     if [ ${#} -eq 0 ]; then
#         will_provide_proplist=1
#     fi
#     ;;
"setprop"|"modprop"|"getprop")
    local need_param_count=2
    if [ "$1" = "getprop" ]; then
        need_param_count=1
    fi
    shift
    local option_g=0
    local option_b=0
    while true; do
        if [ "$1" = "-g" ]; then
            shift
            option_g=1
            continue
        elif [ "$1" = "-b" ]; then
            shift
            option_b=1
            continue
        fi
        break
    done
    if [ $# -ge $need_param_count ]; then
        return
    fi
    if [ "${comp_editing: 0: 1}" = "-" ]; then
        if [ $option_g -eq 0 ]; then
            comp_provide_values "-g"
        fi
        if [ $option_b -eq 0 ]; then
            comp_provide_values "-b"
        fi
    else
        if [ $# -eq 0 ]; then
            will_provide_proplist=1
        else
            comp_provide_files
        fi
    fi
    ;;
# "xsetprop"|"xmodprop")
#     shift
#     if [ ${#} -gt 2 ]; then
#         return
#     else
#         if [ ${#} -eq 0 ] ; then
#             if [ "${comp_editing: 0: 1}" = "-" ]; then
#                 comp_provide_values "-g -b"
#             else
#                 will_provide_proplist=1
#             fi
#         elif [ ${#} -eq 1 ]; then
#             if [ "${1: 0: 1}" = "-" ] ; then
#                 will_provide_proplist=1
#             else
#                 comp_provide_files
#             fi
#         elif [ ${#} -eq 2 ]; then
#             if [ "${1: 0: 1}" = "-" ] ; then
#                 comp_provide_files
#             else
#                 return
#             fi
#         else
#             return
#         fi
#     fi
#     ;;
esac

if [ $will_provide_proplist -eq 1 ]; then
    if [ ! -z "$comp_work_proplist" ]; then
        comp_provide_values $comp_work_proplist
        return
    fi

    local files=(`find $hand__path -name comp_props.sh`)
    local file=
    local dir=
    for file in ${files[@]}
    do
        dir=${file%\/*}
        if [ -f "$dir/cmd.sh" ]; then
            source $file $dir
        fi
    done
    comp_provide_values $proplist
    comp_work_proplist=$proplist
fi

