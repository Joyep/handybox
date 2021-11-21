##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand cd git
##

case $1 in
	"-h"|"--help")
		shift
		echo -e "`hand__color cyan $hand__cmd`            \t# Go to the nearest git root path"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h/--help`  \t# Help"
		;;
	*)
		local path1
		path1=`hand git gettop -- pure`
		if [ $? -ne 0 ]; then
			# echo $path1
			hand echo error "get git top failed!"
			return 1
		fi

		if [[ ! -d "$path1" ]]; then
			hand echo red "git dir ($path1) not found!"
			return 1
		fi

		cd $path1
		;;
esac