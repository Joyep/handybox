#!/bin/bash

#export hand__path=`pwd`
#source $hand__path/hand.sh
#dest=/usr/bin
dest=$HOME/bin/hand
src=hand_bin
# dest=/usr/bin/handy
hand_path=`pwd`
#hand_path=${hand_path//\//\\\/}
# echo $hand_path

echo "Installing Handybox command 'hand' to $dest ..."

cp $src $dest
if [ $(uname) == "Darwin" ]; then
	SED_CMD="gsed"
else
	SED_CMD="sed"
fi

$SED_CMD -i 's/example_path/'${hand_path//\//\\\/}'/g' $dest

chmod a+x $dest


echo "Done!"
echo 
