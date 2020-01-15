#!/bin/bash


##
##
##
function print_usage {
    echo "Usage: $0 cmd [options]"
	echo "  cmd: "
	echo "    create [image file]: "
	echo "		[image file]: raspbian OS image zip/img file"
	echo "    cmd [command]:"
	echo "		[command]: should be escaped with double-quote and "
	echo "		  command need to be full path of command "
	echo "		  e.g. sudo ./build_rootfs.sh cmd \"/usr/bin/apt autoremove\""
	echo "    clean : removing rootfs"
}

# Global variables for this script
RPI_ROOTFS_BASE=./rootfs
IMAGEFILE_MOUNT_PATH=/mnt
IMAGE_MOUNTED=0
CHROOT_SYS_PATH_MOUNTED=0
QEMU_ARM_STATIC=/usr/bin/qemu-arm-static
RSYNC_OPTIONS="-hatr --delete --stats"
UPDATE_INSTALL_SCRIPT=update_upgrade_install_package.sh
CURRENT_WORKING_DIR=""

###############################################################################
# 
#  Helper Functions
# 
###############################################################################

function cleanUp {
	if [ ${IMAGE_MOUNTED} == 1 ]; then 
		# umount before terminating this script
		echo "Unmounting ${IMAGEFILE_MOUNT_PATH}"
		umount ${IMAGEFILE_MOUNT_PATH}
		# clear flag
		IMAGE_MOUNTED=0
	fi
	if [ ${CHROOT_SYS_PATH_MOUNTED} == 1 ]; then 
		umount ${RPI_ROOTFS_BASE}/sys
		umount ${RPI_ROOTFS_BASE}/proc
		umount ${RPI_ROOTFS_BASE}/dev/pts
		umount ${RPI_ROOTFS_BASE}/dev
		# clear flag
		CHROOT_SYS_PATH_MOUNTED=0
	fi
}

## 
function is_command_installed {
	local checking_command=$1
	if ! [ -x "$(command -v ${checking_command})" ]; then
  		echo "Error: ${checking_command} command is not installed "
		echo "or could not found the command in PATH variable."
  		exit 1
	fi
}

## 
function extract_zip_and_mount_image {
	local image_filename=$1
	local filename=$(basename -- "$image_filename")
	local extension="${filename##*.}"
	local filename_without_ext=$(echo "$filename" | cut -f 1 -d '.')
	local extracted_image_filename=${filename_without_ext}.img

	## Extracting Raspbian OS image from zip file
	if [ ${extension} == "zip" ]; then 
		unzip ${image_filename}
		ret_value=$?
		echo "Unzip Resutnr value : ${ret_value}"
		if [ ${ret_value} -ne 0 ]; then 
			echo "Error: Failed to execute unzip ${image_filename}"
			exit 1;
		fi
	elif [ ${extension} != "img" ]; then 
		echo "Error: unsuppored Raspbian OS image type ${image_filename}"
		exit 2;
	fi

	## Extracting the mount offset of Raspbian OS image
	if [ ! -e ${extracted_image_filename} ]; then
		echo "Raspbian OS raw image file does not exist in zip file"
		exit 1
	fi

	local mount_offset=$(fdisk -l ${extracted_image_filename} | grep "Linux" | awk '{print $2 * 512}')
	 mount -o ro,loop,offset=${mount_offset} -t auto \
		${extracted_image_filename} ${IMAGEFILE_MOUNT_PATH}
	local ret_value=$?
	if [ ${ret_value} -ne 0 ]; then 
		echo "Error: Failed to mount  Raspbian OS image  ${image_filename}"
		exit 3;
	fi

	# mark image mounted global flag
	IMAGE_MOUNTED=1
	return 0
}

function copy_files_from_image {
	(
		cd ${IMAGEFILE_MOUNT_PATH};
		 rsync ${RSYNC_OPTIONS} * ${CURRENT_WORKING_DIR}/${RPI_ROOTFS_BASE} 
	)
	local ret_value=$?
	if [ ${ret_value} -ne 0 ]; then 
		echo "Error: Failed to copy from Raspbian OS image"
		exit 4;
	fi

	# fixing links and hack library paths 
	 ./rpi_rootfs.py local ${RPI_ROOTFS_BASE}
}

function update_and_install_raspbian_os_imsage {
	mkdir -p  ${RPI_ROOTFS_BASE}/root
	cp ./scripts/${UPDATE_INSTALL_SCRIPT} ${RPI_ROOTFS_BASE}/root

	mount --bind /sys ${RPI_ROOTFS_BASE}/sys
	mount --bind /proc ${RPI_ROOTFS_BASE}/proc
	mount --bind /dev ${RPI_ROOTFS_BASE}/dev
	mount --bind /dev/pts ${RPI_ROOTFS_BASE}/dev/pts
	# Setting mounted flag for cleanUp
	CHROOT_SYS_PATH_MOUNTED=1
	chmod 777 ${RPI_ROOTFS_BASE}/tmp
	cp ${QEMU_ARM_STATIC} ${RPI_ROOTFS_BASE}/${QEMU_ARM_STATIC} 

	chroot ${RPI_ROOTFS_BASE} /usr/bin/qemu-arm-static  \
		/bin/bash  /root/${UPDATE_INSTALL_SCRIPT}

	# fixing links and hack library paths again
	./rpi_rootfs.py local ${RPI_ROOTFS_BASE}
}

##
function run_chroot_command {
	local command_string=$1
	mount --bind /sys ${RPI_ROOTFS_BASE}/sys
	mount --bind /proc ${RPI_ROOTFS_BASE}/proc
	mount --bind /dev ${RPI_ROOTFS_BASE}/dev
	mount --bind /dev/pts ${RPI_ROOTFS_BASE}/dev/pts
	# Setting mounted flag for cleanUp
	CHROOT_SYS_PATH_MOUNTED=1

	echo "CMD: ${command_string}"
	chroot ${RPI_ROOTFS_BASE} /usr/bin/qemu-arm-static ${command_string}
}

##
function create_rootfs {
	local image_filename=$1

	echo "Raspbian OS image file name : ${image_filename}"
	if [ ! -e ${image_filename} ]; then 
		echo "Raspbian OS image not found"
		exit 5
	fi

	extract_zip_and_mount_image ${image_filename}
	copy_files_from_image 
	update_and_install_raspbian_os_imsage
}

function is_rootfs_exist {
	if [ -e ${RPI_ROOTFS_BASE} ]; then
		echo "rootfs already exist, remove rootfs if you want to create new one"
		exit 6
	fi
	mkdir ${RPI_ROOTFS_BASE} 
}

function clean_rootfs {
	echo "removing whole rootfs directory"
	rm -fr  ${RPI_ROOTFS_BASE}
}

###############################################################################
# 
#  script main
# 
###############################################################################
if [ "$#" -lt 1 ]; then
	print_usage;
    exit 1
fi
args=("$@")
 
trap cleanUp EXIT
trap cleanUp SIGTERM SIGINT SIGFPE SIGSTOP SIGSYS

is_command_installed unzip
is_command_installed awk
is_command_installed grep
is_command_installed fdisk
is_command_installed rsync
is_command_installed qemu-arm-static	# qemu-user-static package
CURRENT_WORKING_DIR=${PWD}

if [ ${args[0]} == "create" ]; then
	is_rootfs_exist		# exit this script when the rootfs exists
	create_rootfs ${args[1]} 
elif [ ${args[0]} == "clean" ]; then
	clean_rootfs
elif [ ${args[0]} == "cmd" ]; then
	shift 
	run_chroot_command "$@"
else
	echo "command not found : ${args[0]}"
	print_usage
fi

exit 0;

