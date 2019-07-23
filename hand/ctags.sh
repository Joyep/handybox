

CTAGS_DIR=".ctags"

# hand_ctags__used=`cat $CTAGS_DIR/current`

# get current ctags workspace name
function get_current()
{
	cat $CTAGS_DIR/current
}

# set current ctags workspace name
function set_current()
{
	echo $1 > $CTAGS_DIR/current
}

# main
#	ls --- show workspace
#	use --- use a workspace
#	show --- show a workspace
#	init|gen --- init a workspace
#   rm  --- remove a workspace
#	addpath --- add a path to current workspace
#	rmpath --- rm a path from current workspace
#
function hand_ctags()
{

	hand_ctags__used=`get_current`

	local sub=$1
	shift
	case $sub in

	"init"|"gen")
		#init [workspace name] paths...
		hand_ctags__init $*
		;;

	"use")

		local work
		local force

		if [ ! "$1" ]; then
			if [ ! "$hand_ctags__used" ]; then
				hand echo error "no workspace name!"
				return 1
			fi
			work=$hand_ctags__used
			force="--force"
		else
			work=$1
			shift

			if [ "$1" == "-f" ]; then
				force="--force"
			fi
			shift
		fi

		#use [workspace name]
		hand_ctags__apply $CTAGS_DIR/workspace_$work $force $*
		# if [ $? -eq 0 ]; then
			hand_ctags__ls
			hand_ctags__show
		# fi
		;;

	# "ls")
	# 	hand_ctags__ls
	# 	;;
	"show")

		hand_ctags__show $*
		;;

	"rm")
		echo "remove workspace of $1 ..."
		local workfile=$CTAGS_DIR/workspace_$1
		local tagfile=$CTAGS_DIR/tags_$1

		rm $workfile
		rm $tagfile
		echo "done"
		
		hand_ctags__ls

		;;

	"addpath")
		
		local work=$hand_ctags__used
		if [ ! "$work" ]; then
			hand echo error "no workspace used"
			return 1
		fi

		local workfile=$CTAGS_DIR/workspace_$work
		if [ ! -f $workfile ]; then
			hand echo error "workspace $work not exist!"
			return 1
		fi

		local path
		for path in $* ; do
			echo $path >> $workfile
		done
		

		echo "done"

		hand_ctags__show


		;;


	"rmpath")

		if [ ! $1 ]; then
			hand echo error "no path"
			return 1
		fi

		local work=$hand_ctags__used
		if [ ! "$work" ]; then
			hand echo error "no workspace used"
			return 1
		fi

		local workfile=$CTAGS_DIR/workspace_$work
		if [ ! -f $workfile ]; then
			hand echo error "workspace $work not exist!"
			return 1
		fi

		local path
		for path in $* ; do
			echo "rmpath $path"

			# if [ $(uname) == "Darwin" ]; then
			# 	sed -i "" '/'$path'/d' $workfile
			# else
				sed -i '/'$path'/d' $workfile
			# fi
		done

		hand_ctags__show
		;;

	*|"ls")
		hand_ctags__ls
		# hand echo error "$sub unsupported"
		;;

	esac
}


function hand_ctags__show()
{
	local work
	if [ $1 ]; then
		work=$1
	else
		work=$hand_ctags__used
	fi

	echo "paths of workpace $work:"
	echo "---"
	cat .ctags/workspace_$work
	echo "---"
}
function hand_ctags__ls()
{
	if [ ! -d $CTAGS_DIR ]; then
		hand echo warn "ctags workspace not found!"
		return 1
	fi
	echo "ctags workspace:"
	workspaces=`ls $CTAGS_DIR/workspace*`
	if [ $? -ne 0 ]; then
		hand echo warn "ctags workspace not found!"
		return 1
	fi
	
	local work
	for work in $workspaces; do
		work=${work##.ctags/workspace_}
		if [ "$work" == "$hand_ctags__used" ]; then
			echo " * "$work
		else
			echo "   "$work
		fi
	done
}

#ctagsgen [--cpp] workspace path1 path2 ...
function hand_ctags__init()
{
    #create ctags dir
    ctagsgen_path=".ctags"
    if [ ! -d $ctagsgen_path ] ; then
        mkdir $ctagsgen_path
    fi

    #handle for cpp language
    if [ $1 == "--cpp" ]; then
    	shift
        iscpp=1
    else
        iscpp=0
    fi
    workname=$1
    shift

    if [ $# -eq 0 ]; then
    	hand echo error "workspace paths not provided!"
    	return 1
    fi

	#create new file of this workspace
	file="$ctagsgen_path/workspace_$workname"
	rm $file -f
    i=0
	for p in $* ; do
	    echo "$p" >> $file
        let "i+=1"
	done

	# apply the list file
	# ctagsapply $file_name --force
    if [ $iscpp -eq 1 ]; then
	    hand_ctags__apply $file "--force" "--cpp"
    else
	    hand_ctags__apply $file "--force"
    fi
}

# apply workspace_file [--force] [--cpp] 
function hand_ctags__apply()
{
	echo "apply workspce $1 ..."
    # workspace_file="./$1"
 	local workspace_file="$1"
    # file eixst?
    if [ ! -f $workspace_file ]; then
    	hand echo error "$workspace_file is not a file!"
    	return 1
    fi

	local path=${workspace_file%/*}
    local file=${workspace_file##*/}
    local work=${file##workspace_}

    local workspace_file="$path/$file"
	local tags_file="$path/tags_$work"

	# update used workpace name
	hand_ctags__used=${file##workspace_}
    
    echo "paths of this workspace:"
   	echo "---"
	cat $workspace_file
    [ $? != 0 ] && hand echo error "ctags ERROR!!" && return
	echo "---"

    iscpp=0
    force=1
	if [ $# -ge 2 ]; then
	    if [ $2 == "--force" ]; then
	        force=1
	    fi
        if [ $# -ge 3 ]; then
	        if [ $3 == "--cpp" ]; then
                iscpp=1
            fi
        fi

	elif [ -f $tags_file ]; then
	    force=0
	fi

	set_current $hand_ctags__used
	if [ $force -eq 1 ]; then
	    #tags exist or set force then create it by ctags
	    if [ $iscpp -eq 1 ]; then
            ctags --languages=c++ --langmap=c++:+.c -R `cat $workspace_file`
        else
	        ctags -R `cat $workspace_file`
        fi
	    [ $? != 0 ] && hand echo error "ctags ERROR!!" && return
	    hand echo do "cp tags $tags_file"
	    hand echo info  "create tags success"
	else 
	    #if tags exist, use it
	    hand echo warn "tags already exist, use it"
	    hand echo do "cp $tags_file tags"
	fi
}


# hand_ctags "$@"