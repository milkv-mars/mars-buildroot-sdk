#!/bin/sh

VID="0x1209"
PID="0x0010"

mass_storage_create()
{
	mkdir -p $1
	cd $1
	dd if=/dev/zero of=$2.img bs=1M count=$3
	mkdosfs -F 32 $2.img
	mkdir -p /mnt/$2
	mount -t vfat -o sync $2.img /mnt/$2
}

mass_storage_delete()
{
	echo "" > /sys/kernel/config/usb_gadget/mass_storage/functions/mass_storage.0/lun.0/file
	umount /mnt/$2
	rm -rf $1/$2.img
}

mass_storage_start()
{
	umount /mnt/$2
	cd /sys/kernel/config/usb_gadget
	mkdir -p mass_storage
	cd mass_storage
	echo 0x0300 > bcdUSB
	echo $VID  > idVendor
	echo $PID > idProduct
	mkdir -p strings/0x409
	echo "01234567" > strings/0x409/serialnumber
	echo "starfive"  > strings/0x409/manufacturer
	echo "udisk"  > strings/0x409/product
	mkdir -p configs/config.1
	echo 120 > configs/config.1/MaxPower
	mkdir -p configs/config.1/strings/0x409
	echo "mass_storage" >  configs/config.1/strings/0x409/configuration
	sleep 1
	mkdir -p functions/mass_storage.0
	echo "$1/$2.img" > functions/mass_storage.0/lun.0/file
	echo 1 > functions/mass_storage.0/lun.0/removable
	echo 0 > functions/mass_storage.0/lun.0/nofua
	ln -s functions/mass_storage.0 configs/config.1
	sleep 1
	echo `ls /sys/class/udc` > UDC
}

mass_storage_stop()
{
	cd /sys/kernel/config/usb_gadget/mass_storage
	echo "" > UDC
	echo "" > functions/mass_storage.0/lun.0/file
	rm -rf configs/config.1/mass_storage.0
	echo "" > configs/config.1/strings/0x409/configuration
	mount -t vfat -o sync $1/$2.img /mnt/$2
}

mass_storage_process()
{
	case "$1" in
		start)
			mass_storage_start $2 $3
		;;
		stop)
			mass_storage_stop $2 $3
		;;
		create)
			mass_storage_create $2 $3 $4
		;;
		delete)
			mass_storage_delete $2 $3
	;;
	esac
}

adb_start()
{
	cd /sys/kernel/config/usb_gadget
	mkdir -p adb
	cd adb
	echo 0x0300  > bcdUSB
	echo $VID  > idVendor
	echo $PID > idProduct
	mkdir -p strings/0x409
	echo "76543210" > strings/0x409/serialnumber
	echo "starfive"  > strings/0x409/manufacturer
	echo "adb_device"  > strings/0x409/product
	mkdir -p configs/config.1
	echo 120 > configs/config.1/MaxPower
	mkdir -p configs/config.1/strings/0x409
	echo "adb" >   configs/config.1/strings/0x409/configuration
	sleep 1
	mkdir functions/ffs.adb
	ln -s functions/ffs.adb configs/config.1
	mkdir -p /dev/usb-ffs/adb
	mount -o uid=2000,gid=2000 -t functionfs adb /dev/usb-ffs/adb
	adbd &
	sleep 1
	echo `ls /sys/class/udc` > UDC
}

adb_stop()
{
	echo "" > /sys/kernel/config/usb_gadget/adb/UDC
	killall adbd
	sleep 1
	umount adb
	cd /sys/kernel/config/usb_gadget/adb
	rm -rf configs/config.1/ffs.adb
	rm -rf functions/ffs.adb/
	echo "" > configs/config.1/strings/0x409/configuration
}


adb_process()
{
	case "$1" in
		start)
			adb_start
		;;
		stop)
			adb_stop
		;;
	esac
}

CONFIGFS=`mount | grep configfs`
if [ "$CONFIGFS" == "" ]
then
	mount -t configfs none /sys/kernel/config/
fi

case "$1" in
	adb)
		adb_process $2
	;;
	mass_storage)
		mass_storage_process $2 $3 $4 $5
	;;
	*)
	echo "Usage: $0 {adb} {start/stop}"
	echo "Usage: $0 {mass_storage} {create} {path} {imagename} {size/[Mi]}"
	echo "Usage: $0 {mass_storage} {delete/start/stop} {path} {imagename}"
	exit 1
esac

