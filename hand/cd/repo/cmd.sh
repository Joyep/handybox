##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand cd repo
##


case $1 in
	"-h"|"--help")
		shift
		echo -e "$hand__cmd            \t# 切换到当前目录所在的repo根目录"
		echo -e "$hand__cmd -h/--help  \t# Help"
		;;
	*)
		local path1
		path1=`hand repo gettop -- pure`
		if [ $? -ne 0 ]; then
			# echo $path1
			hand echo error "get repo top failed!!"
			return 1
		fi

		if [[ ! -d "$path1" ]]; then
			hand echo red "repo dir ($path1) is invalid!"
			return 1
		fi

		cd $path1
		;;
esac

