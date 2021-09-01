##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand cd [$params...]
##


case $1 in
	"-h"|"--help")
		echo -e "$hand__cmd            \t# 切换到handybox主目录"
		echo -e "$hand__cmd <type>     \t# 切换到<type>指定的目录"
		echo -e "$hand__cmd -h/--help  \t# Help"
		;;
	*)
		cd $hand__path
		;;
esac
