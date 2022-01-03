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
    echo -e "`hand__color cyan $hand__cmd` <ip:port>   \t# Set all proxy to <ip:port>"
    return
    ;;
esac

local ip=$1
if [ "$ip" = "" ]; then
	hand echo error "ip no provided! do clean"
	export https_proxy= http_proxy= all_proxy=
else
	export https_proxy=http://$ip http_proxy=http://$ip all_proxy=socks5://$ip
fi

echo https_proxy:$https_proxy
echo http_proxy:$http_proxy
echo all_proxy:$all_proxy
