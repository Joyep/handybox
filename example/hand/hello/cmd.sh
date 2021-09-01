##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

##
# hand hello [$params...]
##


case $1 in
  "-h"|"--help")
    echo -e "$hand__cmd            \t# "
    echo -e "$hand__cmd <person>   \t# Say hello to <person>"
    echo -e "$hand__cmd -h/--help  \t# Help"
    ;;
  *)
    echo Hello ${1}!
    ;;
esac
