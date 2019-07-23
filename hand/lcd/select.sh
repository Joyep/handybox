

hand_lcd_select()
{
	local dir=/sys/class/misc/lcd_select/device
 	local hw_select=`adb shell cat ${dir}/hw_select`;
    local select=`adb shell cat ${dir}/select`;
    local name=`adb shell cat ${dir}/name`;
    echo "Sublcd select info:";
    echo "hw_select=${hw_select}";
    echo "select=${select}";
    echo "name=${name}"
}

# lcd_select_info "$@"