#
# 当前work名字 --- 从文件读取
# hand work on  --- 设置到文件
# hand work temp --- 设置到环境
# hand work setprop --- 设置到文件
# hand work getprop --- 从文件读取

# work.sh --work=abc getprop test.abc
# work.sh --work=abc setprop test.abc xxx

if [ "$1" = "temp" ] || [ "$1" = "on" ] ; then
    # update work name
    hand_work__name=$2
fi
bash $hand__cmd_dir/work.sh --work=$hand_work__name --config_dir=$hand__config_path $*
