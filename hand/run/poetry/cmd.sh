##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

case $1 in
 "-h"|"--help")
    echo -e "`hand__color cyan $hand__cmd` <poetry_project_dir> <python_file> [params...]\t# Run python peotry project"
    return
    ;;
esac

# poetry installed?
type poetry > /dev/null
if [ $? -ne 0 ]; then
	hand echo error "poetry not installed!"
	hand echo warn "Please refer https://python-poetry.org/docs/master/#installing-with-pipx to learn how to install."
	echo
	echo Try install poetry...
	echo

	# pipx installed?
	type pipx > /dev/null
	if [ $? -ne 0 ]; then
		# pipx not installed
		if [ $(uname) = "Darwin"  ]; then
			# macos install pipx
			hand echo do brew install pipx
		else
			# linux install pipx
			hand echo do python3 -m pip install --user pipx
			hand echo do python3 -m pipx ensurepath
		fi
	fi

	# install poetry via pipx
	hand echo do pipx install poetry
fi

# run now
if [ $# -eq 0 ]; then
	hand run poetry -h
	return
fi
local dir=$1
local file=$2
shift
shift
hand echo yellow "Run peotry project: $dir/$file"
hand sh "cd $dir; if [ ! -d dist ]; then poetry install; mkdir dist; fi; source \$(poetry env info --path)/bin/activate && cd - && python $dir/$file $* && deactivate"
