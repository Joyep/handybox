##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand sh
##

if [ $# -eq 1 ]; then
	case $1 in
	"-h"|"--help")
		echo "Execute shell script file or command in a stand-alone process"
		echo -e "`hand__color cyan $hand__cmd` [--zsh/--bash] [--hand] [--env <script>] <file/cmd> [params...]"
		echo -e "                       \t# execute <file/cmd> in zsh/bash process with some env"
		echo -e "                       \t#   --hand: load handybox in execution env"
		echo -e "                       \t#   --env <script>: load <script> in execution env"
		echo -e "`hand__color cyan $hand__cmd` -h/--help   \t# Show help"
		return
		;;
	esac
fi

# parse options
local shell_env= script=
while true ; do
	case $1 in
	"--zsh")
		shell_env=zsh
		shift
		;;
	"--bash")
		shell_env=bash
		shift
		;;
	"--hand")
		shift
		script="\
if [ \"\$ZSH_NAME\" = \"\" ]; then
	shopt -s expand_aliases
fi
hand__load_completion=0
source ${hand__path}/hand.sh
$script"
		;;
	"--env")
		shift
		script="\
$1 
$script"
		shift
		;;
	*)
		break
		;;
	esac
done

# get shell_env by file
if [ "$shell_env" = "" ]; then
	if [ -f "$1" ]; then
		# echo "find shell env by file head"
		local file=`awk 'NR==1' $1`
		local file=${file:2}
		if [ -f "$file" ]; then
			shell_env=$file
		fi
	fi
	if [ "$shell_env" = "" ]; then
		# echo "using current shell env"
		if [ "$ZSH_NAME" = "zsh" ]; then
			shell_env=zsh
		else
			shell_env=bash
		fi
	fi
fi

local temp=$( mktemp )
cat > $temp <<EOF
$script
# echo "==========="
# echo "params: $@"
# echo "process: $shell_env"
# echo "hand version: \$hand__version"
# echo "zsh name: \$ZSH_NAME"
# echo "process: \$\$"
# echo "==========="
if [ -f "$1" ]; then
	source $@
else
	$@
fi
EOF

$shell_env $temp $@
local ret=$?
# echo temp file: $temp
# echo ">>>>>>>>"
# cat $temp
# echo "<<<<<<<<"
rm $temp
return $ret

