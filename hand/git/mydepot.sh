
function hand_git_mydepot()
{
	local sub=$1
    shift
	case $sub in
	"clone")
		hand_git_mydepot__clone $*
		;;
	"init")
		hand_git_mydepot__init $*
		;;
	esac
}



#init $fromdir $togitdir
function hand_git_mydepot__init()
{
	#check params
    if [ $# -ne 2 ]; then
		hand echo error "params count must be 2"
		return 1
	fi

	#check path
    local dirpath=$1
    local gitpath=$mydepot_path/$2.git
	if [ ! -d $dirpath ] ; then
		hand echo error "dir path ($dirpath) not found!"
		return 1
	fi
	if [ -d $gitpath ]; then
		hand echo error "remote git dir ($gitpath) already exist!"
		return 1
	fi

	#start
	hand echo info "Creating bare git depository in $gitpath using $dirpath ..."

	#work on dirpath
	cd $dirpath

	local user=$hand_git_mydepot__user
	local ip=$hand_git_mydepot__path
	local path=$hand_git_mydepot__path

	#1, create a remote bare git repository
	if [ "$user" != "" ] && [ "$ip" != "" ] ; then
		# remote
		remote_do git init --bare $gitpath
		gitpath=$user@$ip:$gitpath
	else
		# local
		hand echo do git init --bare $gitpath
	fi
	if [ $? -ne 0 ]; then
		hand echo error "git init --bare failed!"
		return 1
	fi

	#2, init local git if need
	if [  ! -d .git ]; then
		hand echo do git init
	fi

	#3, add remote repository
	hand echo do git remote add origin $gitpath
	if [ $? -ne 0 ]; then
		hand echo warn "add remote error!"
	fi

	#4, set remote as default push
	#hand echo do git push --set-upstream origin master

	#5, show status
	hand echo do git status

	hand echo info "Remote depository $gitpath created!"

}

#clone $gitname
function hand_git_mydepot__clone()
{
	local user=$hand_git_mydepot__user
	local ip=$hand_git_mydepot__ip
	local path=$hand_git_mydepot__path

    if [ "$path" == "" ]; then
        echo "please define hand_git_mydepot__path"
        return
    fi

	local gitpath=""
	local sedstr="s%$path/%%g"
	
    if [ "$user" == "" ]; then
		#clone from local
		gitpath=$path/$1
		hand echo green "$gitpath"
		if [ ""  == "$1" ]; then
			find $path -name *.git | sed 's%'$path'/%%g'
			return 0
		fi
    else
		#clone from remote
		gitpath=$user@$ip:$path/$1
		hand echo green "$gitpath"
		if [ ""  == "$1" ]; then
			hand echo do ssh $user@$ip "find $path -name '*.git'" | sed 's%'$path'/%%g'
			return 0
		fi
    fi

	shift
	hand echo do git clone $gitpath $*

}

function hand_git_mydepot__workspace_default()
{
	hand echo debug hand_git_mydepot__workspace_default
	#hand_git_mydepot__user=
	#hand_git_mydepot__ip=
	#hand_git_mydepot__path=
}

hand work --load hand_git_mydepot




