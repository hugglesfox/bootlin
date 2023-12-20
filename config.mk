BOARD := qemu

CFLAGS := -march=x86-64 -Os --sysroot=$(SYSROOT) -Wl,-rpath-link,$(SYSROOT)/usr/lib -Wl,-rpath-link,$(SYSROOT)/usr/lib64
MAKEFLAGS := -j10

PCIUTILS_VER    = 3.9.0
AIO_VER         = 0.3.113
BUSYBOX_VER     = 1.36.1
COREBOOT_VER    = 4.21
CRYPTSETUP_VER  = 2.6.1
FLASHROM_VER    = 1.3.0
JSON_C_VER      = 0.17
KEXEC_TOOLS_VER = 2.0.27
LINUX_VER       = 6.6.1
LVM_VER         = 2.03.22
MUSL_VER        = 1.2.4
POPT_VER        = 1.19
UTIL_LINUX_VER  = 2.39