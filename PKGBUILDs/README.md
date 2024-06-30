# ArchLinux Packages

Here are custom packages to support ArchLinux on H616/H618 boards.

These packages are meant to be built on an arm64 host.

## linux-sunxi64-armbian

linux-sunxi64-armbian is a kernel package tweaked to support MangoPi MQ Quad and OrangePi Zero 2W.
It can still be used on other sunxi boards though.

The package uses ArchLinux lts kernel(6.6) package as a template, and utilizes the patches from armbian build.

This package is cross-compile compatible.
To cross compile it on a powerful x86_64 host, run the following command instead of the plain makepkg:

```bash
makepkg ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CARCH=aarch64
```

*All other linux packages can be cross compiled in the same way as well.*

*header package will fail and it's expected :)*

*The linux headers will probably not work, because they are compiled for the builder machine(x86_64) instead of the target machine(arm64).*

## hciattach-opi

Currently UWE5622 needs special care to enable both WiFi and bluetooth. This package is the tool to enable bluetooth.

After building and installing of the package, enable and start the service `hciattach-opi@ttyBT0` to enable bluetooth at boot.

If bluetoothctl complains org.bluez.Error.NotReady, check the rfkill status, and unblock the device if necessary. The default state is blocked.
`hciN`(N for an integer) is the working bluetooth device, and bluez only use `hciN`.
