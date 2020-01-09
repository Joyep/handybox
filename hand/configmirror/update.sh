function hand_configmirror_update()
{
	local need_sync=
	need_sync=`hand__getprop configmirror.support`
	if [[ $? -ne 0 ]] || [[ $need_sync -ne 1 ]]; then
		# do not need to sync config repository
		hand echo warn "do not support configmirror"
		hand echo warn "set prop configmirror.support=1 to enable!"
		return 0
	fi

	local config_git="handybox_config.git"

	local mydepot_path=
	mydepot_path=`hand__getprop git.mydepot.path`
	if [ $? -ne 0 ]; then
		echo $mydepot_path
		return 1
	fi

	hand echo do cd $mydepot_path/$config_git
	hand echo do git remote update
	# hand echo do git push
	hand echo do cd -

}