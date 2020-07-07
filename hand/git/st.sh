hand_git_st()
{
    cd $1
    hand echo green `pwd`
    hand echo do git status
    cd - > /dev/null
}