

function hand_update()
{
	if [ "$1" == "completions" ]; then
		#hand echo do "source $HAND_PATH/hand-completions.bash"
		rm $hand__completion_prebuild
	fi
	hand echo do source $HAND_PATH/hand.sh
	echo "update Handy Box success!"
}
