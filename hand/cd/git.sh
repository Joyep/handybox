function hand_cd_git()
{
	local path=$(hand --silence git gettop)
	if [ "$path" == "" ]; then
		hand echo red "git dir not found!"
		return
	fi
	cd $path
}
