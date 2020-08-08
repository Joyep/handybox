hand_git_pushref__help()
{
	echo "简化gerrit推送"
	echo -e "$1 <remote> <branch>"
	echo -e "$1 <remote>/<branch>"
	echo -e "\t--- 相当于 git push <remote> HEAD:refs/for/<branch>"
}

#pushref
#pushref $remote/$branch
#pushref $remote $branch
hand_git_pushref()
{
	local remote
	local branch
	if [ $# -eq 0 ]; then
		remote=`hand --pure work getprop git.pushref.remote`
		if [ $? -ne 0 ]; then
			echo $remote
			return 1
		fi
		# remote=`hand__get_lastline $remote`

		branch=`hand --pure work getprop git.pushref.branch`
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
