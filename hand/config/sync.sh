function hand_config_sync()
{

	local need_sync=
	need_sync=`hand__getprop config.sync.need`
	if [[ $? -ne 0 ]] || [[ $need_sync -ne 1 ]]; then
		# do not need to sync config repository
		# echo $need_sync
		hand echo warn "do not need to sync"
		return 0
	fi

	# if [[ $need_sync == 1 ]] && return 0

	local config_git="handybox_config.git"

	local mydepot_path=
	mydepot_path=`hand__getprop git.mydepot.path`
	if [ $? -ne 0 ]; then
		hand echo erro $mydepot_path
		# hand echo error "git.mydepot.path not found!"
		return 1
	fi

	hand echo do cd $mydepot_path/$config_git
	hand echo do git remote update
	hand echo do git push
	hand echo do cd -

}