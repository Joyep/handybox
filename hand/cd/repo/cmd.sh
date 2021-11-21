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
		echo -e "`hand__color cyan $hand__cmd`            \t# Go to the nearest repo root path"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h/--help`  \t# Help"
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

