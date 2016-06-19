#!/bin/bash

function mylog {
    logger -s -t buri -p syslog.info "$1"
}

configured_file=/var/local/buri_ephemeral
if [ -e $configured_file ]; then
    mylog "Buri devices already configured. Exiting"
    exit 0
fi

metadata_url_base="http://169.254.169.254/2015-10-20"

drive_scheme='xvd'

# drive detection and counting

ephemeral_devices=""
ebs_devices=""
ephemeral_count=0
ebs_count=0

mylog "Fetching block device mapping..."

block_devices=$(curl --silent $metadata_url_base/meta-data/block-device-mapping/)

ephemerals=$(echo "$block_devices" | grep ephemeral)
ebses=$(echo "$block_devices" | grep ebs)

for e in $ephemerals; do
    mylog "Probing $e..."
    device_name=$(curl --silent $metadata_url_base/meta-data/block-device-mapping/$e)
    device_name=$(echo $device_name | sed "s/sd/$drive_scheme/")
    device_path="/dev/$device_name"
    if [ -b $device_path ]; then
        ephemeral_devices="$ephemeral_devices $device_path"
        ((ephemeral_count++))
    fi
done

for e in $ebses; do
    mylog "Probing $e ..."
    device_name=$(curl --silent $metadata_url_base/meta-data/block-device-mapping/$e)
    device_name=$(echo $device_name | sed "s/sd/$drive_scheme/")
    device_path="/dev/$device_name"
    if [ -b $device_path ]; then
        ebs_devices="$ebs_devices $device_path"
        ((ebs_count++))
    fi
done

read -r -a ephemeral_array <<< $ephemeral_devices
read -r -a ephemeral_array_unused <<< $ephemeral_devices
read -r -a ebs_array <<< $ebs_devices
read -r -a ebs_array_unused <<< $ebs_devices

# three cases:
# * we have both ephemeral and ebs, use combined map file.
# * we have only ephemeral, use the ephemeral file
# * we have only ebs, use the ebs file
#
# device map files have the following fields:
# device_count mount_point raid_level devices symlinks
#
# device_count - takes the format of ephemeral# or ebs#.
#              - is the count of the drives of that type.
#              -  may be * for any count not listed
# mount_point  - the mount point where a single drive or raid will be mounted
# raid_level   - if more than one drive, the raid level. no sanity check.
#              - if only one drive, no raid
# devices      - the devices to be raided, e.g. 0,1,2 . Starting from 0.
#              - use * for any remaining devices. * must be in the last line for the device type
# symlinks     - the symlinks to create, colon and comma separated /symlink=/mntpt:user:group
#
# ephemeral example:
# ephemeral1 /mnt1 0 0 /cass/commitlog=/mnt1/commitlog:jetty:jetty,/cass/data=/mnt1/data:jetty:jetty,/cass/saved_caches=/mnt1/saved_caches:jetty:jetty
# ephemeral2 /mnt1 0 0 /cass/commitlog=/mnt1/commitlog:jetty:jetty
# ephemeral2 /mnt2 0 1 /cass/data=/mnt2/data:jetty:jetty,/cass/saved_caches=/mnt2/saved_caches:jetty:jetty
# ephemeral* /mnt1 0 0 /cass/commitlog=/mnt1/commitlog:jetty:jetty
# ephemeral* /mnt2 0 * /cass/data=/mnt2/data:jetty:jetty,/cass/saved_caches=/mnt2/saved_caches:jetty:jetty
#
# ebs example:
# ebs1 /mnt 0 0 /cass/commitlog=/mnt/commitlog:jetty:jetty,/cass/data=/mnt/data:jetty:jetty,/cass/saved_caches=/mnt/saved_caches:jetty:jetty
# ebs2 /mnt 0 0 /cass/commitlog=/mnt/commitlog:jetty:jetty
# ebs2 /mnt2 0 1 /cass/data=/mnt2/data:jetty:jetty,/cass/saved_caches=/mnt2/saved_caches:jetty:jetty
# ebs* /mnt 0 0 /cass/commitlog=/mnt/commitlog:jetty:jetty
# ebs* /mnt2 0 * /cass/data=/mnt2/data:jetty:jetty,/cass/saved_caches=/mnt2/saved_caches:jetty:jetty
#
# both example:
# ephemeral* /mnt1 0 * /cass/commitlog=/mnt1/commitlog:jetty:jetty
# ebs* /mnt2 0 * /cass/data=/mnt2/data:jetty:jetty,/cass/saved_caches=/mnt2/saved_caches:jetty:jetty

if [ $ephemeral_count -gt 0 ] && [ $ebs_count -gt 0 ] ; then
    device_map=/etc/buri-device-map-both
elif [ $ephemeral_count -gt 0 ] ; then
    device_map=/etc/buri-device-map-ephemeral
elif [ $ebs_count -gt 0 ] ; then
    device_map=/etc/buri-device-map-ebs
else
    device_map='/dev/null'
fi

# if the path isn't a file, we're done
if [ ! -f $device_map ] ; then
    logger -s "No buri device map file found. Exiting."
    touch $configured_file
    exit 0;
fi

function make_filesystem {
    fs_device_path=$1
    fs_mount_point=$2
    mylog "Formatting $fs_device_path"
    mkfs -t xfs -f ${fs_device_path}
    echo "${fs_device_path} $fs_mount_point xfs defaults 0 0" >> /etc/fstab
    mylog "Mounting $fs_device_path"
    mount $fs_mount_point
}

function make_raid {
    mr_device_path=$1
    mr_raid_level=$2
    mr_device_count=$3
    mr_raid_devices=$4

    mylog "Making RAID $mr_device_path level $mr_raid_level with devices $mr_raid_devices"
    yes | mdadm --create --force $mr_device_path --level=$mr_raid_level --raid-devices=$mr_device_count $mr_raid_devices
    echo DEVICE $mr_raid_devices | tee -a /etc/mdadm/mdadm.conf
}

# for each symbolic link, make the target directory and link it
function make_symlinks {
    ms_symlinks=$1

    mylog "Making directories, setting ownership, and linking: $ms_symlinks"
    IFS="," read -r -a ms_symlink_array <<< $ms_symlinks
    for symlink_triplet in ${ms_symlink_array[@]} ; do
        while IFS=":" read -r ms_symlink ms_user ms_group ; do
            IFS="=" read -r ms_src ms_target <<< $ms_symlink
            mkdir -p $ms_target $(dirname $ms_src)
            ln -s $ms_target $ms_src
            chown $ms_user:$ms_group $ms_target
            chmod 0770 $ms_target
        done <<< $symlink_triplet
    done

    echo
}

function configure_disks {
    cd_device_array_name=$1
    cd_device_array_unused_name=$2
    cd_lines=$3

    while read -r cd_line; do

        read -r cd_dummy cd_mount_point cd_raid_level cd_use_devices cd_symlinks <<< $cd_line
        mkdir -p $cd_mount_point

        if [ "$cd_use_devices" == "*" ] ; then
            # rewrite to use all the unused drives
            cd_use_devices=$(eval echo \${!$cd_device_array_unused_name[*]} | tr ' ' ,)
        fi

        # count the number of device used
        IFS="," read -r -a cd_use_devices_array <<< $cd_use_devices
        cd_use_devices_count=${#cd_use_devices_array[@]}

        if [ $cd_use_devices_count -gt 1 ] ; then

            ((raid_count++))

            # make a list of raid devices
            cd_raid_devices=""
            for cd_device_index in ${cd_use_devices_array[@]} ; do

                eval cd_new_raid_device=\${$cd_device_array_name[$cd_device_index]}
                cd_raid_devices="$cd_raid_devices $cd_new_raid_device"
                eval $cd_device_array_unused_name[\$cd_device_index]=''

            done

            cd_device_path=/dev/md$raid_count
            make_raid $cd_device_path $cd_raid_level $cd_use_devices_count "$cd_raid_devices"
            make_filesystem $cd_device_path $cd_mount_point

        elif [ $cd_use_devices_count = 1 ] ; then
            cd_device_index=${cd_use_devices_array[0]}
            eval cd_device_path=\${$cd_device_array_name[$cd_device_index]}
            make_filesystem $cd_device_path $cd_mount_point

            eval $cd_device_array_unused_name[\$cd_device_index]=''

        fi

        make_symlinks $cd_symlinks

    done <<< "$cd_lines"
}

function find_relevant_lines {
    frl_device_type=$2
    frl_device_count=$3
    frl_device_map=$4

    frl_found_lines=$(grep $frl_device_type$frl_device_count $frl_device_map)

    if [ "x$frl_found_lines" = "x" ]; then
        frl_found_lines=$(grep ${frl_device_type}* $frl_device_map)
    fi

    eval "$1='$frl_found_lines'"
}

# first undo the default ubuntu mount and reload the partition table
# we may need to set up the disk differently
if [ $ephemeral_count -gt 0 ] ; then
    mylog "Removing default Ubuntu mounted /mnt"
    umount /mnt || true
    read -r first_ephemeral dummy <<< $ephemeral_devices
    sed -i "#$first_ephemeral#d" /etc/fstab
    # and zero the beginning of the drive so mdadm et al don't complain
    dd if=/dev/zero of=${first_ephemeral} bs=1M count=2
fi

raid_count=0
mylog "Truncating /etc/mdadm/mdadm.conf"
truncate --size 0 /etc/mdadm/mdadm.conf

if [ $ephemeral_count -gt 0 ] ; then
    relevant_ephemeral=''
    find_relevant_lines relevant_ephemeral ephemeral $ephemeral_count $device_map
    configure_disks ephemeral_array ephemeral_array_unused "$relevant_ephemeral"
fi

if [ $ebs_count -gt 0 ] ; then
    relevant_ebs=''
    find_relevant_lines relevant_ebs ebs $ebs_count $device_map
    configure_disks ebs_array ebs_array_unused "$relevant_ebs"
fi

# if we have raid, need to update mdadm.conf and rebuild the kernel image
if [ $raid_count -gt 0 ] ; then
    mylog "Updating /etc/mdadm/mdadm.conf"
    mdadm --detail --scan | tee -a /etc/mdadm/mdadm.conf
    mylog "Updating initramfs"
    update-initramfs -u
fi

touch $configured_file

mylog "Buri disk configuration complete."

