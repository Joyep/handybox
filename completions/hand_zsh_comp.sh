#compdef hand

comp_provide_values() {
	local comp=(${=@})
	if [ ${#comp} -gt 0 ]; then
		_values "hand" $comp
	fi
}

comp_provide_files() {
	_arguments \
		'*:files:_files' \
		# {-h,-h}'[Help of this command]' \
}

comp_dump() {
	echo
	echo cmd=${comp_dir}
	echo params: ${comp_params}
	echo params size: ${#comp_params}
	echo editing: $comp_editing
}

# local size=${#words}
local comp_editing=${words[CURRENT]}
local comp_dir=${hand__path}/completions
local comp_params=(${words[2, CURRENT-1]})

set -- $comp_params
source $comp_dir/comp.sh
