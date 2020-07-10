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

hand_git_st $*