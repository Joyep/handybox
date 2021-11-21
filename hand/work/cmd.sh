##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand work
#      
# EXPORTED_VARIABLES:
#      hand_work__name   # current workspace name
##

if [ $# -eq 1 ]; then
	case $1 in
	"-h"|"--help")
		# local SKY='\033[96m'
		# local ITALIC='\033[3m'
		# local YELLOW='\033[33m'
		# local RES='\033[0m'        # 清除颜色
		echo "Manage handybox workspace"
		
		echo -e "`hand__color cyan $hand__cmd`               \t# Show all workspaces"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow on \<name\>`      \t# Switch workspace(create one if necessary)"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow temp \<name\>`    \t# Switch workspace Temporarily(only effect in current shell environment)"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow remove \<name\>`  \t# Remove a workspace"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow getprop\|setprop\|modprop \[-g\] \[\-b\] \<key\> \[\<value\>\|\<operation\>\]`"
		echo -e "                          \t# getprop: Get value of property <key>"
		echo -e "                          \t# setprop: Set property <key> with <value>"
		echo -e "                          \t# modprop: Modify property <key> by operating <operation>"
		echo -e "                          \t#      -g: Get/Set property of global workspace"
		echo -e "                          \t#      -b: Get/Set property of workspaces in base configuration"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h\|--help`      \t# Show help"

		return
		;;
	esac
fi


case $1 in
"on"|"temp"|"remove")
	if [ "$2" = "" ]; then
		hand echo error "no workspace name!"
		return
	fi
	if [ "$1" != "remove" ]; then
		hand_work__name=$2
	fi
	;;
esac


# get current work name
local work_file=$hand__config_path/.current_work
if [ "$hand_work__name" = "" ]; then
	if [ -f $work_file ]; then
		hand_work__name=`cat $work_file`
	fi
	if [ "$hand_work__name" = "" ]; then
		hand_work__name=default
		echo $hand_work__name > $work_file
	fi
fi

local env_script="\
hand__path=$hand__path
hand__debug_disabled=$hand__debug_disabled
hand__configs=\"${hand__configs[@]}\"
hand__config_path=${hand__config_path}
hand_work__name=$hand_work__name"
# echo env=$env_script

case $1 in
"getprop"|"setprop"|"modprop")
	hand sh --env "$env_script" ${hand__cmd_dir}/prop.sh "$@"
	;;
*)
	hand sh --env "$env_script" $hand__cmd_dir/work.sh $@
	if [ "$1" = "remove" ] && [ "$hand_work__name" = "$2" ]; then
		hand_work__name="default"
	fi
	;;
esac

# hand sh --env "$env_script" $hand__cmd_dir/work.sh $@

