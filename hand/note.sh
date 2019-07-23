
# simple note searching



# note
#   gettop --- get note dir
#   setdir --- set note dir
#   search --- search keywords from note dir
#
function hand_note()
{
    local sub=$1
    shift

    case $sub in
    "gettop")
        if [ ! $hand_note__dir ]; then
            hand echo error "note dir not defined!"
            return 1
        fi
        echo $hand_note__dir
        ;;

    "setdir")
        local new_dir
        if [ ! $1 ]; then
            new_dir=`pwd`
        else
            if [ "${1:0:1}" == "/" ]; then
                # is absolute path
                new_dir=$1
            else 
                new_dir=`pwd`/$1
            fi
        fi

        if [ ! -d $new_dir ]; then
            hand echo error "$new_dir is not a dir!"
            return 1
        fi

        echo "note dir:  $new_dir"
        hand_note__dir=$new_dir

        ;;

    "grep")
        hand_note__search $*
        ;;
    "search")
        hand_note__search_all $*
        ;;
    *)
        echo 
        echo "========== simple txt note =============="
        echo "dir: $hand_note__dir"
        # echo "========================================="
        echo
        ;;
    esac

}


# search 搜索笔记内容
# search [keywords...]
#
#  根据关键字找到推荐目录, 优先在推荐目录里搜索, 
#  如果没有推荐如果没有找到推荐目录, 则在全局搜索.
#  支持多个关键字搜索
#
function hand_note__search()
{
    if [ ! $hand_note__dir ]; then
        hand echo error "hand_note__dir not defined!"
        return 1
    fi

    # get keywords and path
    local des_path=$hand_note__dir

    # get keywords
    local keywords=$*
    #echo $#
    # if [ $# -eq 1 ] ; then
    #     keywords=$1
    # elif [ $# -gt 1 ] ; then
    #     local p=`echo $* | awk '{print $NF}'`
    #     if [ -d $p ] ; then
    #         des_path=$p
    #         keywords=`echo $* | sed -r 's/\//x/g'  | sed -r 's/[  ]+\w+[  ]*$//g'`
    #     else
    #         keywords=$*
    #     fi
    # else
    #    echo_error "params error!"
    #    return
    # fi

    echo_warn "Search for [$keywords] in $des_path ..."

    # search recommanded paths
    echo_warn "Recommanded Paths >>>"

    # get recommanded paths as nice_paths
    local key=""
    local nice_paths=""
    for key in $keywords
    do
        # hand echo yellow "get nice path in $des_path by keyword $key" 
        nice_paths=`echo "$nice_paths $(hand_note__get_nice_path $key $des_path)"`
        # echo $nice_paths
        # echo "-----"
    done
    #echo nice_paths=$nice_paths


    # Del dumplex from nice_paths
    local temp_paths=""
    local temp_path=""
    local nice_path=""
    # create lines and sort
    nice_paths=`echo $nice_paths | sed -r 's/[ ]+/\n/g' | sort`
    for nice_path in $nice_paths
    do
        if [ "$temp_path" = "" ] || [[ ! "$nice_path" =~ $temp_path ]]; then
            #echo get a valid path $nice_path
            temp_path=$nice_path
            temp_paths=`echo "$temp_paths $temp_path"`
            continue
        fi
    done
    nice_paths=`echo $temp_paths | sed -r 's/[ ]+/\n/g' | sed -r '/^[ ]*$/d' | sort`

    # print nice paths
    echo "$nice_paths"
    #echo ""


    # Search in each nice path
    local has_nice_path=0
    for nice_path in $nice_paths
    do
        has_nice_path=1
        # search once
        hand_note__search_path "$keywords" "$nice_path"
    done

    # Search in gloable note path
    if [ $has_nice_path -eq 0 ] ; then
        #echo_warn "Other Paths >>>"
        hand_note__search_path "$keywords" "$des_path"
    fi
}

# note-grep-all 全局搜索笔记, 不做推荐
# search the it_path dir
function hand_note__search_all()
{
    if [ ! $hand_note__dir ]; then
        hand echo error "hand_note__dir not defined!"
        return 1
    fi
    hand_note__search_path "$*" $hand_note__dir
}




# search_path [keywords...] [path]
# 在指定路径里搜索内容中包含所有关键字的文件 (grep)
#
function hand_note__search_path()
{
    [ $# -ne 2 ] && echo_error "params error!" && return

    local keywords=$1
    local path=$2
    # local it_dir=$note_dir/IT/
    # local abs_path=${path#$it_dir}

    # find all note files
    local files=`find $path -name "*.txt"`

    # if $path string include some keywords, just search other keywords.
    #local temp_keywords=""
    #for key in $keywords
    #do
    #    [[ ! "$abs_path" =~ $key ]] && temp_keywords=`echo "$temp_keywords $key"`
    #done
    #keywords=$temp_keywords

    # but if null in $keywords after handled, use the first one
    # echo keywords=[$keywords]
    #if [ "$keywords" = "" ]; then
        # echo keywords is null
    #    keywords=`echo $1 | awk '{print $NF}'`
    #fi

    # now, search in file include all keywords
    # echo_warn "Search [$keywords] in $path >>>"
    for file in $files
    do
        # for one file
        fileabs=${file#$hand_note__dir}
        keyfile=""  #keyfile表示内容匹配关键字, 否则是文件名匹配
        for key in $keywords
        do
            # for one keyword
            # check file include the keyword
            if [[ "$fileabs" =~ $key ]] ; then
                # yes, the file include the keyword
                # now, check other keywords for this file
                # this file must include all keywords!!!
                continue
            else
                result=`grep -rn -i $key $file`
                if [ "$result" ]; then
                    # yes, the file include the keyword
                    # now, check other keywords for this file
                    # this file must include all keywords!!!
                    keyfile=$file
                    continue
                else
                    # oh NO, the file NOT include the keyword
                    # now, we know this file not match all keywords
                    # skip this file, check other files
                    continue 2
                fi
            fi
        done

        # find a match file
        echo
        echo_green $file

        # display grep result
        for key in $keywords
        do
            grep -rn -i $key $file


            # if [ $keyfile ] && [ -f $keyfile ]; then
            #     # file content match keyword, grep it
            #     #echo_info "get a keyfile $keyfile"
            #     grep -rn -i $key $keyfile
            #     break
            # else
            #     # file name match keyword, 
            #     #echo_info "judge from this file"
            #     result=`grep -rn -i $key $file`
            #     if [ "$result" ] ; then
            #         grep -rn $key $file
            #         break
            #     fi
            # fi
        done
        #echo "end"

    done

}

#
# get_nice_path [keyword] [path]
# 在路径中搜索包含关键字的路径 (find)
# 1. 找到所有包含关键字的目录名
# 2. 找到所有包含关键字的文件名
# 3. 去重
#
function hand_note__get_nice_path()
{
    # $1 key
    # $2 des_path

    # get all dir with key
    local paths=`find $2 -type d -iname "*$1*"` #all matched dir
    #echo paths=$paths

    # get all file names with key
    local paths2=`find $2 -iname "*$1*"` #all matched dir and file
    #echo paths2=$paths2

    # get path from the file names
    local filedir=""
    for p in $paths2
    do
        filedir=`dirname $p`
        if [ "$paths" = "" ] || [[ ! "$paths" =~ $filedir ]] ; then
            paths="$paths $filedir"
        fi
        #echo paths now =$paths
    done

    # sort path and del dumplet
    # paths=`echo $paths | sed -r 's/[ ]+/\n/g' | sort`

    # echo
    echo $paths
    #echo $paths | sed -r 's/[  ]+/\n/g' | sort
}

