#!/bin/bash

# function _foo()
#  {
#      echo -e "\n"
 
#      declare -p COMP_WORDS
#      declare -p COMP_CWORD
#      declare -p COMP_LINE
#      declare -p COMP_WORDBREAKS
#  }
# complete -F _foo foo



#input COMP_WORDS array
#output COMPREPLY
hand__completion_entry() {
	local cmd comp
	for ((i=1; i<${COMP_CWORD}; i++ )); do
		if [ "${COMP_WORDS[i]:0:2}" == "--" ]; then
			continue
		fi
		cmd="${cmd}_${COMP_WORDS[i]}"
	done

	if [ "$(declare -F hand${cmd}__completion)" ]; then
		comp=$(hand${cmd}__completion ${COMP_WORDS[@]:i+1})
	else
		comp=`eval echo '$'hand__complist${cmd}`
	fi

	if [ -z "$comp" ]; then
		COMPREPLY=($(compgen -fd -- "${COMP_WORDS[COMP_CWORD]}"))
		return
	fi

	#echo math=${COMP_WORDS[i]}
	COMPREPLY=($(compgen -W "$comp" -- "${COMP_WORDS[COMP_CWORD]}"))
	return
}

if [[ "$SHELL" = "/bin/zsh" ]]; then
	fpath=($hand__path/completions $fpath)
	autoload -U _hand
	compdef _hand hand h hs hand__hub
else
	complete -F hand__completion_entry h
	# complete -F hand__completion_entry handy
	complete -F hand__completion_entry hand
	complete -F hand__completion_entry hs
fi


#gen $path $cmd
hand__completions_generate()
{
	# echo pathx=$pathx
	# echo ">>" Generate "$@ ============="
	local pathx=$1
	local path1
	local path2
	local cmd=$2
	local item
	local list=
	local list2=

	if [ -e $hand__path/hand/$pathx ]; then
		list="$(ls $hand__path/hand/$pathx | sed '/\.comp\.sh$/d')"
	fi

	if [ -e $hand__config_path/hand/$pathx ]; then
		list2="$(ls $hand__config_path/hand/$pathx | sed '/\.comp\.sh$/d')"
	fi

	if [ -z "$list" ] && [ -z "$list2" ]; then
		echo "$pathx is not a path!!!"
		return 1
	fi

	hand echo debug "completion: hand$cmd"

	list=(`echo $list $list2`)
	# echo list=$list
	#local list="$(ls $path | sed 's/.sh$//')"
	#eval hand__complist${cmd}='"$list"'

	#echo ===
	#echo path1=$path1
	#echo path2=$path2
	#ls $path1;ls $path2
	#echo ===

	# local words="$(echo $list | sed 's/ .*\.sh / /g')"
	local words=`echo $list | sed 's/\.sh//g'`
	# echo words=$words
	# echo '============'

	#eval hand__complist${cmd}='"${words}"'
	
	#eval hand__complist${cmd}='"$(echo "$list" | sed 's/\.sh//')"'

	#eval echo list2='$'hand__complist${cmd}
	#eval echo hand__complist${cmd}='\"'${words}'\"' >> $hand__completion_prebuild
	

	echo hand__complist${cmd}="'${words}'" >> $hand__completion_prebuild

	# echo "-------------1"
	local item=
	for item in $list
	do
		# echo "for item=$item:"
		if [ "${item##*.sh}" ]; then
			# echo item=$item
			# echo cmd=$cmd
			hand__completions_generate $pathx/$item "${cmd}_${item}"
		fi
		# echo "***2"
	done
}

hand__completions_load_sub()
{
	local f
	#echo "load sub..."
	for f in $(find $hand__path/hand $hand__config_path/hand -name "*.comp.sh")
	do
		hand echo debug "source $f"
		#echo "" >> $hand__completion_prebuild
		#echo "# $f" >> $hand__completion_prebuild
		echo -e "\n" >> $hand__completion_prebuild
		cat $f >> $hand__completion_prebuild
	done
}

#generate completions by hand dir
if [ ! -f $hand__completion_prebuild ]; then
	
	echo -e "#\n# THIS FILE IS GENERATED BY PROGRAM\n# DO NOT EDIT HERE!\n\n" >> $hand__completion_prebuild

	hand echo debug "generating completions..."
	hand__completions_generate

	hand echo debug "load sub completions..."
	hand__completions_load_sub
fi

source $hand__completion_prebuild