#
# 假如config目录的仓库是一个镜像仓库, 每次提交前需要对镜像仓库进行更新, 提交后要对镜像仓库进行推送
# 这里提供update和push命令达到这个目的
#
function hand_configmirror__help()
{
	echo "--- hand configmirror ---"
	echo "假如config目录的仓库是一个镜像仓库, 每次提交前需要对镜像仓库进行更新, 提交后要对镜像仓库进行推送"
	echo "这里提供update和push命令达到这个目的"
}

function hand_configmirror()
{
	local need_sync
	need_sync=`hand__pure_do hand prop get configmirror.support`
	if [[ $? -ne 0 ]] || [[ $need_sync -ne 1 ]]; then
		# do not need to sync config repository
		hand echo warn "do not support configmirror"
		hand echo warn "'hand prop set configmirror.support 1' to enable!"
		return 0
	fi

	local config_git
	config_git=`hand__pure_do hand prop get configmirror.git.path`
	if [[ $? -ne 0 ]]; then
		# hand echo error "prop configmirror.config.git not found!"
		echo $config_git
		return 1
	fi

	if [[ -d $config_git ]]; then
		hand echo error "$config_git is not a dir!"
		return 1
	fi

	local mydepot_path
	mydepot_path=`hand__pure_do hand prop get git.mydepot.path`
	if [ $? -ne 0 ]; then
		echo $mydepot_path
		return 1
	fi

	hand echo do cd $mydepot_path/$config_git
	case $1 in
	"update")	
		hand echo do git remote update
		;;
	"push")
		hand echo do git push
		;;
	esac
	hand echo do cd -
}
