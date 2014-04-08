#!/bin/bash

if [ -e /dev/md0 ]; then
  echo "Detected RAID already setup, exiting"
  exit 0
fi

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

ephemeral_drives=()

ephemerals=$(curl --silent $METADATA_URL_BASE/meta-data/block-device-mapping/ | grep ephemeral)
for e in $ephemerals; do
  echo "Probing $e .."
  device_name=$(curl --silent $METADATA_URL_BASE/meta-data/block-device-mapping/$e)
  device_name=$(echo $device_name | sed "s/sd/$DRIVE_SCHEME/")
  device_path="/dev/$device_name"
 
  if [ -b $device_path ]; then
    echo "Detected ephemeral disk: $device_path"
    ephemeral_drives+=($device_path)
  else
    echo "Ephemeral disk $e, $device_path is not present. skipping"
  fi
done

case "${#ephemeral_drives[@]}" in
  0)
	echo "No ephemeral disk detected. No action taken."
	exit 0
        ;;
  1)
	echo "Single ephemeral disk detected. No action taken."
	exit 0
        ;;
  *)
	echo "Several (2+) ephemeral disks detected, raiding"
        ;;
esac

# ephemeral0 is typically mounted for us already. umount it here
umount /mnt
 
# overwrite first few blocks in case there is a filesystem, otherwise mdadm will prompt for input
for drive in ${ephemeral_drives[@]}; do
  dd if=/dev/zero of=$drive bs=4096 count=1024
done
 
partprobe
mdadm --create --verbose /dev/md0 --level=0 -c256 --raid-devices=${#ephemeral_drives[@]} ${ephemeral_drives[@]}
echo DEVICE ${ephemeral_drives[@]} | tee /etc/mdadm/mdadm.conf
mdadm --detail --scan  | grep -oP '.*(?=\sname=.*)' | tee -a /etc/mdadm/mdadm.conf
blockdev --setra 65536 /dev/md0
mkfs -t ext4 /dev/md0
mount -t ext4 -o noatime /dev/md0 /mnt
echo $((30*1024)) > /proc/sys/dev/raid/speed_limit_min
 
# Remove xvdb/sdb from fstab
sed -i "/${DRIVE_SCHEME}b/d" /etc/fstab
 
# Make raid appear on reboot
echo "/dev/md0 /mnt ext4 noatime 0 0" | tee -a /etc/fstab

update-initramfs -u

