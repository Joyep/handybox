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
		echo -e "`hand__color cyan $hand__cmd`            \t# Go go handybox config path"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h/--help`  \t# Help"
		;;
	*)
		cd $hand__config_path
		;;
esac
