# Image Builder

Here is a set of shell scripts to generate a simple archlinux image.

- install packages
    - `arch-install-scripts`
    - `qemu-user-static`
    - `qemu-user-static-binfmt`
    - maybe more
- configure the settings in `settings.env`
- run `build-image.sh` with root privilege to build the full image

*the scripts in `shlib` are supporting libs consisting of all low-level logics*

## things to do after first boot

- resize partition
    - not documented here
- initialize keyring
    - `pacman-key --init`
    - `pacman-key --populate archlinux archlinuxarm`
