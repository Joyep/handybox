
# props:
#		remote.user
#		remote.ip
#		remote.path
# subcmds:
#		do
#		ls
#		cpto
#		cpfrom
#
function hand_remote()
{

	remote_user=`hand__pure_do hand prop get remote.user`
	if [ $? -ne 0 ]; then
		echo $remote_user
		# hand echo error "please define remote.user"
		return 1
	fi
	remote_ip=`hand__pure_do hand prop get remote.ip`
	if [ $? -ne 0 ]; then
		echo $remote_ip
		# hand echo error "please define remote.ip"
		return 1
	fi

	remote_path=`hand__pure_do hand prop get remote.path`
	if [ $? -ne 0 ]; then
		echo $remote_path
		# hand echo error "please define remote.path!"
		return 1
	fi

	local sub=$1
    shift
	case $sub in
	"do")
		remote_do "$@"
		;;
    "ls")
		remote_do ls ${remote_path}
        ;;
	"cpto")
		remote_cpto $*
		;;
	"cpfrom")
		remote_cpfrom $*
		;;
	*)
		hand echo error "$sub not support"
	esac
	return $?
}

#cp file/dir to remote (into default path)
function remote_cpto()
{
	hand echo do scp -r $1 $remote_user@$remote_ip:${remote_path}
}

#cp file/dir from remote (from default path)
function remote_cpfrom()
{
	hand echo do scp -r $remote_user@$remote_ip:${remote_path}/$1 ./

}

expand_cmd_hand()
{
	if [ "$1" = "hand" ] || [  "$1" =  "hand__hub" ]; then
		shift
		echo "\$HOME/bin/hand" "$@"
	else
		echo "$@"
	fi
}


# expand_cmd $cmd $params
expand_cmd()
{
	# echo ">  $@"
	# alias
	# cmd=`alias $1`
	# if [ $? -eq 0 ]; then
	local c=$1
	local cmd=`alias | grep "alias $c="`
	if [ "$cmd" != "" ]; then
		# alias got, do_command again
		# is_alias=1
		cmd=${cmd#*=}
		cmd=${cmd//\'/}
		if [ "$cmd" != "" ]; then
			# hand__echo_debug $cmd $*
			local first=`hand__get_first $cmd`
			if [ "$first" = "$c" ]; then
				# echo expanded cmd is the same
				expand_cmd_hand "$@"
			else
				shift
				expand_cmd $cmd "$@"
			fi	
		fi
	else
		expand_cmd_hand "$@"
	fi
}


#do [-f] $cmd...
# -f: if cmd contains file or dir, copy them to remote path
#     and replace the file or dir a real remote path
function remote_do()
{

	# echo remote_do $@

	if [ "$remote_user" = "" ] || [ "$remote_ip" = "" ]; then
		hand echo error "remote not defined!"
		return 1
	fi

	#support remote
	local remote=$remote_user@$remote_ip

	#options
	if [ "$1" = "-f" ]; then
		shift
		# echo "should copy file"
		local copy_file=1
	fi

	# transfrom alias
	local real_cmd=`expand_cmd $1`
	shift
	# real_cmd=`hand__get_lastline $real_cmd`

	# echo real_cmd=$real_cmd

	if [ $copy_file ]; then
		#copy file or dir in cmd, and then execute remote do
        local path1=${remote_path%\/}
		local params=""
		local p=
		for p in $* ; do
			#echo $p
			if [ -f $p ] || [ -d $p ]; then
				#file or dir found
				hand echo do scp -r $p $remote:$path1
				p=${p##*\/}
			fi
			params="$params $p"
		done
		hand echo do ssh $remote "cd $remote_path && $real_cmd $params"
	else
		#normal remote do
        if [ $# -gt 0 ]; then
		    hand echo do ssh $remote "cd $remote_path && $real_cmd $@"
        else
		    hand echo do ssh $remote
        fi
	fi
}

# hand_remote "$@"
