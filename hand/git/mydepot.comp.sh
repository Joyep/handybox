
hand__complist_git_mydepot="clone init"
#completion $words
#hand__complist_git_mydepot__completion()
# {
#	if [ $# -lt 2 ]; then
#		compgen -W "$hand__complist_git_mydepot" -- "$1"
#	fi
# }

# for hand prop get/set completion list
hand__complist_prop_get="${hand__complist_prop_get}\
  git.mydepot.user\
  git.mydepot.ip\
  git.mydepot.path"
hand__complist_prop_set=${hand__complist_prop_get}