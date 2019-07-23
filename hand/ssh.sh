

hand_ssh()
{
	local sub=$1
    shift
	case $sub in
	"status")
		hand echo do sudo systemsetup -getremotelogin
		;;
	"on")
		hand echo do sudo systemsetup -setremotelogin on
		;;
	"off")
		hand echo do sudo systemsetup -setremotelogin off
		;;
	esac
}