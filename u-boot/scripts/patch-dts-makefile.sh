#!/usr/bin/env bash
PATH_TO_NEW_DTS=$1
NAME_SPACE=$2
PATH_TO_TARGET_MAKEFILE=$3

for dts in $(ls -1Av "$PATH_TO_NEW_DTS"); do
    [[ $dts = *.dts ]] || continue
    file_no_extension=${dts%.dts}
    if ! grep "${file_no_extension}" "${PATH_TO_TARGET_MAKEFILE}" > /dev/null; then
        echo "dtb-${NAME_SPACE} += ${file_no_extension}.dtb" >> "${PATH_TO_TARGET_MAKEFILE}"
    fi
done
