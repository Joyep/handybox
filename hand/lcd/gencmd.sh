function hand_lcd_gencmd()
{
	python3 $hand__path/libs/mipi_cmd_formater/gen.py $*
}

# gencmd "$@"
