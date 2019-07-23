
#main function
function hand_adb_connect()
{
	echo "start of adb connect ..."
	# echo "params=$*"
	local port=5555

	# get ip value
	local ip=$1
	if [ "$ip" == "" ]; then
		ip=`hand prop get adb.connect.ip`
		if [ $? -ne 0 ]; then
			echo $ip
			hand echo error "please assign IP last value"
			return 1
		fi
		ip=`hand__get_lastline $ip`
	else
		# get a new ip value, save it
		hand prop set adb.connect.ip $ip
	fi


	# get ip prefix
	prefix=`hand prop get adb.connect.prefix`
	if [ $? -ne 0 ]; then
		echo $prefix
		hand echo warn "default ip prefix '192.168.199' used, you can also set prop adb.connect.prefix"
		# use default ip prefix
		prefix="192.168.199"
	else
		prefix=`hand__get_lastline $prefix`
	fi

	# ok, do disconnet and then connect
	hand echo do adb disconnect
	hand echo do adb connect "${prefix}.${ip}:${port}"

	# at last, show adb device list
	adb devices
}
	

# adb_connect "$@"
