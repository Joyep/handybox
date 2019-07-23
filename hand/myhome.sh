

hand_myhome()
{
	local sub=$1
    shift
	case $sub in
	"link")
		hand_myhome__link $* 
		;;
	"unlink")
		hand_myhome__unlink $*
		;;
	"apply")
		hand_myhome__apply $*
		;;
	esac
}


#
# apply home file
# cmd $file
function hand_myhome__apply()
{
    local computer=`computer_name`
    local myhome=$hand__config_path/home
    local file=${1##*/}

	if [ ! -f "$myhome/$file" ]; then
        hand echo error "Error: file ($myhome/$file) not found!"
		return
	fi

	# 1, backup this file: mv $HOME/file $HOME/file_mybak
	if [ -e "$HOME/$file" ] ; then
        echo "backup $HOME$file"
		mv $HOME/$file $HOME/${file}_mybak  #backup home file
	fi

	# 2, create a link $HOME/file, link to $myhome/file
	ln -sf $myhome/$file $HOME/$file
	if [ $? -ne 0 ] ; then
		hand echo error "Error: create link failed!"
		mv $HOME/${file}_mybak $HOME/$file  #restore home file
		ll $HOME/$file
		return 0
	fi

	# success
	echo "apply link success!"
	ll $HOME/$file


}

#
# if myhome file exist and home file is a link, then
# cp myhome file to home file
#
function hand_myhome__unlink()
{
    local computer=`computer_name`
    local myhome=$hand__config_path/home
    local file=${1##*/}


	#if [ ! -f "$myhome/$file" ]; then
    #    echo "Error: file ($myhome/$file) not found!"
	#	return
	#fi

	if [ ! -L "$HOME/$file" ]; then
		hand echo error "Error: home file ($HOME/$file) not exist or is not a link!"
		return
	fi

	mv $HOME/$file $HOME/${file}_mybak  #backup home file
	cp $myhome/$file $HOME/$file

	ls -al $HOME/$file
	echo "unlink success!"
}

#
# if home file exist, then
# mv home file to myhome file
# create a link home file linked to myhome file
#
function hand_myhome__link()
{
    local computer=`computer_name`
    local myhome=$hand__config_path/home
    local file=${1##*/}

	if [ ! -f "$HOME/$file" ]; then
        hand echo error "Error: file ($HOME/$file) not found!"
		return
	fi

	if [ -L "$HOME/$file" ]; then
		hand echo error "Error: home file ($HOME/$file) is a link! ignore."
		ls -al $HOME/$file
		return
	fi

	if [ ! -d $myhome ]; then
		mkdir -p $myhome
	fi

	mv $HOME/$file $myhome/  #do mv
	ln -s $myhome/$file $HOME/$file
  	if [ $? -ne 0 ] ; then
		hand echo error "create link failed!"
		mv  $myhome/ $HOME/$file   #restore
     	ls -al ~/$file
		return
	fi

	echo "link success!"
	ls -al ~/$file

}


# hand_myhome "$@"