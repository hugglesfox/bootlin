#!/bin/busybox sh

/bin/busybox --install -s

mount -t devtmpfs dev /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys

exec setsid cttyhack sh
