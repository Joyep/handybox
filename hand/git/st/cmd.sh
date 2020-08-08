hand_git_st()
{
    if [ $# -eq 0 ]; then
        git status
        return $?
    fi
    local i
    for i in $* ; do
        cd $i
        hand echo yellow `pwd`
        hand echo do git status
        cd - > /dev/null
    done
}

hand_git_st__help()
{
    echo "$1 <path> --- 相当于跳转到<path>, 执行git status, 然后跳回来."
}