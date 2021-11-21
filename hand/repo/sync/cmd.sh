##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# repo sync
##
case $1 in
	"-h"|"--help")
		echo -e "`hand__color cyan $hand__cmd`           \t# Call repo sync, retry if failed"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h\|--help` \t# show help"
		;;
	*)
		hand echo do repo sync
		while [ $? -ne 0 ]; do
			hand echo error "repo sync error, try again after 10s!"
			sleep 10
			hand echo do repo sync
		done
		echo "repo sync success!!!"
		;;
esac
