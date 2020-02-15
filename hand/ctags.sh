#
# hand ctags
#
# a ctags project manager.
#

# 概念定义
# ctags工程: 目录下包含.ctags的工程. 例如
# workspace: 一个ctags工程可以包含多个workspace, 每个workspace定义一个对代码的某个视图.

# usage
#	ctags --- display all workspaces
#   ctags show --- show detail of a workspace
#	ctags init --- init a workspace
#	ctags use --- switch to a workspace
#   ctags rm --- remove a workspace
#	ctags addpath --- add a path to current workspace
#	ctags rmpath --- rm a path from current workspace
#


 hand_ctags()
{
	local sub=$1
	shift
	case $sub in

	"init"|"gen")
		#init [workspace name] paths...
		hand_ctags__gen $*
		hand_ctags__ls
		;;

	"use")
		hand_ctags__use $*
		;;

	"show")
		hand_ctags__show $*
		;;

	"rm")
		hand_ctags__rm $*
		hand_ctags__ls
		;;

	"addpath")
		hand_ctags__addpath $*
		hand_ctags__show
		;;

	"rmpath")
		hand_ctags__rmpath $*
		hand_ctags__show
		;;

	*)
		hand_ctags__ls
		# hand echo error "$sub unsupported"
		;;

	esac
}

# get top dir which include .ctags
hand_ctags__gettop()
{
    local path1=`pwd`
    while true;
    do
        if [ -d $path1/.ctags ]; then
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

# rmpath [paths...]
# remove path for current workspace
hand_ctags__rmpath()
{
	# find .ctags dir
	local topdir
	topdir=`hand_ctags__gettop`
	if [ $? -ne 0 ]; then
		# ctags dir not found, use current path
		hand echo error "ctags workspace NOT found!"
		hand_ctags__help
		return 1
	fi

	local work
	work=`cat $topdir/.ctags/current`
	if [ $? -ne 0 ] || [ ! "$work" ]; then
		hand echo error "no workspace used"
		return 1
	fi

	local workfile=$topdir/.ctags/workspace_$work
	if [ ! -f $workfile ]; then
		hand echo error "workspace $work not exist!"
		return 1
	fi

	local path1
	for path1 in $* ; do
		echo "rmpath $path1"

		# if [ $(uname) = "Darwin" ]; then
		# 	sed -i "" '/'$path'/d' $workfile
		# else
			# sed -i '/'$path1'/d' $workfile
			sed -i $path1'd' $workfile
		# fi
	done

	# hand_ctags__show
}

# addpath [paths...]
# add paths to current workspace
hand_ctags__addpath()
{
	# find .ctags dir
	local topdir
	topdir=`hand_ctags__gettop`
	if [ $? -ne 0 ]; then
		# ctags dir not found, use current path
		hand echo error "ctags workspace NOT found!"
		hand_ctags__help
		return 1
	fi

	local work
	work=`cat $topdir/.ctags/current`
	if [ $? -ne 0 ] || [ ! "$work" ]; then
		hand echo error "no workspace used"
		return 1
	fi

	local workfile=$topdir/.ctags/workspace_$work
	# if [ ! -f $workfile ]; then
	# 	hand echo error "workspace $work not exist!"
	# 	return 1
	# fi

	# current dir
	local pwd=`pwd`

	local path1
	local path2
	for path1 in $* ; do
		path2=$pwd/$path1
		if [ ! -d $path2 ]; then
			hand echo warn "Skip invalid dir --- $path2"
			continue
		fi
		# transform path related to $topdir
		echo ${path2##${topdir}/} >> $workfile
		# echo $path1 >> $workfile
	done
	
	# echo "done"

	# hand_ctags__show
}

hand_ctags__rm()
{
	# find .ctags dir
	local topdir
	topdir=`hand_ctags__gettop`
	if [ $? -ne 0 ]; then
		# ctags dir not found, use current path
		hand echo error "ctags workspace NOT found!"
		hand_ctags__help
		return 1
	fi

	# works to delete
	local works
	if [ ! $1 ]; then
		works=`cat $topdir/.ctags/current`
	else
		works=$*
	fi

	# do delete
	local work
	for work in $works ; do	
		echo "remove workspace of \"$work\" ..."
		hand echo do rm $topdir/.ctags/workspace_$work
		hand echo do rm $topdir/.ctags/tags_$work
		# if [ "$current" = "$work" ]; then
		# 	echo "" > $topdir/.ctags/current
		# fi
	done
}

 hand_ctags__show()
{
	# find .ctags dir
	local topdir
	topdir=`hand_ctags__gettop`
	if [ $? -ne 0 ]; then
		# ctags dir not found, use current path
		hand echo error "ctags workspace NOT found!"
		hand_ctags__help
		return 1
	fi

	local work
	if [ $1 ]; then
		work=$1
	else
		work=`cat $topdir/.ctags/current`
	fi

	echo "paths of workpace \"$work\""
	echo "---"
	cat $topdir/.ctags/workspace_$work
	echo "---"
}

hand_ctags__help()
{
	# echo "hand ctags"
	echo "hand ctags gen [workspace_name] [paths...] --- 创建workspace"
}

# use $workspace [-f]
hand_ctags__use()
{
	# find .ctags dir
	local topdir
	topdir=`hand_ctags__gettop`
	if [ $? -ne 0 ]; then
		# ctags dir not found, use current path
		hand echo error "ctags workspace NOT found!"
		hand_ctags__help
		return 1
	fi

	# parse params
	local work
	local force
	if [ ! "$1" ]; then
		# no param
		# get current workspace
		local current
		current=`cat $topdir/.ctags/current`
		if [ $? -ne 0 ] || [ ! "$current" ]; then
			hand echo error "no workspace name!"
			return 1
		fi
		work=$current
		force="--force"

		hand echo info "Force apply current workspace \"$work\"..."
	else
		work=$1
		shift
		if [ "$1" = "-f" ]; then
			force="--force"
		fi
		shift
	fi

	# set workspace
	echo $work > $topdir/.ctags/current

	#use [workspace name]
	hand_ctags__apply $topdir/.ctags/workspace_$work $force $*
	# if [ $? -eq 0 ]; then
		hand_ctags__ls
		# hand_ctags__show
	# fi
}


 hand_ctags__ls()
{

	# find .ctags dir
	local topdir
	topdir=`hand_ctags__gettop`
	if [ $? -ne 0 ]; then
		# ctags dir not found, use current path
		hand echo error "ctags workspace NOT found!"
		hand_ctags__help
		return 1
	fi

	echo "ctags workspace (in $topdir)"
	workspaces=`ls $topdir/.ctags/workspace*`
	if [ $? -ne 0 ]; then
		hand echo warn "no workspace!"
		return 1
	fi
	
	# get current workspace
	local current=`cat $topdir/.ctags/current`
	local work
	for work in $workspaces; do
		work=${work##$topdir/.ctags/workspace_}
		if [ "$work" = "$current" ]; then
			echo " * "$work
		else
			echo "   "$work
		fi
	done
}

#ctagsgen [--cpp] workspace path1 path2 ...
 hand_ctags__gen()
{
	# find .ctags dir
	local topdir
	topdir=`hand_ctags__gettop`
	if [ $? -ne 0 ]; then
		# ctags dir not found, use current path
		topdir=`pwd`
	fi

	# if [ ! -d $topdir ]; then
	# 	# topdir invalid
	# 	hand echo error "ctags top dir ($topdir) invalid!!"
	# 	return 1
	# fi

    # create ctags dir if need
	#local ctagsgen_path
    #ctagsgen_path=".ctags"
    if [ ! -d "$topdir/.ctags" ] ; then
        mkdir "$topdir/.ctags"
    fi
	hand echo green "ctags dir: $topdir/.ctags/"

    #handle for cpp language
    local iscpp
	if [ $1 = "--cpp" ]; then
    	shift
        iscpp=1
    else
        iscpp=0
    fi

	# get workspace name
	local workname
    workname=$1
    shift

	# handle paths
    if [ $# -eq 0 ]; then
    	hand echo error "workspace paths not provided!"
    	return 1
    fi

	# check workspace file exist
	file="$topdir/.ctags/workspace_$workname"
	if [ -f $file ]; then
		hand echo warn "workspace already exist!"
		return 1
	fi
	# rm $file -f
    
	# gen workspace file
	hand echo green "Generating a ctags workspace \"$workname\" ..."
	
	# write all paths into this workspace file
	# i=0
	# for p in $* ; do
	#     echo "$p" >> $file
    #     let "i+=1"
	# done

	# set workspace
	echo $workname > $topdir/.ctags/current
	
	# add paths into this workspace
	hand_ctags__addpath $*

	# apply this workspace
	# ctagsapply $file_name --force
    if [ $iscpp -eq 1 ]; then
	    hand_ctags__apply $file "--force" "--cpp"
    else
	    hand_ctags__apply $file "--force"
    fi
}

# apply workspace_file [--force] [--cpp] 
 hand_ctags__apply()
{
	hand echo info "Apply workspce $1 $2 ..."
    # workspace_file="./$1"
 	local workspace_file="$1"
    # file eixst?
    if [ ! -f $workspace_file ]; then
    	hand echo error "$workspace_file is not a file!"
    	return 1
    fi

	local path1=${workspace_file%/*}
    local file=${workspace_file##*/}
    local work=${file##workspace_}

    # local workspace_file="$path1/$file"
	local tags_file="$path1/tags_$work"

	# update used workpace name
	# hand_ctags__used=${file##workspace_}
    
	# show detail of this workspace
    echo "paths of this workspace:"
   	echo "---"
	cat $workspace_file
    [ $? != 0 ] && hand echo error "ctags ERROR!!" && return
	echo "---"

    local iscpp=0
    local force=1
	if [ $# -ge 2 ]; then
	    if [ $2 = "--force" ]; then
	        force=1
	    fi
        if [ $# -ge 3 ]; then
	        if [ $3 = "--cpp" ]; then
                iscpp=1
            fi
        fi

	elif [ -f $tags_file ]; then
	    force=0
	fi

	# hand_ctags__set_current $work
	# echo $work > $topdir/.ctags/current

	# generate tags file
	if [ $force -eq 1 ]; then
	    # tags not exist or by force
		# create it by ctags
		local pwd=`pwd`
		cd $topdir
	    if [ $iscpp -eq 1 ]; then
            ctags --languages=c++ --langmap=c++:+.c -R `cat $workspace_file`
        else
	        ctags -R `cat $workspace_file`
        fi
	    [ $? != 0 ] && hand echo error "ctags ERROR!!" && return
	 	cd $pwd
	    hand echo info "create tags success"
		hand echo do "cp $topdir/tags $tags_file"
	else 
	    #if tags exist, use it
	    hand echo info "tags already exist, use it"
	    hand echo do "cp $tags_file $topdir/tags"
	fi
}

# get current ctags workspace name
 hand_ctags__get_current()
{
	cat $CTAGS_DIR/current
}

# set current ctags workspace name
 hand_ctags__set_current()
{
	echo $1 > $CTAGS_DIR/current
}