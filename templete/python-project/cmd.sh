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
    echo -e "`hand__color cyan $hand__cmd`            \t# " Say hello
    echo -e "`hand__color cyan $hand__cmd` `hand__color yellow \<person\>`   \t# Say hello to <person>"
    echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h\|--help`  \t# Help"
    return
    ;;
esac

local hello_to=$1
if [ "$hello_to" = "" ]; then
  hello_to=`hand work getprop hello.to -- pure`
  if [ $? -ne 0 ]; then
	  hello_to=""
  fi
fi

hand run poetry $hand__cmd_dir main.py $hello_to
