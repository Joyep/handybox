

function hand_adb_detect()
{
	adb shell echo
	if [ $? -ne 0 ]; then
		hand echo error "adb device not found!"
		return 1
	fi
	return 0
}