
# 'hand work'
# 用于改变handybox环境中属性(hand prop)配置
# 必须配合 hand prop 使用

## Used Variables:
# hand_work__name ---  current workspace name

## Usage
# hand work --- show workspaces
# hand work [name]  --- switch to [name] workspace
# hand work --temp [name]   ---lightly switch to [name] workspace
function hand_work()
{
	#no param
	if [ $# -eq 0 ]; then
		# only show current work
    	hand_work__show
    	return
	fi

	# work --temp [name], or work [name]
	if [ "$1" = "--temp" ] ; then
		shift
		hand_work__temp_on "$1"
	else
		hand_work__on "$1"
	fi

	# show them all
	hand_work__show
}

# lightly work on a workspace(only set a shell variable)
function hand_work__temp_on()
{
	hand_work__name=$1
}

# work on a workspace and write work to file
function hand_work__on()
{
	hand_work__temp_on $1
	
	# write current work name to file
	local current_file="$hand__config_path/current_work"
	echo $1 > $current_file

	# touch prop file
	touch $hand__config_path/${1}.props
		
}


function hand_work__show()
{
	local default_name='default'
	local current_file="$hand__config_path/current_work"

	# get current hand work name
	local work_name=$hand_work__name
	if [ ! "$work_name" ]; then
		echo "\$hand_work__name is empty, read from $current_file"
		work_name=`cat $current_file`
	fi

	if [ ! "$work_name" ]; then
		echo "work file $current_file is empty! so use $default_name as default"
		work_name=$default_name
	fi

	# udpate it
	if [ ! "$hand_work__name" ]; then
		hand_work__temp_on $default_name
		if [ ! -f $hand__config_path/${work_name}.props ]; then
			touch $hand__config_path/${work_name}.props
		fi
	fi
	
	echo "work space:"
	for i in `ls $hand__config_path/*.props`
	do 
		local name=${i##*\/}
		name=${name%.*}

		if [[ ! ${name//_*} ]]; then
			continue
		fi

		if [ "$work_name" = "$name" ]; then
			echo "  *  "$name
		else
			echo "     "$name
		fi
	done
}