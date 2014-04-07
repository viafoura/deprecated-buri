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
    ephemeral_count=$((ephemeral_count + 1 ))
  else
    echo "Ephemeral disk $e, $device_path is not present. skipping"
  fi
done
 
if [ "$ephemeral_count" = 0 ]; then
  echo "No ephemeral disk detected. exiting"
  exit 0
fi

if [ ${#reserved_drives[@]} -lt $reserved ]; then
  echo "Unable to fulfill requested disk reservations (want: $reserved, have: ${#reserved_drives[@]}). exiting"
  exit 0
fi

if [ ${#raid_drives[@]} = 1 ]; then
  echo "Not creating raid of one. Moving disk to reserved list"
      reserved_drives=("${raid_drives[@]}" "${reserved_drives[@]}")
      raid_drives=()
fi

echo "Total Count: $ephemeral_count"
echo "RAID count : ${#raid_drives[@]}"
echo "RAID drives: ${raid_drives[@]}"
echo "Reserved count : ${#reserved_drives[@]}"
echo "Reserved drives: ${reserved_drives[@]}"


