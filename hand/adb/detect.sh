

function hand_adb_detect()
{
	adb shell echo "android device detected."
	if [ $? -ne 0 ]; then
		hand echo error "adb device not found!"
		return 1
	fi
	return 0
}

# adb_detect "$@"
