#!/bin/bash

METADATA_URL_BASE="http://169.254.169.254/2012-01-12"
 
# Configure Raid - take into account xvdb or sdb
root_drive=`df -h | grep -v grep | awk 'NR==2{print $1}'`
 
if [ "$root_drive" == "/dev/xvda1" ]; then
  echo "Detected 'xvd' drive naming scheme (root: $root_drive)"
  DRIVE_SCHEME='xvd'
else
  echo "Detected 'sd' drive naming scheme (root: $root_drive)"
  DRIVE_SCHEME='sd'
fi

reserved=0
 
# figure out how many ephemerals we have by querying the metadata API, and then:
#  - convert the drive name returned from the API to the hosts DRIVE_SCHEME, if necessary
#  - verify a matching device is available in /dev/
raid_drives=()
reserved_drives=()
ephemeral_drives=()

ephemeral_count=0
ephemerals=$(curl --silent $METADATA_URL_BASE/meta-data/block-device-mapping/ | grep ephemeral)
for e in $ephemerals; do
  echo "Probing $e .."
  device_name=$(curl --silent $METADATA_URL_BASE/meta-data/block-device-mapping/$e)
  # might have to convert 'sdb' -> 'xvdb'
  device_name=$(echo $device_name | sed "s/sd/$DRIVE_SCHEME/")
  device_path="/dev/$device_name"
 
  # test that the device actually exists since you can request more ephemeral drives than are available
  # for an instance type and the meta-data API will happily tell you it exists when it really does not.
  if [ -b $device_path ]; then
    echo "Detected ephemeral disk: $device_path"
    if [ $ephemeral_count -ge $reserved ]; then
      raid_drives+=($device_path)
    else 
      reserved_drives+=($device_path)
    fi
    ephemeral_drives+=($device_path)
    ephemeral_count=$((ephemeral_count + 1 ))
  else
    echo "Ephemeral disk $e, $device_path is not present. skipping"
  fi
done


# 1 = device, 2 = mountpoint
function format_and_mount() {
	echo "Format/Mount $1 to $2";
}
 
# 1 = list to raid, 2 = list to manage single
function remake_volumes() {
}

case "$ephemeral_count" in
  0)
	echo "No ephemeral disk detected. No action taken."
        ;;
  1)
	echo "Single ephemeral disk detected. No action taken."
	#exit 0
        ;;
  2)
	echo "Two ephemeral disks detected."
	if [ ${reserved} != 0 ]; then
		format_and_mount(${ephemeral_drives[1]}, "/mnt/reserved")
		# Format/mount the 2nd ephemeral
        else
		remake_volumes("${ephemeral_drives[@]}", "")
		# Unmount 1st ephemeral, make raid
        fi
	#exit 0
        ;;
  *)
	echo "Multiple ephemeral disks detected."
        #exit 1
        ;;
esac

