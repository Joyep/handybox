

#emulator $avd_name
hand_android_emulator()
{
	if [ $# -eq 0 ]; then
		#show avd list
		ls $HOME/.android/avd/ | grep avd
		return
	fi
	# start emulator
	cd $ANDROID_HOME/tools
	./emulator -avd $1
	cd -
}

# android_emulator "$@"
