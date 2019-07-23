function hand_git_gettop()
{
    local path=`pwd`
    while true;
    do
        if [ -d $path/.git ]; then
            echo "$path"
            return 0
        fi

        if [ -d $path/.repo ]; then
            echo "$path"
            return 0
        fi

        if [ "$path" = "/" ] ; then
            echo ""
            return 1
        fi

        path=`dirname $path`
    done
}

# git_gettop "$@"
