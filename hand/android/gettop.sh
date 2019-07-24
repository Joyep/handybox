
function hand_android_gettop()
{
	local aroot=

	# get root from $OUT
	if [ ! -z $OUT ]; then
		echo ${OUT%out*}
		return
	fi

	# get root from gettop
	hand__check_function_exist gettop
	if [ $? -eq 0 ]; then
		#1, just call gettop
		aroot=$(gettop)
		if [ "$aroot" != "" ]; then
			echo $aroot
			return
		fi
	fi
	
	# get root by repo/git dir 
	aroot=$(hand --silence repo gettop)
	if [ $? -ne 0 ]; then
		aroot=$(hand --silence git gettop)
		if [ $? -ne 0 ]; then
			# repo/git not found!
			return 1
		fi
	fi
	if [ ! -d "$aroot/frameworks" ] ; then
		# this dir is not an android dir
		return 1
	fi

	echo $aroot
}
