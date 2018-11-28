

function hand_android_gettop()
{
	local aroot=""

	hand__check_function_exist gettop
	if [ $? -eq 0 ]; then
		#1, just call gettop
		aroot=$(gettop)
	fi
	
	if [ "$aroot" == "" ]; then
		#2, try repo dir
		aroot=$(hand --silence repo gettop)
		if [ "$aroot" == "" ]; then
			#3, try git dir
			aroot=$(hand --silence git gettop)
			if [ "$aroot" == "" ]; then
				#4, not found
				return 1
			fi
		fi

		if [ ! -d $aroot/frameworks ] ; then
			#not android dir
			return 1
		fi
	fi

	echo $aroot
	return 0
}
