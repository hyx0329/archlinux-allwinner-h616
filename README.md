# ArchLinux on H616/H618 ARM boards

Now working progress.

Current kernel version 6.6.31.

## What have been done?

For u-boot part:
- Mainline u-boot is used.
- Device tree for MangoPi MQ Quad is added.
- It implments a simple straight way to build the u-boot with reproducibility.

For linux part:
- Mainline linux is used.
- It takes patches from Armbian project, and consolidates them to an ArchLinux kernel package.

For os image:
- It implments tools to build a full minimal ArchLinux os image.
- Linux and some utilities are packaged as ArchLinux packages.

Other:
- `misc` is the place to hold non-software parts, like the official documents, 3d-models, non-official mods, etc.

## Issues

- uwe5622 driver
    - it must be loaded after cpufreq_dt(or any module provides cpufreq access)
    - it may cause system soft lock

## Credits

- [Armbian](https://www.armbian.com/) for their work on kernel maintainence.
- [linux-sunxi community](https://linux-sunxi.org/) for all generous contributions from everyone which make the platform better.
