function hand_repo_gettop()
{
	local path=`pwd`
    while true;
    do
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

# hand_repo_gettop "$@"