
#main function
function hand_adb_connect()
{
	if [ $# -ne 0 ]; then
		hand_adb_connect__last_ip_val=$1
	elif [ "$hand_adb_connect__last_ip_val" == "" ]; then
		hand echo error "please determin IP last value"
		return 1
	fi

	hand echo do adb disconnect
	hand echo do adb connect ${hand_adb_connect__prefix}.${hand_adb_connect__last_ip_val}
	adb devices
}

#default workspace
function hand_adb_connect__workspace_clear()
{
	hand_adb_connect__prefix=
}
function hand_adb_connect__workspace_default()
{
	#echo "hand_adb_connect load default config"
	if [ "$hand_adb_connect__prefix" == "" ]; then
		hand_adb_connect__prefix="192.168.1"
	fi
}
	

#load
hand work --load hand_adb_connect
