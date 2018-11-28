
function hand_remote()
{
	local sub=$1
    shift
	case $sub in
	"do")
		hand_remote__do $*
		;;
	"cpto")
		hand_remote__cpto $*
		;;
	"cpfrom")
		hand_remote__cpfrom $*
		;;
	*)
		hand_echo__error "$sub not support"
	esac
	return $?
}

#cp file/dir to remote (into default path)
function hand_remote__cpto()
{
	if [ "$hand_remote__user" == "" ] || [ "$hand_remote__ip" == "" ]; then
		hand echo error "remote user or remote ip not defined!"
		return 1
	fi

	hand echo do scp -r $1 $hand_remote__user@$hand_remote__ip:${hand_remote__path}
}

#cp file/dir from remote (from default path)
function hand_remote__cpfrom()
{
	echo

}

#do [-f] $cmd...
# -f: if cmd contains file or dir, copy them to remote path
#     and replace the file or dir a real remote path
function hand_remote__do()
{
	if [ "$hand_remote__user" != "" ] && [ "$hand_remote__ip" != "" ]; then	
		#support remote
		local remote=$hand_remote__user@$hand_remote__ip
		if [ "$1" == "-f" ]; then
			#copy file or dir in cmd, and then execute remote do
			shift
            local path=${hand_remote__path%\/}
			local params=""
			local p=
			for p in $* ; do
				#echo $p
				if [ -f $p ] || [ -d $p ]; then
					#file or dir found
					hand echo do scp -r $p $remote:$path
					p=$path/${p##*\/}
				fi
				params="$params $p"
			done
			hand echo do ssh $remote $params
		else
			#normal remote do
			hand echo do ssh $remote $*
		fi
		return $?
	fi
	
	hand echo error "remote not defined!"
	return 1
}

function hand_remote__workspace_default()
{
	echo "hand_remote load default config"
	#if [ "$hand_remote__ip" == "" ]; then
	#	hand_remote__ip="192.168.1.123"
	#	hand_remote__user="username"
	#	hand_remote__path="/path/to/remote/workpath"
	#fi
}

hand work --load hand_remote
