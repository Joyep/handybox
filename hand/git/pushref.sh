

#pushref $remote $branch
hand_git_pushref()
{
	if [ $# -ne 2 ]; then
		hand echo red "pushref need provide remote and branch!"
		return 1
	fi
	hand echo do git push $1 HEAD:refs/for/$2
}