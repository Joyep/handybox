#!/bin/bash


##
# main <action> [params...]
#                   show                       # show workspace info
#                   on $workname               # choose workspace
#                   getprop $key               # get prop from workspace 
#                   setprop [-g] $key $value   # set prop to workspace
##
main() {

	#echo work.sh
	#echo params: $*
	#echo pn: $#

    # local hand_work__name=$1
	# shift

    # local hand__config_path=$1
    # shift

    if [ ! -f $hand__config_path/default.props ]; then
        touch $hand__config_path/default.props
    fi

    # handle sub command
    local sub=$1
    shift
    case $sub in
    "show")
        hand_work__show
        ;;
    "on")
        hand_work__on $1
        #hand_work__show
        ;;
    "remove")
        hand_work_remove $*
        hand_work__show
        ;;
    *)
        hand echo error "work.sh: \"$sub\" not support"
        ;;
    esac
}

# persistently work on a workspace (save work name into a file)
hand_work__on()
{
	if [ $# -eq 0 ]; then
        hand echo error "no work name"
        return 1
    fi

    {
        flock 200
	    hand_work__name=$1
        # write current work name to file
        echo $hand_work__name > $hand__config_path/current_work
        # touch prop file
        #touch $hand__config_path/${hand_work__name}.props
    } 200>$hand__config_path/current_work

}

# remove a workspace
hand_work_remove()
{
	if [ $# -eq 0 ]; then
        hand echo error "no work name"
        return 1
    fi

	rm 	$hand__config_path/${1}.props
    if [ "$hand_work__name" = "$1" ]; then
        hand_work__on default
    fi
}


hand_work__show()
{
	echo "work space:"
	local i= name= list=()
    # if [ "$hand__base_config" != "" ]; then
    #     # echo with base config
    #     list=`ls `
    # fi

    # echo list: $list
	for i in `ls $hand__config_path/*.props $hand__config_path/../$hand__base_config/*.props`
	do
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
			echo "  *  "$name
		else
			echo "     "$name
		fi
	done

    # echo ${list[*]}
}


main "$@"
