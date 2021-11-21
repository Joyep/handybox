##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# cmd: repo gettop [ <params...> ]
##


case $1 in
	"-h"|"--help")
		echo -e "`hand__color cyan $hand__cmd`           \t--- Get nearest repo root path"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h\|--help` \t--- show help"
		;;
	*)
        local path1=`pwd`
        while true;
        do
            if [ -d $path1/.repo ]; then
                echo "$path1"
                return 0
            fi

            if [ "$path1" = "/" ] ; then
                # echo ""
                return 1
            fi

            path1=`dirname $path1`
            if [ $? -ne 0 ]; then
                return 1
            fi
        done
        ;;
esac