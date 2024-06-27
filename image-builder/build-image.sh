#!/usr/bin/env bash

# quit on error
set -e
# verbose
set -x

source shlib/prepare.lib
source shlib/image-ops.lib


[ -f settings.env ] && source settings.env || {
    echo "Settings load failed! Exiting!"
    exit 1
}

mkdir -p "${WORKING_DIR}"
mkdir -p "${WORKING_DIR}/mount_point"

_IMAGE_FILE_PATH="${WORKING_DIR}/${IMAGE_NAME}"
_MOUNT_POINT=$(readlink -e "${WORKING_DIR}/mount_point")
_PACSTRAP_EXTRA_PARAMS=()

if [ -n "$PACSTRAP_PACMAN_CONFIG" ]; then
    _PACSTRAP_EXTRA_PARAMS+=("-C")
    _PACSTRAP_EXTRA_PARAMS+=("$PACSTRAP_PACMAN_CONFIG")
fi


# create empty image
create_image "${_IMAGE_FILE_PATH}" "${IMAGE_SIZE}"

# write partition table
initialize_partition_table_mbr "${_IMAGE_FILE_PATH}" "${MBR_PARTITION_SETUP[@]}"

# make image a loop device
_LOOP_DEVICE=$(losetup -f -P --show "${_IMAGE_FILE_PATH}")

# format partitions
# well currently here only exists a rootfs partition
mkfs.ext4 -F -L ROOTFS "${_LOOP_DEVICE}p1"

# write u-boot
# do this on the loop device so the image file is not truncated
# otherwise extra params for dd are required
dd if="${UBOOT_BINARY}" of="${_LOOP_DEVICE}" bs=512 seek=${UBOOT_OFFSET}

# mount the partition
mount "${_LOOP_DEVICE}p1" "${_MOUNT_POINT}"

# bootstrap rootfs
pacstrap -G -M "${_PACSTRAP_EXTRA_PARAMS[@]}" "${_MOUNT_POINT}" base "${PACSTRAP_PACKAGES[@]}"

# prepare swap file
if [ "$SWAP_SIZE" -gt 0 ]; then
    dd if=/dev/zero of="${_MOUNT_POINT}/swapfile" bs=1M count=${SWAP_SIZE}
    chmod 0600 "${_MOUNT_POINT}/swapfile"
    mkswap "${_MOUNT_POINT}/swapfile"
fi

# copy resources
for entry in "${INSTALL_STATIC_FILES[@]}"; do
    source_file=$(cut -d':' -f1 <<< "${entry}")
    dest_location=$(cut -d':' -f2 <<< "${entry}")
    file_mode=$(cut -d':' -f3 <<< "${entry}")

    [ -n "$file_mode" ] || file_mode=644

    install -Dm"${file_mode}" "${source_file}" "${_MOUNT_POINT}/${dest_location}"
done

# install offline packages
if [ 0 -lt "${#INSTALL_EXTRA_PACKAGES[@]}" ]; then
    pacstrap -G -M -U "${_PACSTRAP_EXTRA_PARAMS[@]}" "${_MOUNT_POINT}" "${INSTALL_EXTRA_PACKAGES[@]}"
fi

# write fstab
genfstab -U "${_MOUNT_POINT}" \
    | sed -E '/./{H;$!d} ; x ; s:(\n)?#.*\n.*swap.*::g' \
    | sed -E "s:(/dev/sd[a-z])|(/dev/loop[0-9]+p):/dev/mmcblk0p:g" \
    > "${_MOUNT_POINT}/etc/fstab"

if [ -f "${_MOUNT_POINT}/swapfile" ]; then
    printf "# Swap\n/swapfile  none  swap  defaults  0 0\n" >> "${_MOUNT_POINT}/etc/fstab"
fi

# write boot scripts
# the boot.cmd only needs a compilation
# the variables in bootEnv.txt need some substitutions
cp "${BOOT_SCRIPT_TEMPLATE}" "${_MOUNT_POINT}/boot/boot.cmd"
# TODO: make arm64 a parameter
mkimage -C none -A arm64 -T script -d "${_MOUNT_POINT}/boot/boot.cmd" "${_MOUNT_POINT}/boot/boot.scr"
# get UUID for substitution
_MOUNT_POINT_UUID=$(findmnt -Ufnro UUID -M "${_MOUNT_POINT}")
_sed_subst="
s|^rootdev=.*|rootdev=UUID=${_MOUNT_POINT_UUID}|g
"
sed "${_sed_subst}" "${BOOT_ENV_TEMPLATE}" | install -Dm644 /dev/stdin "${_MOUNT_POINT}/boot/bootEnv.txt"
# some fixup
if ! grep "^rootdev" "${_MOUNT_POINT}/boot/bootEnv.txt" > /dev/null; then
    printf "rootdev=UUID=%s\n" ${_MOUNT_POINT_UUID} >> "${_MOUNT_POINT}/boot/bootEnv.txt"
fi

# create initial privileged user
# NOTE: _MOUNT_POINT must be absolute path
useradd --root "${_MOUNT_POINT}" -m "${NEW_PRIV_USER}"
chroot "${_MOUNT_POINT}" sh -c "echo '$NEW_PRIV_USER:$NEW_PRIV_USER_PASS' | chpasswd"
usermod --root "${_MOUNT_POINT}" -aG "wheel" "$NEW_PRIV_USER"
for group in "${NEW_PRIV_USER_GROUPS[@]}"; do
    usermod --root "${_MOUNT_POINT}" -aG "$group" "$NEW_PRIV_USER"
done
# write sudoers config
if [ ! -d "${_MOUNT_POINT}/etc/sudoers.d" ] ; then 
    mkdir -p -m750 "${_MOUNT_POINT}/etc/sudoers.d"
    chown root:root "${_MOUNT_POINT}/etc/sudoers.d"
fi
echo "%wheel ALL=(ALL:ALL) ALL" | install -o root -g root -Dm640 /dev/stdin "${_MOUNT_POINT}/etc/sudoers.d/allow-users-in-wheel"

# CHANGEME: should be put else where
ln -sfTv dtb-linux-sunxi64-armbian "${_MOUNT_POINT}/boot/dtb"

# # umount and unload
umount "${_LOOP_DEVICE}p1"
losetup -d "${_LOOP_DEVICE}"
