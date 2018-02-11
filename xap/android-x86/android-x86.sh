#!/bin/bash
# By Chih-Wei Huang <cwhuang@linux.org.tw>
# adapted by Gwenhael Le Moine <gwenhael@le-moine.org>
# License: GNU Generic Public License v2

RAM=${RAM:-8192}
RESOLUTION=${RESOLUTION:-"1536x2048"}
ANDROID_DIR=${ANDROID_DIR:-/usr/share/android-x86}
ANDROID_DATA_DIR=${ANDROID_DATA_DIR:-$HOME/.android-x86}

continue_or_stop()
{
    echo "Please Enter to continue or Ctrl-C to stop."
    read
}

QEMU_ARCH=`uname -m`
QEMU="xterm -e qemu-system-${QEMU_ARCH}"

which $QEMU > /dev/null 2>&1 || QEMU=qemu-system-i386
if ! which $QEMU > /dev/null 2>&1; then
    echo -e "Please install $QEMU to run the program.\n"
    exit 1
fi

[ -e $ANDROID_DIR/system.img ] && SYSTEMIMG=$ANDROID_DIR/system.img || SYSTEMIMG=$ANDROID_DIR/system.sfs

if [ -e $ANDROID_DATA_DIR/data.img ]; then
    if [ -w $ANDROID_DATA_DIR/data.img ]; then
        DATA="-drive index=2,if=virtio,id=data,file=$ANDROID_DATA_DIR/data.img"
        DATADEV='DATA=vdc'
    else
        echo -e "\n$(realpath $ANDROID_DATA_DIR/data.img) exists but is not writable.\nPlease grant the write permission if you want to save data to it.\n"
        continue_or_stop
    fi
elif [ -d $ANDROID_DATA_DIR/data ]; then
    if [ `id -u` -eq 0 ]; then
        DATA="-virtfs local,id=data,path=$ANDROID_DATA_DIR/data,security_model=passthrough,mount_tag=data"
        DATADEV='DATA=9p'
    else
        echo -e "\n$(realpath $ANDROID_DATA_DIR/data) subfolder exists.\nIf you want to save data to it, run $0 as root:\n\n$ sudo $0\n"
        continue_or_stop
    fi
fi

NET="-net nic,model=e1000 -net user -netdev user,id=mynet,hostfwd=tcp::5555-:5555 -device virtio-net-pci,netdev=mynet"
DISPLAY="-vga std -display gtk"

run_qemu()
{
    $QEMU -enable-kvm \
          -kernel $ANDROID_DIR/kernel \
          -append "root=/dev/ram0 androidboot.selinux=permissive buildvariant=userdebug console=ttyS0 RAMDISK=vdb video=$RESOLUTION $DATADEV" \
          -initrd $ANDROID_DIR/initrd.img \
          -m $RAM -smp 2 -cpu host \
          -soundhw ac97 \
          -serial mon:stdio \
          -boot menu=on \
          -drive index=0,if=virtio,id=system,file=$SYSTEMIMG,format=raw,readonly \
          -drive index=1,if=virtio,id=ramdisk,file=$ANDROID_DIR/ramdisk.img,format=raw,readonly \
          $DATA \
          $NET \
          $DISPLAY \
          $@
}

run_qemu $@
