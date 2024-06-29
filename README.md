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

Other:
- `misc` is the place to hold non-software parts, like the official documents, 3d-models, non-official mods, etc.

## Issues

- ~~I cannot get my orangepi zero 2w boot with latest mainline u-boot. It's probably a kernel issue and it's still under investigation.~~
    - ~~BTW I don't know why the community image is not working as well.~~
    - It looks like a u-boot issue.
    - linux 6.6.31 works great with armbian patches, but later versions are not
        - on 6.6.35, uwe5622 driver will halt the system
    - I have to replicate armbian's work in a different way.

## Credits

- [Armbian](https://www.armbian.com/) for their work on kernel maintainence.
- [linux-sunxi community](https://linux-sunxi.org/) for all generous contributions from everyone which make the platform better.
