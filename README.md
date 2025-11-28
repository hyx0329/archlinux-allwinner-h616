# ArchLinux on H616/H618 ARM boards

Now seems working fine, thanks to various developers.

Current kernel version 6.12.23.

The prebuilts currently include artifacts for following boards:

- MangoPi MQ Quad
- OrangePi Zero 2W
- OrangePi Zero 3

You can always build your own by tweaking the configs.
Each board needs its specific u-boot, while the kernel is mostly compatible.

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

### Option 3: Build everything from scratch

- For u-boot, read `u-boot/README.md`
- For kernel package, see `PKGBUILDs/linux-sunxi64-armbian`
    - native build time on a MQ Quad(`-j4`):
        - real    712m58.118s
        - user    2398m8.220s
        - sys     267m37.190s
- Then you can utilize the image-builder and craft an OS image using your binaries

## What have been done?

For u-boot part:
- Mainline u-boot is used, with patches from Armbian.
- Device tree and build config for MangoPi MQ Quad are added.
- It implments a simple straight way to build the u-boot with reproducibility.

For linux part:
- Mainline linux is used.
- It takes patches from Armbian project.
- Everything is packaged to a pacman package.

For os image:
- It implments tools to build a usable minimal ArchLinux os image.
- Users are expected to customize the OS for their needs.

Other:
- `misc` is the place to hold non-software parts, like the official documents, 3d-models, non-official mods, etc.

## Issues

- uwe5622 driver
    - will not be automatic loaded. write the config in `modules-load.d` or `modprobe.d`
    - it must be loaded after cpufreq_dt(or any module provides cpufreq access)
    - it may cause system soft lock
- u-boot(or boot script)
    - cannot boot initramfs directly, must use an initrd.
- Kernel
    - There may be some stability issue. In case of system halt, utilizing hardware watchdog is recommended to avoid manually resetting the device.

## Credits

- [Armbian](https://www.armbian.com/) for their work on kernel maintainence.
- [linux-sunxi community](https://linux-sunxi.org/) for all generous contributions from everyone which make the platform better.
