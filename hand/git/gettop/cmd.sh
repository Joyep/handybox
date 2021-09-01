##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# cmd: git gettop ${params...}
#                 -h/--help             # show help
##

case $1 in
	"-h"|"--help")
		shift
        echo $hand__cmd "获取当前目录所在的git根目录路径"
		;;
	*)
        local path1=`pwd`
        while true;
        do
            if [ -d $path1/.git ]; then
                echo "$path1"
                return 0
            fi

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