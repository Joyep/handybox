#input COMP_WORDS array
#output COMPREPLY

comp_provide_values() {
    comp_values=(${comp_values[@]} ${@} )
}

comp_provide_files() {
    comp_with_file=1
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
    local comp_with_file=0

    set -- $comp_params
    source ${hand__path}/completions/comp.sh

    local comp_options=
    if [ $comp_with_file -eq 1 ]; then
        comp_options="-f"
    fi
    if [ ${#comp_values} -gt 0 ]; then
        COMPREPLY=($(compgen -W "${comp_values[*]}" $comp_options -- "${COMP_WORDS[COMP_CWORD]}"))
    elif [ $comp_with_file -eq 1 ]; then
        COMPREPLY=($(compgen -f -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
}

complete -F hand__completion_entry h
complete -F hand__completion_entry hand
