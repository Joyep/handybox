
#pushref $remote/$branch
#pushref $remote $branch
hand_git_pushref()
{
	local remote
	local branch
	if [ $# -eq 0 ]; then
		remote=`hand --pure prop get git.pushref.remote`
		if [ $? -ne 0 ]; then
			echo $remote
			return 1
		fi
		# remote=`hand__get_lastline $remote`

		branch=`hand --pure prop get git.pushref.branch`
		if [ $? -ne 0 ]; then
			echo $branch
			return 1
		fi
		# branch=`hand__get_lastline $branch`
		
	elif [ $# -eq 1 ]; then
		# hand echo do git push ${1/\/*} HEAD:refs/for/${1#*\/}
		remote=${1/\/*}
		branch=${1#*\/}
	elif [ $# -eq 2 ]; then
		# hand echo do git push $1 HEAD:refs/for/$2
		remote=$1
		branch=$2
	else
		hand echo red "pushref need provide remote and branch!"
		return 1
	fi

	hand echo do git push $remote HEAD:refs/for/$branch
}

hand_git_pushref $*