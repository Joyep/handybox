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
		echo -e "`hand__color cyan $hand__cmd`            \t# Go to handybox home path"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow \"<type>\"`     \t# Go to path determined by <type>"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h/--help`  \t# Help"
		;;
	*)
		cd $hand__path
		;;
esac
