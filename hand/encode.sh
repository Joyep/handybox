hand_encode()
{
	enca -L zh_CN -x UTF-8 $1 && dos2unix $1
}

