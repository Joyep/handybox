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
        echo `hand__color cyan $hand__cmd` "\t# Get nearest git root path"
		;;
	*)
		local gitdir=
		gitdir=`git rev-parse --git-dir`
		if [ $? -eq 0 ]; then
			dirname $gitdir
		else
			return 1
		fi
        ;;
esac
