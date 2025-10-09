# ArchLinux on H616/H618 ARM boards

Now seems working fine, thanks to various developers.

Current kernel version 6.12.21.

This repo currently supports following boards:

- MangoPi MQ Quad
- OrangePi Zero 2W

## How to use the content

### Option 1: Use image builder and build the OS image(recommended)

- go to `image-builder` folder
- follow the instructions in `image-builder/README.md`
- flash the generated image to your SD card device
- resize rootfs partition to utilize all space on card

### Option 2: Pick only prebuilt files

- Minimum
    - Install u-boot binary manually
    - Install prebuilt kernel package using pacman
    - Write proper u-boot boot script, refer `distro-scripts/boot.cmd`
- With wireless access
    - Install firmware files to correct locations
        - see board specific configs for details
    - Load correct driver modules(`sprdwl_ng` for uwe5622's wifi)
        - For uwe5622, `hciattach-opi` is required to utilize bluetooth

## What have been done?

For u-boot part:
- Mainline u-boot is used.
- Device tree for MangoPi MQ Quad is added.
- It implments a simple straight way to build the u-boot with reproducibility.

For linux part:
- Mainline linux is used.
- It takes patches from Armbian project(copied directly, but packed in a tar ball for convenience), and consolidates them to an ArchLinux kernel package.

For os image:
- It implments tools to build a full minimal ArchLinux os image.
- Linux and some utilities are packaged as ArchLinux packages.

Other:
- `misc` is the place to hold non-software parts, like the official documents, 3d-models, non-official mods, etc.

## Issues

- uwe5622 driver
    - will not be automatic loaded. write the config in `modules-load.d` or `modprobe.d`
    - it must be loaded after cpufreq_dt(or any module provides cpufreq access)
    - it may cause system soft lock
- u-boot(or boot script)
    - cannot boot initramfs directly, must use an initrd.
- H616
    - 6.12 kernel is known causing H616(not H618) halt but the reason is unknown

## Credits

- [Armbian](https://www.armbian.com/) for their work on kernel maintainence.
- [linux-sunxi community](https://linux-sunxi.org/) for all generous contributions from everyone which make the platform better.
