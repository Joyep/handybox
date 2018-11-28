#!/bin/bash
echo "Installing Handybox handy to /usr/bin/"
#export HAND_PATH=`pwd`
#source $HAND_PATH/hand.sh
dest=/usr/bin
hand_path=`pwd`
#hand_path=${hand_path//\//\\\/}
echo $hand_path

sudo cp handy $dest/
sudo sed -i 's/example_path/'${hand_path//\//\\\/}'/g' $dest/handy
sudo chmod a+x $dest/handy

echo "Success!"
