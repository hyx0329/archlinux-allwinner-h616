# Build u-boot for MangoPi MQ Quad

CROSS_COMPILE ?= aarch64-linux-gnu-

ATF_DIR = atf
ATF_REPO = https://github.com/ARM-software/arm-trusted-firmware.git
ATF_TAG := lts-v2.10.25
ATF_PLATFORM = sun50i_h616
ATF_DEBUG ?= 0
ATF_BINARY_NAME := bl31.bin

ATF_CROSS_COMPILE := ${CROSS_COMPILE}
ATF_BINARY_PATH != [ -z ${ATF_DEBUG} ] && printf "%s" "build/${ATF_PLATFORM}/debug" || printf "%s" "build/${ATF_PLATFORM}/release"
ATF_BINARY = ${ATF_DIR}/${ATF_BINARY_PATH}/${ATF_BINARY_NAME}

U_BOOT_DIR = u-boot
U_BOOT_REPO := https://github.com/u-boot/u-boot.git
U_BOOT_TAG := v2025.04
U_BOOT_CONFIGS_DIRECTORY = configs
U_BOOT_DEFCONFIG := orangepi_zero2w_defconfig
U_BOOT_DTS_DIRECTORY = dts/upstream/src/arm64/allwinner
U_BOOT_DTS_NAMESPACE := $$(CONFIG_MACH_SUN50I_H616)

U_BOOT_CROSS_COMPILE := ${CROSS_COMPILE}
U_BOOT_COMPILE_PARAM := CROSS_COMPILE=${U_BOOT_CROSS_COMPILE} BL31=../${ATF_BINARY}
U_BOOT_BINARY_NAME := u-boot-sunxi-with-spl.bin
U_BOOT_BINARY = ${U_BOOT_DIR}/${U_BOOT_BINARY_NAME}




.DEFAULT_GOAL: help

.PHONY: help
help:
	@echo "This is a dummy target, please make build-u-boot instead."

### Build ATF ###

.PHONY: clone-atf
clone-atf:
	[ -d ${ATF_DIR} ] || { git clone ${ATF_REPO} ${ATF_DIR}; $(MAKE) prepare-atf; }

.PHONY: prepare-atf
prepare-atf:
	$(MAKE) -C ${ATF_DIR} realclean
	git -C ${ATF_DIR} reset --hard
	git -C ${ATF_DIR} clean -f -d
	git -C ${ATF_DIR} fetch --tags || :
	git -C ${ATF_DIR} checkout ${ATF_TAG}

.PHONY: build-atf
build-atf: ${ATF_BINARY}

${ATF_BINARY}:
	$(MAKE) clone-atf
	$(MAKE) -C ${ATF_DIR} CROSS_COMPILE=${ATF_CROSS_COMPILE} realclean
	$(MAKE) -C ${ATF_DIR} CROSS_COMPILE=${ATF_CROSS_COMPILE} PLAT=${ATF_PLATFORM} DEBUG=${ATF_DEBUG} bl31

.PHONY: print-atf-location
print-atf-bin-location:
	@echo ${ATF_BINARY}

### End Build ATF ###

### Build u-boot ###

.PHONY: clone-u-boot
clone-u-boot:
	[ -d ${U_BOOT_DIR} ] || { git clone ${U_BOOT_REPO} ${U_BOOT_DIR}; $(MAKE) prepare-u-boot; }

.PHONY: prepare-u-boot
prepare-u-boot:
	$(MAKE) -C ${U_BOOT_DIR} distclean
	git -C ${U_BOOT_DIR} reset --hard
	git -C ${U_BOOT_DIR} clean -f -d
	git -C ${U_BOOT_DIR} fetch --tags || :
	git -C ${U_BOOT_DIR} checkout ${U_BOOT_TAG}
	./scripts/apply-patches.sh patches "${U_BOOT_DIR}"
	cp patches/defconfigs/* ${U_BOOT_DIR}/${U_BOOT_CONFIGS_DIRECTORY}
	cp -r patches/dts/* ${U_BOOT_DIR}/${U_BOOT_DTS_DIRECTORY}
# 	./scripts/patch-dts-makefile.sh "patches/dts" '${U_BOOT_DTS_NAMESPACE}' "${U_BOOT_DIR}/${U_BOOT_DTS_DIRECTORY}/Makefile"

.PHONY: build-u-boot
build-u-boot: ${U_BOOT_BINARY}

${U_BOOT_BINARY}: ${ATF_BINARY}
	$(MAKE) clone-u-boot
	$(MAKE) -C ${U_BOOT_DIR} ${U_BOOT_COMPILE_PARAM} ${U_BOOT_DEFCONFIG}
	# Remove all boot delay
	bash -c "cd ${U_BOOT_DIR}; ./scripts/config --set-val BOOTDELAY 0"
	$(MAKE) -C ${U_BOOT_DIR} ${U_BOOT_COMPILE_PARAM}

print-u-boot-bin-location:
	@echo ${U_BOOT_BINARY}

### End Build u-boot ###

.PHONY: clean
clean:
	[ ! -d ${ATF_DIR} ] || { $(MAKE) -C ${ATF_DIR} clean; $(MAKE) prepare-atf; }
	[ ! -d ${U_BOOT_DIR} ] || { $(MAKE) -C ${U_BOOT_DIR} clean; $(MAKE) prepare-u-boot; }

.PHONY: fullclean
fullclean:
	rm -rf ${ATF_DIR} ${U_BOOT_DIR}
