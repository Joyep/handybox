
# 'hand work'
# 用于改变handybox环境中属性(hand prop)配置
# 必须配合 hand prop 使用

## Used Variables:
# hand_work__name ---  current workspace name
# hand_work__current_file --- file stored current workspace name
# hand__config_path --- hand configuration path

## Usage
# hand work --- show workspaces
# hand work [name]  --- switch to [name] workspace
# hand work --on [name]   ---lightly switch to [name] workspace
function hand_work()
{

	hand_work__current_file="$hand__config_path/current_work"

	#no param
	if [ $# -eq 0 ]; then
		# only show current work
    	hand_work__show
    	return
	fi

	# work --on [name], or work [name]
	if [ "$1" == "--on" ] ; then
		shift
		hand_work__on "$1"
	else
		hand_work__set "$1"
	fi

	# show them all
	hand_work__show
}

# lightly work on a workspace
function hand_work__on()
{
	hand_work__name=$1
}

# work on a workspace and write work to file
function hand_work__set()
{
	hand_work__on $1

	# write current work name to file
	echo $1 > $hand_work__current_file

	# touch prop file
	touch $hand__config_path/${1}.props
		
}


function hand_work__show()
{

	# get current hand work name
	local work_name=$hand_work__name
	if [ ! "$work_name" ]; then
		echo "\$hand_work__name is empty, read from $hand_work__current_file"
		work_name=`cat $hand_work__current_file`
	fi

	if [ ! "$work_name" ]; then
		echo "work file $hand_work__current_file is empty! so use default"
		work_name="default"
	fi

	# udpate it
	if [ ! "$hand_work__name" ]; then
		hand_work__on default
		if [ ! -f $hand__config_path/${work_name}.props ]; then
			touch $hand__config_path/${work_name}.props
		fi
	fi
	
	echo "work space:"
	for i in `ls $hand__config_path/*.props`
	do 
		local name=${i##*\/}
		name=${name%.*}

		if [ "$work_name" == "$name" ]; then
			echo "  *  "$name
		else
			echo "     "$name
		fi
	done
}