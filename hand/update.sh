

hand_update()
{
	if [ "$1" = "completions" ]; then
		#hand echo do "source $hand__path/hand-completions.bash"
		rm $hand__completion_prebuild
		hand echo do source $hand__path/hand-completions.bash
		echo "update Handy Box Completions success!"
	else
		# hand echo do source $hand__path/hand.sh
		hand__load_file $hand__path/hand.sh hand "u"
		hand
		echo "update Handy Box success!"
	fi
}

