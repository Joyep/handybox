
#cp file/dir to remote (into default path)
function remote_cpto()
{
	for file in $* ; do
		hand echo do scp -r $file $remote_user@$remote_ip:${remote_path}
	done
}

#cp file/dir from remote (from default path)
function remote_cpfrom()
{
	local file_path=
	for file in $* ; do
		if [ "${file:0:1}" = "/" ] || [ "${file:0:1}" = "~" ]; then
			file_path=$file
		else
			file_path=$remote_path/$file
		fi
		hand echo do scp -r $remote_user@$remote_ip:$file_path ./
	done
}

# expand_cmd_hand()
# {
# 	if [ "$1" = "hand" ] || [  "$1" =  "hand__hub" ]; then
# 		shift
# 		echo "\$HOME/bin/hand" "$@"
# 	else
# 		echo "$@"
# 	fi
# }


# # expand_cmd $cmd $params
# expand_cmd()
# {
# 	# echo ">  $@"
# 	# alias
# 	# cmd=`alias $1`
# 	# if [ $? -eq 0 ]; then
# 	local c=$1
# 	local cmd=`alias | grep "alias $c="`
# 	if [ "$cmd" != "" ]; then
# 		# alias got, do_command again
# 		# is_alias=1
# 		cmd=${cmd#*=}
# 		cmd=${cmd//\'/}
# 		if [ "$cmd" != "" ]; then
# 			# hand__echo_debug $cmd $*
# 			local first=`hand__get_first $cmd`
# 			if [ "$first" = "$c" ]; then
# 				# echo expanded cmd is the same
# 				expand_cmd_hand "$@"
# 			else
# 				shift
# 				expand_cmd $cmd "$@"
# 			fi	
# 		fi
# 	else
# 		expand_cmd_hand "$@"
# 	fi
# }


#do [-f] $cmd...
# -f: if cmd contains file or dir, copy them to remote path
#     and replace the file or dir a real remote path
function remote_do()
{

	#echo remote_do $@

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

	if [ $# -eq 0 ]; then
		hand echo do ssh $remote
		return $?
	fi

	# transfrom alias
	# local real_cmd=`expand_cmd $1`
	local real_cmd=$1
	shift
	# real_cmd=`hand__get_lastline $real_cmd`
	# echo real_cmd=$real_cmd

	# echo normal remote do
	local path1=${remote_path%\/}
	local params=""
	local p
	for p in "$@" ; do
		# echo copy_file=$copy_file
		if [ "$copy_file" = "1" ] && [ -f $p -o -d $p ]; then
			# echo file or dir found
			hand echo do scp -r $p $remote:$path1
			p=${p##*\/}
		fi
		# params="$params \\\"$p\\\""
		params="$params \\\\\\\"$p\\\\\\\""
	done
	local precmd="if [ \\\"\\\$ZSH_NAME\\\" != \\\"\\\" ]; then source ~/.zshrc ; else shopt -s expand_aliases ; source ~/.profile || source ~/.bashrc || source ~/.bash_profile ; fi"
	hand echo do ssh $remote "$precmd && cd $remote_path && eval $real_cmd $params"
}

# map local path to remote path
# map --human <local_path>
# return <remote_path>
map_remote_path()
{
	#echo start...
	local human=0
	if [ "$1" = "--human" ]; then
		shift
		human=1
	fi
	local f1=${1%%/}
	if [ "$f1" = "." ] || [ "$f1" = "" ]; then
		f1=`pwd`
	elif [ "${f1:0:1}" != "/" ]; then
		f1=`pwd`/$f1
	fi

	f1=`readlink -f $f1`

	#echo read prop

	# parse options
	local map_rules=
	map_rules=`hand work getprop remote.map.path -- pure`
	if [ $? -ne 0 ]; then
		echo $map_rules
		echo -e "属性remote.map.path: 配置本地路径与远程路径的映射关系."
		echo "格式: remote.map.path=\"<local_start>,<remote_start>[,windows][::...]\""
		echo "例如: remote.map.path=/ssd2,//192.168.199.95,windows::/home/daniel/work,//192.168.199.95/daniel,windows"
		return 1
	fi
	#echo map_rules: $map_rules
	#echo read ok

	if [ "$ZSH_NAME" != "" ]; then
		local rule_array=(${=map_rules//::/ })
	else
		local rule_array=(${map_rules//::/ })
	fi
	local rule=
	for rule in ${rule_array[@]}; do
		#echo try rule $rule ...
		if [ "$ZSH_NAME" != "" ]; then
			local section_arr=(${=rule//,/ })
		else
			local section_arr=(${rule//,/ })
		fi
		#echo ${section_arr[@]}

		local index=0
		if [ "$ZSH_NAME" != "" ]; then
			index=1
		fi
		local lstart=${section_arr[index]}
		local rstart=${section_arr[index+1]}
		local windows=${section_arr[index+2]}
		local is_windows=0
		if [ "$windows" = "windows" ]; then
			is_windows=1
		fi
		#echo "try to map from $lstart to $rstart ...(windows=$is_windows)"
		#echo "f1:          $f1"
		local rfile=
		rfile=${f1/$lstart/$rstart}
		#echo "rfile: $rfile"
		if [ "$rfile" = "$f1" ]; then
			#echo not match!
			continue
		fi

		#echo ok

		if [ $is_windows -eq 1 ]; then
			if [ $human -eq 1 ]; then
				if [ "$ZSH_NAME" != "" ]; then
					rfile=${rfile//\//\\\\}
				else
					rfile=${rfile//\//\\}
				fi
			else
				rfile="\\\\\\${rfile//\//\\\\\\\\}"
			fi
		fi
		echo "$rfile"
		break
	done

}


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

# hand remote do [command]
#
if [ $# -eq 1 ]; then
	case $1 in
	"-h"|"--help")
		echo "与远程计算机交互(基于ssh)"
		echo -e "$hand__cmd do [<command>]               \t# 在远程机执行命令"
		echo -e "$hand__cmd cpto <files/dirs...>         \t# 将文件或目录拷贝到远程机"
		echo -e "$hand__cmd cpfrom <files/dirs...>       \t# 从远程机拷贝文件或目录"
		echo -e "$hand__cmd compare <file1> <file2>      \t# 用bcomp比较两个文件"
		echo -e "$hand__cmd mappath <local_path>         \t# 查看本地路径<local_path>映射到远程机的路径"
		echo -e "$hand__cmd open [--select] <local_path> \t# 在远程机打开或选中本地文件或目录(需要先建立路径映射)"
		echo -e "$hand__cmd open [--code] <local_path>   \t# 在远程机用vscode打开本地文件或目录(需要先建立路径映射)"
		echo -e "$hand__cmd -h|--help                    \t# Show help"
		return
		;;
	esac
fi

if [ "$1" = "mappath" ]; then
	shift
	map_remote_path --human $1
	return
fi

local remote_user
remote_user=`hand work getprop remote.user -- pure`
if [ $? -ne 0 ]; then
	echo $remote_user
	# hand echo error "please define remote.user"
	return 1
fi
#echo user=$remote_user
local remote_ip
remote_ip=`hand work getprop remote.ip -- pure`
if [ $? -ne 0 ]; then
	echo $remote_ip
	# hand echo error "please define remote.ip"
	return 1
fi
#echo ip=$remote_ip
local remote_path
remote_path=`hand work getprop remote.path -- pure`
if [ $? -ne 0 ]; then
	echo $remote_path
	# hand echo error "please define remote.path!"
	return 1
fi
#echo path=$remote_path

#echo read init props done

local sub=$1
shift
case $sub in
"show")
	echo "ssh://$remote_user@$remote_ip:$remote_path"
	;;
"do")
	remote_do "$@"
	;;
# "ls")
# 	remote_do ls ${remote_path}
# 	;;
"cpto")
	remote_cpto $*
	;;
"cpfrom")
	remote_cpfrom $*
	;;
#"mappath")
#	map_remote_path --human $1
	#local f=`map_remote_path --human $1`
	#echo $f
#   ;;
"compare")
	# h bcompare --remote <file1> <file2>
	local f1=
	f1=`map_remote_path $1`
	if [ $? -ne 0 ]; then
		echo $f1
		return
	fi
	local f2=
	f2=`map_remote_path $2`
	if [ $? -ne 0 ]; then
		echo $f2
		return
	fi
	hand remote do bcomp "$f1" "$f2" &
	;;
"open")
	local options=
	local rcmd=open
	if [ "$1" = "--select" ]; then
		shift
		options="/select,"
	elif [ "$1" = "--code" ]; then
		shift
		rcmd=code
	fi
	local f1=
	f1=`map_remote_path $1`
	if [ $? -ne 0 ]; then
		echo $f1
		return
	fi
	hand remote do $rcmd "${options}$f1"
	#remote_open $*
	;;
*)
	hand echo error "$sub not support"
esac
return $?
