# Build u-boot for H616/H618

- u-boot version 2024.07-rc4-00012-g1ebd659cf0
- atf/TF-A version lts-v2.10.4

Use the nix-shell environment for full reproducibility. Alternatively, export a fixed `SOURCE_DATE_EPOCH` and use a fixed toolchain.

## Build steps

- install the dependencies or use nix-shell
- run `make build-u-boot`, by default it build image for OrangePi Zero 2W
    - for MangoPi MQ Quad, run `make U_BOOT_DEFCONFIG=mangopi_mq_quad_defconfig build-u-boot`
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

- for MangoPi MQ Quad
    - device tree for MQ Quad created, which is based on orange pi zero2's and zero3's dts.
        - power structure description matches the actual hardware
    - build config created, based on the one for orange pi zero2
        - use AXP313 driver instead
            - set DCDC3 to 1500mV(DDR3)
        - remove the interrupt pin for pmu, after all there's none
- for all builds
    `BOOTDELAY` is set to 0
