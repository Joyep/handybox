##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

case $1 in
"-h"|"--help")
    echo -e "`hand__color cyan $hand__cmd` <dir> <excutable_file> [options]\t# Run an executable file"
    return
    ;;
esac

# echo $*
local dir=$1
local file=$2
shift
shift
hand echo yellow "Run executable: $dir/$file"
make -C $dir --no-print-directory && $dir/$file $*
