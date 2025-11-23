# Build u-boot for H616/H618

- u-boot version v2025.04(`34820924edbc4ec7803eb89d9852f4b870fa760a`)
- atf/TF-A version `lts-v2.10.4`
    - It's recommended to use ATF `lts-v2.12.8`. NixOS doesn't yet support GCC 15 cross toolchain for it.
- Read `Makefile` for configurable options. eg.:
    - `ATF_TAG` to override ATF source tag/commit
    - `U_BOOT_DEFCONFIG` to override which defconfig to use

Use the nix-shell environment for full reproducibility. Alternatively, export a fixed `SOURCE_DATE_EPOCH` and use a fixed toolchain.

## Build steps

- install the dependencies or use nix-shell
- run `make build-u-boot`, by default it build image for OrangePi Zero 2W
    - for MangoPi MQ Quad, run `make U_BOOT_DEFCONFIG=mangopi_mq_quad_defconfig build-u-boot`
        - please override ATF to `lts-v2.12.8` and use GCC 15, for stability
    - for OrangePi Zero 2W, run `make U_BOOT_DEFCONFIG=orangepi_zero2w_defconfig build-u-boot`
    - for other boards in mainline u-boot, set `U_BOOT_DEFCONFIG` to corresponding defconfig name
- do either of the following to test the binary
    - flash `u-boot/u-boot-sunxi-with-spl.bin` to SD card at 8KiB.
        `dd if=u-boot/u-boot-sunxi-with-spl.bin of=/dev/card_block_device bs=8K seek=1`
    - transfer the binary using sunxi-fel
        - `sunxi-fel uboot u-boot/u-boot-sunxi-with-spl.bin`
        - sunxi-tools may need a rebuild(even on ArchLinux) to work with latest libusb on the system, or errors like `usb_bulk_send() ERROR -7: Operation timed out` may occur.

*You must know what to do next, right? <3*

- The u-boot location overlaps with standard size GPT partition table. Either use MBR or shrink GPT entry count to 56 or smaller.

## Requirements

Same with u-boot & TF-A requirements.

TODO: determine the package list required.

## u-boot modifications

- for all builds
    `BOOTDELAY` is set to 0
- for MangoPi MQ Quad
    - device tree for MQ Quad created, which is based on orange pi zero2's and zero3's dts.
        - power structure description matches the actual hardware
    - build config created, based on the one for orange pi zero2
        - use AXP313 driver instead
            - set DCDC3 to 1350mV(DDR3L)
        - remove the interrupt pin for pmu, after all there's none

