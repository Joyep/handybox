
if [[ "`hand__shell_name`" = "zsh" ]]; then
	fpath=($hand__path/completions $fpath)
	autoload -U hand_zsh_comp.sh
	compdef hand_zsh_comp.sh hand
	return 0
else
	source $hand__path/completions/hand_bash_comp.sh
	return 0
fi