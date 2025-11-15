#!/usr/bin/env bash
# current working directory must be kernel source directory

set -e

# armbian/build source
SRC=$1
# kernel source dir
kerneldir=$2
# linux version
version=$3
# family code, eg. sunxi64, rockchip64
LINUXFAMILY=$4

# dummy impl
display_alert() { :; }

# copied and adapted from $SRC/lib/functions/compilation/patch/patching.sh
process_patch_file() {
	local patch="${1}"
	local status="${2}"
	local -i patch_date
	local relative_patch="${patch##"${SRC}"/}" # ${FOO##prefix} remove prefix from FOO

	# detect and remove files which patch will create
	lsdiff -s --strip=1 "${patch}" | grep '^+' | awk '{print $2}' | xargs -I % sh -c 'rm -f %'

	# shellcheck disable=SC2015 # noted, thanks. I need to handle exit code here.
	patch --batch -p1 -N --input="${patch}" --quiet --reject-file=- && { # "-" discards rejects
		printf "* $status ${relative_patch}: %s\n" "okay"
	} || {
		printf "* $status ${relative_patch}: %s\n" "FAILED"
        return 1
	}
}

# a naive compatible implementation
linux-version() {
    local action=$1
    case $action in
        compare)
            local v1=$2
            local operator=$3
            local v2=$4
            v1=$(printf "%02d%03d%03d" $(tr '.' ' ' <<< "$v1"))
            v2=$(printf "%02d%03d%03d" $(tr '.' ' ' <<< "$v2"))

			test "$v1" "-$operator" "$v2"
			return $?
        ;;
    esac
}

# load patching functions
source "$SRC"/lib/functions/compilation/patch/drivers_network.sh

# apply patches
driver_uwe5622
