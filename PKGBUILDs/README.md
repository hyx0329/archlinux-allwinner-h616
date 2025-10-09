# ArchLinux Packages

Here are custom packages to support ArchLinux on H616/H618 boards.

These packages are meant to be built on an arm64 host.

## linux-sunxi64-armbian

Current armbian/build version: 95b8c4cc8c252d4f9dbcbc17611e835550b3fa70

linux-sunxi64-armbian is a kernel package tweaked to support MangoPi MQ Quad and OrangePi Zero 2W.
It can still be used to support other H616/H618 boards though.

The package uses ArchLinux lts kernel(6.6, 6.12) package as a template, and utilizes the patches from armbian build.

This package is cross-compile compatible.
To cross compile it on a powerful x86_64 host, run the following command instead of the plain makepkg:

```bash
makepkg MAKEFLAGS="-j$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CARCH=aarch64
```

*All other linux packages can be cross compiled in the same way as well.*

*header package may fail and it's expected :)*
well the script is updated to make sure the header package will NOT be built when `CROSS_COMPILE` is set. If it's required, build it on your arm device.

## hciattach-opi

This is the necessary glue driver to enable UWE5622's bluetooth on Linux.
Copied from OPi's repo.

After building and installing of the package, enable and start the service `hciattach-opi@ttyBT0` to enable bluetooth device at boot.

If bluetoothctl complains org.bluez.Error.NotReady, check the rfkill status(`rfkill list`), and unblock the device(`rfkill unblock`) if necessary. The default state is blocked.
BTW `hciN`(N for an integer) is the actual working bluetooth device interface, and bluez only use `hciN`.
