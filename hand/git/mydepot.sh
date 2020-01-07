
function hand_git_mydepot()
{
	local sub=$1
    shift
	case $sub in
	"clone")
		mydepot_clone $*
		;;
	"init")
		mydepot_init $*
		;;
	*)
		hand echo error "command not support!"
		;;
	esac
}



#init $fromdir $togitdir
function mydepot_init()
{
	#check params
    if [ $# -ne 2 ]; then
		hand echo error "params count must be 2"
		return 1
	fi

	local user
	user=`hand --silece prop get git.mydepot.user`
	if [ $? -ne 0 ]; then
		user=
	fi
	local ip
	ip=`hand --silece prop get git.mydepot.ip`
	if [ $? -ne 0 ]; then
		ip=
	fi
	local path1
	path1=`hand --silence prop get git.mydepot.path`
	if [ $? -ne 0 ]; then
		echo $path1
		hand echo error mydepot path not found!
		return 1
	fi

	#check path
    local dirpath=$1
    local gitpath=$path1/$2.git
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
function mydepot_clone()
{
	local user
	
	local path1
	path1=`hand --silence prop get git.mydepot.path`
    if [ $? -ne 0 ]; then
    	echo $path1
        # hand echo warn "git.mydepot.path not found! please set by:"
        # hand echo warn "hand prop set git.mydepot.path <your path>"
        return 1
    fi

    local ip
	ip=`hand --silence prop get git.mydepot.ip`
	if [ $? -ne 0 ]; then
		ip=""
	fi

	local gitpath=""
	local sedstr="s%$path1/%%g"
	user=`hand --silence prop get git.mydepot.user`
    if [ $? -ne 0 ]; then
		#clone from local
		gitpath=$path1/$1
		hand echo green "$gitpath"
		if [ ""  = "$1" ]; then
			echo $path1
			find $path1 -name "*.git" | sed 's%'$path1'/%%g'
			return 0
		fi
    else
		#clone from remote
		gitpath=$user@$ip:$path1/$1
		hand echo green "$gitpath"
		if [ ""  = "$1" ]; then
			hand echo do ssh $user@$ip "find $path1 -name '*.git'" | sed 's%'$path1'/%%g'
			return 0
		fi
    fi

	shift
	hand echo do git clone $gitpath $*

}


# git_mydepot "$@"


