
hand_update()
{
	if [ "$1" = "completions" ]; then
		#hand echo do "source $hand__path/hand-completions.bash"
		rm $hand__config_path/.completions.sh
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
	echo "$1 --- 重新载入handybox脚本"
	echo "$1 completions --- 更新handybox自动完成脚本"
}
