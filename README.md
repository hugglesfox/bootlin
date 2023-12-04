# BootLin

A CoreBoot distribution designed to give a simple Linux boot environment.

- Supports booting any multiboot image using kexec (linux, bsd, etc)
- Allows for full disk encryption (including /boot)
- Able to download and boot images from the network (untested)

## Why?

There are a number of different types of payloads available for CoreBoot. The
most common of which are SeaBios and Tianocore which provide implementations for
booting from a master boot record or EFI partition respectively. However
CoreBoot is also able to directly boot a Linux kernel, skipping the need for
traditional bootloader. 

Whilst one could use their distribution's kernel, it comes with the downsides of
needing to fit the usually large kernel into the usually small BIOS flash and
not being able to boot anything but what your distribution's kernel and
initramfs is configured to boot (your root partition).

Thus BootLin consists of 3 main components

1. Firmware (CoreBoot)
2. Payload (Linux)
3. User environment (busybox based initramfs)

Coreboot initialises the hardware then executes the custom linux kernel included
in the coreboot image. Linux then sets up the initramfs which is embedded into
the kernel image, providing the usual kernel things such as process management
and device drivers. From there further execution is handed over to the user by
executing the `init.sh` script. Most of the usual posix tools are present in the
initramfs via busybox but flashrom, kexec and cryptsetup are also available for
updating the BIOS flash, further booting images and unlocking encrypted disks.

## Usage

Start with customising the `init.sh` script to your needs. This script is
ran on startup meaning it can be used for things such as automatically mounting
disks to be booted.

Next compile the BIOS image using make, setting the BOARD variable to the
configuration to be used for your main board (see the `config` directory for a
list of supported boards)

```sh
$ make BOARD=qemu
```

This should've created `coreboot.rom` which can then be written to your BIOS
flash using tools such as `flashrom`.

## Contributing

Bootlin is licence under the MIT licence. All contributions are welcome.