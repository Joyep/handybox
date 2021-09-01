##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand cd config
##

case $1 in
	"-h"|"--help")
		echo -e "$hand__cmd            \t# 切换到handybox配置目录"
		echo -e "$hand__cmd -h/--help  \t# Help"
		;;
	*)
		cd $hand__config_path
		;;
esac
