help()
{
	echo "切换到handybox配置目录"
}

if [ "$1" = "--help" ]; then
	shift
	help $*
else
	cd $hand__config_path
fi