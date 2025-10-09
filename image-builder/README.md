# Image Builder

Here is a set of shell scripts to generate a simple archlinux image.

- install packages
    - `arch-install-scripts`
    - `qemu-user-static`
    - `qemu-user-static-binfmt`
    - maybe more
- configure the settings in `settings.env`
    - You should change `WORKING_DIR` as your RAM may not be big enough to contain the image file.
    - This file will be sourced directly by `build-image.sh`, if no other config is provided.
- run `build-image.sh` with root privilege to build the full image
    - For MangoPi MQ Quad: `./build-image.sh settings-mangopi-mq-quad.env`
    - For OrangePi Zero 2W: `./build-image.sh settings-orangepi-zero-2w.env`
    - The differences are the preinstalled wireless chip drivers and kernel packages.
    - Yes the first parameter passed to builder script is the custom config file to use.
    - Two configs both source the `settings.env` to share some default values.

*the scripts in `shlib` are supportive libs consisting of all low-level logics*

## Things to do after first boot

- resize partition
    - not documented here
- initialize keyring
    - `pacman-key --init`
    - `pacman-key --populate archlinux archlinuxarm`

### To enable bluetooth on OrangePi Zero 2W

- run `systemctl enable --now hciattach-opi@ttyBT0` to enable the userspace driver
- run `systemctl enable --now bluetooth` to enable the bluetooth service
- run `rfkill list` to check if BT is blocked
    - unblock with `rfkill unblock [ID]` if necessary
