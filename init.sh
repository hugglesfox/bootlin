#!/bin/busybox sh

# Setup the busybox applet symlinks
/bin/busybox --install -s

# Mount kernel provided filesystems
mount -t devtmpfs dev /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys

# Insert your initialisation code here.
#
# The following is an example of
#  - enabling networking
#  - decrypting and mounting a root partition
#  - configuring kexec to use the kernel and initramfs on the mounted partition

ip link set lo up
ip link set eth0 up

cryptsetup open /dev/sda1 root
mount /dev/mapper/root /mnt

kexec -l /mnt/vmlinuz --initrd /mnt/initrd.img --append="root=/dev/mapper/root resume=/dev/mapper/root resume_offset=2065633"

# Finally execute a shell
exec setsid cttyhack sh
