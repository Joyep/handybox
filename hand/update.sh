

hand_update()
{
	if [ "$1" = "completions" ]; then
		#hand echo do "source $hand__path/hand-completions.bash"
		rm $hand__completion_prebuild
		hand echo do source $hand__path/hand-completions.sh
		echo "update Handy Box Completions success!"
	else
		# hand echo do source $hand__path/hand.sh
		hand__load_file $hand__path/hand.sh hand "u"
		hand
		echo "update Handy Box success!"
	fi
}

hand_update__help()
{
	echo "== hand update =="
	echo "重新载入handybox主脚本"
	echo "子命令:"
	echo "  completions: 更新handybox命令行自动完成脚本"
	
}
