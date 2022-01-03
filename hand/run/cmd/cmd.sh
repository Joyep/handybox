##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

if [ $# -eq 0 ]; then
	hand run cmd -h
	return
elif [ $# -eq 1 ]; then
	case $1 in
	  "-h"|"--help")
		echo -e "`hand__color cyan $hand__cmd` <cmd.sh_file> [params...] \t# Run a handybox cmd.sh file directly"
		echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h\|--help`  \t\t# Help"
		return
		;;
	esac
fi

local file=$1
shift
if [ ! -f $file ] ; then
	hand echo error $file is not a file !
	return
fi
local dir=`dirname $file`
hand__cmd_dir=`pwd`/$dir
hand__cmd="hand run cmd $file"
source $file $*
