##
# handybox sub command file
# V2.0
#
# ENV:
#      hand__cmd_dir  # dir of this cmd.sh
#      hand__cmd      # input cmd
##

if [ $# -eq 0 ]; then
	set -- "-h"
fi
case $1 in
  "-h"|"--help")
    echo -e "`hand__color cyan $hand__cmd` <gtp_cfg_hex_list...>\t# calculate the check sum of gtp cfg "
    echo -e "`hand__color cyan $hand__cmd` `hand__color yellow -h\|--help`  \t# Help"
	echo -e "\nfor example:"
	echo -e "`hand__color cyan $hand__cmd` 00 11 22 33 44 55 66"
    return
    ;;
esac

hand run bin $hand__cmd_dir .checksum2 $*
