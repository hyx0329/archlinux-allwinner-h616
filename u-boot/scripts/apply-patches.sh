[ -d $1 ] && [ -d $2 ] || exit 0

PATCHES_DIR=$(readlink -e $1)
TARGET_DIR=$(readlink -e $2)

pushd "$TARGET_DIR"

for f in $(ls -1Av "$PATCHES_DIR"); do
    [[ $f = *.patch ]] && [ -f "$PATCHES_DIR/$f" ] || continue
    printf "Applying %s\n" "$f"
    patch -Np1 < "$PATCHES_DIR/$f"
done

popd
