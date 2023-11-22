#!/bin/busybox sh

/bin/busybox --install -s

mount -t devtmpfs dev /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys

ip link set lo up
ip link set eth0 up

exec setsid cttyhack sh
