##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

#if [ $# -eq 0 ]; then
#	hand run cmd -h
#	return
#el
if [ $# -eq 1 ]; then
	case $1 in
	  "-h"|"--help")
		echo -e "`hand__color cyan $hand__cmd` [-f <cmd.sh_file>] [params...] \t# Run a handybox cmd.sh file directly"
		echo
		#return
		;;
	esac
fi

local file=
local default_file=
if [ "$1" = "-f" ]; then
	file=$2
	default_file=0
	shift
	shift
else
	file="cmd.sh"
	default_file=1
fi
if [ ! -f $file ] ; then
	hand echo error $file is not a file !
	return
fi

local dir=`dirname $file`
if [ "${dir##/*}" = "" ]; then
    hand__cmd_dir=$dir
else
    hand__cmd_dir=`pwd`/$dir
fi
if [ $default_file -eq 1 ]; then
	hand__cmd="hand run cmd"
else
	hand__cmd="hand run cmd -f $file"
fi
source $file $*
