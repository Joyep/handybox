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
		echo "管理handybox工作区"
		echo -e "$hand__cmd                \t# 展示所有工作区"
		echo -e "$hand__cmd on <name>      \t# 切换工作区"
		echo -e "$hand__cmd temp <name>    \t# 临时切换工作区(仅作用于当前shell环境)"
		echo -e "$hand__cmd remove <name>  \t# 删除工作区"
		echo -e "$hand__cmd getprop|setprop|modprop [-g] [-b] <key> [<value>|<operation>]"
		echo -e "                          \t# getprop: 获取属性<key>的值"
		echo -e "                          \t# setprop: 设置属性<key>的值为<value>"
		echo -e "                          \t# modprop: 对属性<key>的值执行<operation>以修改"
		echo -e "                          \t#      -g: 表示读写全局工作区的属性"
		echo -e "                          \t#      -b: 表示读写base工作区的属性"
		echo -e "$hand__cmd -h|--help      \t# Show help"
		return
		;;
	esac
fi

# determin work name
local work_file=$hand__config_path/current_work
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
hand_work__name=$hand_work__name
hand__base_config=$hand__base_config
hand__debug_disabled=$hand__debug_disabled
hand__config_path=${hand__config_path}"
# echo hand__debug_disabled: $hand__debug_disabled
case $1 in
"getprop"|"setprop"|"modprop")
	hand sh --env "$env_script" ${hand__cmd_dir}/prop.sh "$@"
	;;
"on")
	shift
	hand sh --env "$env_script" $hand__cmd_dir/work.sh on $1
	hand work temp $1
	;;
"temp")
	shift
	hand_work__name=$1
	hand work
	;;
*)
	if [ $# -eq 0 ]; then
		# no param, show current work
		hand sh --env "$env_script" $hand__cmd_dir/work.sh show
		return
	fi
	hand sh --env "$env_script" $hand__cmd_dir/work.sh $@
	;;
esac
