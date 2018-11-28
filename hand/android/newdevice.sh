

#newdevice $old_name $new_name
hand_android_newdevice()
{
	local old=$1
	local new=$2

	local OLD=$1
	local NEW=$2

	local files=`findname "*.mk"; findname "*.sh";  findname "*.h"; findname "*.txt"`

	#replace $old $new
	sed -i 's/'$old'/'$new'/g'  $files
	sed -i 's/'$OLD'/'$NEW'/g'  $files

	#rename
	#???

	echo "OK!"

	echo "old--------------"
	ack $old
	ack $OLD

	echo "new--------------"
	ack $new
	ack $NEW
}