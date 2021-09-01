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
		echo "重新载入handybox脚本"
		echo -e "$hand__cmd           \t# update handybox main script"
		echo -e "$hand__cmd -h/--help \t# Show help"
		;;
	*)
		source $hand__path/hand.sh
		hand
		echo "update Handy Box success!"
		;;
esac

