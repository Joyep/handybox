function hand_cd_repo()
{
	#hand --load repo gettop
	local path=$(hand --silence repo gettop)
	if [ "$path" == "" ]; then
		hand echo red "repo dir not found!"
		return
	fi
	cd $path
}
