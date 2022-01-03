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
    echo -e "`hand__color cyan $hand__cmd` nodejs <poetry_project_dir> <python_file> [options]\t# Run nodejs npm project"
    return
    ;;
esac

# echo $*
local dir=$1
local file=$2
shift
shift
hand echo yellow "Run nodejs project: $dir/$file"
make -C $dir --no-print-directory && node $dir/$file $*
