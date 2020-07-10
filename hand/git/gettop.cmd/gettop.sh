function hand_git_gettop()
{
    local path1=`pwd`
    while true;
    do
        if [ -d $path1/.git ]; then
            echo "$path1"
            return 0
        fi

        if [ -d $path1/.repo ]; then
            echo "$path1"
            return 0
        fi

        if [ "$path1" = "/" ] ; then
            # echo ""
            return 1
        fi

        path1=`dirname $path1`
        if [ $? -ne 0 ]; then
            return 1
        fi
    done
}

hand_git_gettop__help()
{
    echo "获取当前目录所在的git根目录路径"
}

hand_git_gettop $*
