#input COMP_WORDS array
#output COMPREPLY

comp_provide_values() {
    comp_values=(${comp_values[@]} ${@} )
}

comp_provide_files() {
    COMPREPLY=($(compgen -fd -- "${COMP_WORDS[COMP_CWORD]}"))
}

comp_dump() {
	echo
	echo cmd=${comp_dir}
	echo params: ${comp_params}
	echo editing: $comp_editing
}


hand__completion_entry() {

    local comp_editing=${COMP_WORDS[COMP_CWORD]}
    local comp_dir=${hand__path}/hand
    local comp_params=${COMP_WORDS[@]:1:COMP_CWORD-1}
    local comp_values=()

    set -- $comp_params
    source ${hand__path}/completions/comp.sh

    if [ ${#comp_values} -gt 0 ]; then
        COMPREPLY=($(compgen -W "${comp_values[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}

complete -F hand__completion_entry h
complete -F hand__completion_entry hand
