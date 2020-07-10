# echo "cd handybox home"
# echo $$
# cd $hand__path
# echo $#
if [ $# -eq 0 ]; then
	cd $hand__path
elif [ "$1" = "--help" ]; then
	echo "切换到handybox主目录"
else
	echo "Unknown path $*"
fi