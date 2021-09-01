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
        echo "执行repo sync, 失败后重试"
		echo -e "$hand__cmd           \t--- call repo sync, retry if failed"
		echo -e "$hand__cmd -h/--help \t--- show help"
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
