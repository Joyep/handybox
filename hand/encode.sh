hand_encode()
{
	hand echo info "trans file to UTF-8 and unix format"
	hand echo do enca -L zh_CN -x UTF-8 $1
	hand echo do dos2unix $1
}

# hand_encode "$@"

