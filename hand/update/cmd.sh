##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand update
##


case $1 in
	"-h"|"--help")
		shift
		echo -e "`hand__color cyan $hand__cmd`           \t# Reload handybox main script"
		echo -e "`hand__color cyan $hand__cmd` -h/--help \t# Show help"
		;;
	*)
		source $hand__path/hand.sh
		hand
		hand echo green "handybox main script updated!"
		;;
esac

