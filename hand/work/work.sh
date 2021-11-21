#!/bin/bash

##
# work [<action> [params...]]
#                         # show workspace
#   on/temp $workname     # choose workspace
##
work() {

    # handle sub command
    local sub=$1
    shift
    case $sub in
    "on")
        work_on $1
        ;;
    "remove")
        work_remove $1
        ;;
    esac
    if [ $? -eq 0 ]; then
        work_show
    fi
}

# persistently work on a workspace (save work name into a file)
# work_on <workspace>
work_on()
{
	# if [ $# -eq 0 ]; then
    #     echo "ERROR: No workspace name!"
    #     return 1
    # fi

    {
        flock 200
	    hand_work__name=$1
        # write current work name to file
        echo $hand_work__name > $hand__config_path/.current_work
        # touch prop file
        local config=
        local matched=0
        for config in ${hand__configs[@]}; do
            if [ -f $hand__path/config/$config/${hand_work__name}.props ]; then
                matched=1
                break
            fi
        done
        if [ $matched -eq 0 ]; then
            touch $hand__config_path/${hand_work__name}.props
        fi
        # if [ ! -f $hand__config_path/${hand_work__name}.props ]; then
        #     touch $hand__config_path/${hand_work__name}.props
        # fi
    } 200>$hand__config_path/.current_work

}

# remove a workspace
# work_remove <workspace>
work_remove()
{
	# if [ $# -eq 0 ]; then
    #     echo "ERROR: No workspace name!"
    #     return 1
    # fi

    local config=
    local file=
    for config in ${hand__configs[@]} ; do
        file=$hand__path/config/$config/${1}.props
        if [ -f $file ]; then
            echo "Remove workspace \"${1}\" from $config"
            rm $file
        fi
    done

    if [ "$hand_work__name" = "$1" ]; then
        work_on default
    fi
}


work_show()
{
	echo "All workspaces:"
	local i= name= list=()
    # echo configs=${hand__configs}
    local config=
    for config in ${hand__configs[@]}; do
        # echo config=$config
        if [ ! -f $hand__path/config/$config/default.props ]; then
            touch $hand__path/config/$config/default.props
        fi
        for i in `ls $hand__path/config/$config/*.props`; do
            # echo i=$i
            name=${i##*\/}
            name=${name%.*}

            if [[ ! ${name//_*} ]]; then
                # skip _* prop name
                continue
            fi

            # echo list: ${list[@]}
            local n= matched=0
            for n in ${list[@]}; do
                if [ "$n" = "$name" ]; then
                    matched=1
                    break
                fi
            done
            if [ $matched -eq 1 ]; then
                continue
            fi

            list[${#list[@]}]=$name
            if [ "$hand_work__name" = "$name" ]; then
                echo -e "\033[32m  *  $name\033[0m"
            else
                echo "     "$name
            fi
        done
    done
	

    # echo ${list[*]}
}

# echo ">>> work.sh"
work "$@"
