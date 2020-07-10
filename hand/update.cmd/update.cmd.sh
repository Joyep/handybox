
#help $cmd $params...
function help()
{
    echo "$1 --- 重新载入handybox脚本"
	echo "$1 completions --- 更新handybox自动完成脚本"
}


if [ "$1" = "completions" ]; then
    #hand echo do "source $hand__path/hand-completions.bash"
    rm $hand__config_path/.completions.sh
    source $hand__path/hand-completions.sh
    echo "update Handy Box Completions success!"
elif [ "$1" = "--help" ]; then
    shift
    help $*
else
    # hand echo do source $hand__path/hand.sh
    source $hand__path/hand.sh
    hand
    echo "update Handy Box success!"
fi
