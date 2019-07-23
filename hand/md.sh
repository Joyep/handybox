

function hand_md()
{
	local sub=$1
	shift
	case $sub in
	"clean_images")
		hand_md__clean_images $*
		;;
	"fix_images")
		hand_md__fix_images $*
		;;

	*)
		hand echo error "$sub unsupported"
		;;
	esac
}


# 删除所有没有引用到的图片
function hand_md__clean_images()
{
	local images=`find . -name "*.png"`

	local mdfiles=`find . -name "*.md"`

	local used_images=`ack  '.png\)' $mdfiles`

	hand time start

	local img
	local img_name
	for img in $images ; do
		# echo $img
		img_name=${img##*/}
		if [[ ! $used_images =~ $img_name ]]; then
			hand echo red " [ Not Used ] "$img
			if [ "$1" == "-y" ]; then
				hand echo green "Deleted!"
				rm $img
			fi
		else
			hand echo green " [ Used ] "$img
		fi
	done

	# for img in $used_images ; do
	# 	echo $img
	# done

	hand time end

	if [ "$1" != "-y" ]; then
		hand echo yellow "add option '-y' to remove unused images"
	fi
}


# handle a markdown file
# $1 file
# $2 -y
function hand_md__handle_mdfile()
{

	local md=$1
	local fix=$2

	echo ">>> " $md

	# imglines=`cat $md | grep "\!\[" | grep png`
	imglines=`ack "\!\[.*.png" $md` 

	for line in $imglines ; do
		# echo imgline=$line

		((all_cnt=all_cnt+1))
		# echo all_cnt=$all_cnt


		# 引用图片的文件路径
		img_path=${line##*\(}
		img_path=${img_path%png*}png
		# echo img_path=$img_path

		# 引用图片的文件名
		img_name=${img_path##*/}

		# 引用图片的目录名
		img_path=${img_path%/*}


		# dir of md file
		md_dir=${md%/*}

		# image file exist?
		if [ ! -f $md_dir/$img_path/$img_name ]; then
			# file not exist
			hand echo warn "$md_dir/$img_path/$img_name not exist!" 

			if [ "$fix" != '-y' ]; then
				continue;
			fi

			local fixed=0
			# find one and copy to here
			for f in `find . -name "$img_name"` ; do
				if [ ! -d $md_dir/$img_path/ ]; then
					mkdir -p $md_dir/$img_path/
				fi
				hand echo do cp $f $md_dir/$img_path/$img_name
				hand echo green "Fixed!" 
				fixed=1
				break
			done

			if [ $fixed -ne 1 ]; then
				hand echo red "[Fix Faield] File ($img_name) Not Found!"
				continue
			fi
		fi

		# image path is right?
		if [ "$img_path"  != "__images" ]; then
			# dir of img file is not right
			hand echo warn "$img_name should placed in __images, but it placed in $img_path! please fix it"

			if [ "$fix" != '-y' ] ; then
				continue;
			fi

			# modify refered image path
			# if [ $(uname) == "Darwin" ]; then
			# 	sed -i "" "s%]($img_path/$img_name)%](__images/${img_name})%" $md
			# else
				sed -i "s%]($img_path/$img_name)%](__images/${img_name})%" $md
			# fi

			if [ $? -ne 0 ]; then
				hand echo red "[Fix Faield] Modify path Failed! ($md: $img_path/$img_name)"
				continue;
			fi

			# move image file
			if [ ! -d $md_dir/__images ]; then
				mkdir $md_dir/__images
			fi
			mv $md_dir/$img_path/$img_name $md_dir/__images/
			if [ $? -ne 0 ]; then
				hand echo red "[Fix Faield] Copy file Failed! (mv $md_dir/$img_path/$img_name $md_dir/__images/)"
				continue;
			fi

			hand echo green "Modify $img_path to $md_dir/__images done!"
		fi

	done

	hand thread up

}


# check images
# 检查所有引用图片的地方, 保证:
# 1. 路径都是当前目录下的 __images/, 如果不是, 则提示用户修改成这样, --fix 强制修改
# 2. 图片文件有效, 如果没有图片, 则全局搜索, 拷贝过来
# 3. 如果图片文件多余, 则提示用户删除, 使用 --clean 可以强制删除
function hand_md__fix_images()
{
	# all markdown files
	local mdfiles=`find . -name "*.md"`

	hand time start

	hand thread init 4

	for md in $mdfiles ; do

		hand thread down

		
		hand_md__handle_mdfile $md $1 &

	done

	hand thread clean

	hand time end

	if [ "$1" != '-y' ] ; then
		hand echo yellow "add option '-y' to fix all images"
	fi
}




# check images
function hand_md__check_images_old()
{

	# img refered but not found
	local img_not_found_cnt=0
	# all img refer item
	local all_cnt=0
	# correct img refer item count
	local correct_cnt=0
	# warn count
	local warn_cnt=0

	# all markdown files
	local mdfiles=`find . -name "*.md"`

	# all img files
	local imgfiles=`ls __images/`
	local usedfiles=""

	for md in $mdfiles ; do
		echo ">>> " $md

		imglines=`cat $md | grep "\!\[" | grep png`

		for line in $imglines ; do
			# echo imgline=$line

			((all_cnt=all_cnt+1))
			# echo all_cnt=$all_cnt


			img_path=${line##*\(}
			img_path=${img_path%png*}png
			# echo img_path=$img_path

			img_name=${img_path##*/}

			# find out which img files are used
			if [[ "$imgfiles" =~ "$img_name" ]]; then
				# remove img_name from imgfiles
				imgfiles=`echo $imgfiles | sed  s/$img_name//`
				hand echo green "[FOUND] $img_name"
				usedfiles="$usedfiles $img_name"
			else 
				if [[ ! "$usedfiles" =~ "$img_name" ]]; then
					hand echo error "$img_name not found!"
					((img_not_found_cnt=img_not_found_cnt+1))
					continue
				fi
			fi

			# md file dir
			md_dir=${md%/*}

			# img path is right?
			if [ -f $md_dir/$img_path ]; then
				hand echo green "[PATH OK] $md_dir/$img_path"
				((right_cnt=right_cnt+1))
				continue
			fi

			# echo md_dir=$md_dir
			img_dir="__images"
			while true; do
				# echo "find img file in  $md_dir/__images/$img_name"
				if [ -f $md_dir/__images/$img_name ]; then
					break;
				fi
				md_dir2=${md_dir%/*}
				if [ "$md_dir2" == "$md_dir" ]; then
					img_dir=""
					break;
				fi
				md_dir=$md_dir2
				img_dir="../"$img_dir
			done


			if [ "$img_dir" == "" ]; then
				hand echo error "img file not found, skip!"
				((img_not_found_cnt=img_not_found_cnt+1))
				continue
			fi

			# replace a right path

			new_img_path="$img_dir"/"$img_name"
			# hand echo green new_img_path=$new_img_path

			if [ "$1" == "--fix" ]; then
				# do replace
				hand echo green "do replace for $md"

				# if [ $(uname) == "Darwin" ]; then
				# 	sed -i "" "s%]($img_path)%]($new_img_path)%" $md
				# else
					sed -i "s%]($img_path)%]($new_img_path)%" $md
				# fi

				((correct_cnt=correct_cnt+1))
			else
				hand echo warn "should fix with $new_img_path for $md"
				((warn_cnt=warn_cnt+1))
				# hand echo warn "use '--fix' to fix refer img path"
			fi

		
			
		done

		# break
	done

	echo ------- not used img files ---------
	echo $imgfiles
	if [ "$1" == "--clean" ]; then
		for img in $imgfiles ; do
			rm __images/$img
		done
		hand echo info "unused img file were removed!"
	else
		hand echo warn "use '--clean' to remove unused img files"
	fi
	echo ----------------------------
	hand echo green "all_cnt=$all_cnt"
	# hand echo green "right_cnt=$right_cnt"
	hand echo green "correct_cnt=$correct_cnt"
	hand echo yellow "warn_cnt=$warn_cnt"
	hand echo red "img_not_found_cnt=$img_not_found_cnt"

	if [ $warn_cnt -gt 0 ]; then
		hand echo warn "use '--fix' to fix refer img path"
	fi

}

# 找到所有对图片引用的md文件, 将图片引用路径改成工程目录下的__images下
function hand_md__fix_image_path()
{
	local error_cnt=0
	local success_cnt=0
	local right_cnt=0
	local all_cnt=0
	local warn_cnt=0

	local mdfiles=`find . -name "*.md"`



	for md in $mdfiles ; do
		echo ">>> " $md

		imglines=`cat $md | grep "\!\[" | grep png`

		for line in $imglines ; do
			# echo imgline=$line

			((all_cnt=all_cnt+1))
			# echo all_cnt=$all_cnt


			img_path=${line##*\(}
			img_path=${img_path%png*}png
			# echo img_path=$img_path

			img_name=${img_path##*/}

			# md file dir
			md_dir=${md%/*}

			# img path is right?
			if [ -f $md_dir/$img_path ]; then
				hand echo green "$md_dir/$img_path ok!"
				((right_cnt=right_cnt+1))
				continue
			fi

			# echo md_dir=$md_dir
			img_dir="__images"
			while true; do
				# echo "find img file in  $md_dir/__images/$img_name"
				if [ -f $md_dir/__images/$img_name ]; then
					break;
				fi
				md_dir2=${md_dir%/*}
				if [ "$md_dir2" == "$md_dir" ]; then
					img_dir=""
					break;
				fi
				md_dir=$md_dir2
				img_dir="../"$img_dir
			done


			if [ "$img_dir" == "" ]; then
				hand echo error "img file not found, skip!"
				((error_cnt=error_cnt+1))
				continue
			fi

			# replace a right path

			new_img_path="$img_dir"/"$img_name"
			# hand echo green new_img_path=$new_img_path

			if [ "$1" == "-y" ]; then
				# do replace
				hand echo green "do replace for $md"
				hand echo do sed -i "s%]($img_path)%]($new_img_path)%" $md
				((success_cnt=success_cnt+1))
			else
				hand echo warn "should replace $new_img_path for $md"
				((warn_cnt=warn_cnt+1))
			fi

		
			
		done

		# break
	done

	echo ----------------------------
	hand echo green "all_cnt=$all_cnt"
	hand echo green "right_cnt=$right_cnt"
	hand echo green "success_cnt=$success_cnt"
	hand echo yellow "warn_cnt=$warn_cnt"
	hand echo red "error_cnt=$error_cnt"

}

# 清理
function hand_md__clean_images2()
{
	local error_cnt=0
	local success_cnt=0
	local used_cnt=0

	local warn_cnt=0
	local all_cnt=0
	local not_use_cnt=0

	local mdfiles=`find . -name "*.md"`

	local imgfiles=`ls __images/`

	for md in $mdfiles ; do
		echo ">>> " $md

		imglines=`cat $md | grep "\!\[" | grep png`

		for line in $imglines ; do
			echo imgline=$line

			((all_cnt=all_cnt+1))
			# echo all_cnt=$all_cnt


			img_path=${line##*\(}
			img_path=${img_path%png*}png
			# echo img_path=$img_path

			img_name=${img_path##*/}

			if [[ "$imgfiles" =~ "$img_name" ]]; then
				# remove img_name from imgfiles
				imgfiles=`echo $imgfiles | sed  s/$img_name//`
				hand echo green "$img_name used!"
				((used_cnt=used_cnt+1))
			fi
			
		done

		# break
	done

	echo ------- not used img files ---------
	echo $imgfiles
	hand echo warn "'-y' to remove"
	echo ----------------------------
	hand echo green "all_cnt=$all_cnt"
	hand echo green "used_cnt=$used_cnt"
	hand echo green "success_cnt=$success_cnt"
	hand echo yellow "not_used_cnt=$not_use_cnt"
	hand echo red "error_cnt=$error_cnt"

}

# hand_md "$@"


