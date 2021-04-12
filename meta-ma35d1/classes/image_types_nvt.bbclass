inherit image_types

IMAGE_TYPEDEP_nand = "ubi"
do_image_nand[depends] = "virtual/trusted-firmware-a:do_deploy \
		          ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                          virtual/kernel:do_deploy \
                          virtual/bootloader:do_deploy \
                          python3-nuwriter-native:do_deploy \
                          jq-native:do_populate_sysroot \
                         "

IMAGE_TYPEDEP_spinand = "ubi"
do_image_spinand[depends] = "virtual/trusted-firmware-a:do_deploy \
                             ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                             virtual/kernel:do_deploy \
                             virtual/bootloader:do_deploy \
                             python3-nuwriter-native:do_deploy \
                             jq-native:do_populate_sysroot \
                             ${@bb.utils.contains('IMAGE_FSTYPES', 'nand', '${IMAGE_BASENAME}:do_image_nand', '', d)} \
                            "

IMAGE_TYPEDEP_sdcard = "ext4"
do_image_sdcard[depends] = "parted-native:do_populate_sysroot \
                            virtual/trusted-firmware-a:do_deploy \
                            ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                            virtual/kernel:do_deploy \
                            virtual/bootloader:do_deploy \
                            python3-nuwriter-native:do_deploy \
                            jq-native:do_populate_sysroot \
                            ${@bb.utils.contains('IMAGE_FSTYPES', 'nand', '${IMAGE_BASENAME}:do_image_nand', '', d)} \
                            ${@bb.utils.contains('IMAGE_FSTYPES', 'spinand', '${IMAGE_BASENAME}:do_image_spinand', '', d)} \
                           "

IMAGE_CMD_spinand() {
    # Generate the FIP image  with the bl2.bin and required Device Tree
    if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
        ${DEPLOY_DIR_IMAGE}/fiptool create \
            --soc-fw ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin \
            --tos-fw ${DEPLOY_DIR_IMAGE}/tee-header_v2-optee.bin \
            --tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/tee-pager_v2-optee.bin \
            --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin-spinand \
            ${DEPLOY_DIR_IMAGE}/fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand
        (cd ${DEPLOY_DIR_IMAGE}; ln -sf fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand fip.bin-spinand)
    else
        ${DEPLOY_DIR_IMAGE}/fiptool create \
            --soc-fw ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin \
            --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin-spinand \
            ${DEPLOY_DIR_IMAGE}/fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand
        (cd ${DEPLOY_DIR_IMAGE}; ln -sf fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand fip.bin-spinand)
    fi

    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi ]; then
        (cd ${DEPLOY_DIR_IMAGE}; \
         ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-spinand; \
         nuwriter/nuwriter -c nuwriter/header-spinand.json; \
         cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-spinand.bin; \
         nuwriter/nuwriter -p nuwriter/pack-spinand.json; \
         cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-spinand.bin; \
         ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-spinand.bin ${IMAGE_BASENAME}-${MACHINE}-spinand.pack; \
         rm rootfs.ubi-spinand \
         rm -rf $(date "+%m%d-*"); \
        )
    fi
} 

IMAGE_CMD_nand() {
    # Generate the FIP image  with the bl2.bin and required Device Tree
    if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
        ${DEPLOY_DIR_IMAGE}/fiptool create \
            --soc-fw ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin \
            --tos-fw ${DEPLOY_DIR_IMAGE}/tee-header_v2-optee.bin \
            --tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/tee-pager_v2-optee.bin \
            --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin-nand \
            ${DEPLOY_DIR_IMAGE}/fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand
        (cd ${DEPLOY_DIR_IMAGE}; ln -sf fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand fip.bin-nand)
    else
        ${DEPLOY_DIR_IMAGE}/fiptool create \
            --soc-fw ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin \
            --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin-nand \
            ${DEPLOY_DIR_IMAGE}/fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand
        (cd ${DEPLOY_DIR_IMAGE}; ln -sf fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand fip.bin-nand)
    fi

    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi ]; then
        (cd ${DEPLOY_DIR_IMAGE}; \
         ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-nand; \
         nuwriter/nuwriter -c nuwriter/header-nand.json; \
         cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-nand.bin; \
         nuwriter/nuwriter -p nuwriter/pack-nand.json; \
         cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-nand.bin; \
         ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-nand.bin ${IMAGE_BASENAME}-${MACHINE}-nand.pack; \
         rm rootfs.ubi-nand \
         rm -rf $(date "+%m%d-*"); \
        )
    fi
}

SDCARD = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.sdcard"

# Boot partition size [in KiB]
BOOT_SPACE ?= "32768"

# Set alignment in KiB
IMAGE_ROOTFS_ALIGNMENT ?= "4096"

IMAGE_CMD_sdcard() {
    BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} - 1 )

    # Generate the FIP image  with the bl2.bin and required Device Tree
    if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
        ${DEPLOY_DIR_IMAGE}/fiptool create \
            --soc-fw ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin \
            --tos-fw ${DEPLOY_DIR_IMAGE}/tee-header_v2-optee.bin \
            --tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/tee-pager_v2-optee.bin \
            --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin-sdcard \
            ${DEPLOY_DIR_IMAGE}/fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard
        (cd ${DEPLOY_DIR_IMAGE}; ln -sf fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard fip.bin-sdcard)
    else
        ${DEPLOY_DIR_IMAGE}/fiptool create \
            --soc-fw ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin \
            --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin-sdcard \
            ${DEPLOY_DIR_IMAGE}/fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard
        (cd ${DEPLOY_DIR_IMAGE}; ln -sf fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard fip.bin-sdcard)
    fi

    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 ]; then

        SDCARD_SIZE=$(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ $ROOTFS_SIZE \+ ${IMAGE_ROOTFS_ALIGNMENT})

        # Initialize a sparse file
        dd if=/dev/zero of=${SDCARD} bs=1 count=0 seek=$(expr 1024 \* ${SDCARD_SIZE})
        parted -s ${SDCARD} mklabel msdos
        parted -s ${SDCARD} unit KiB mkpart primary $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT}) $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ $ROOTFS_SIZE )
        parted ${SDCARD} print

        # MBR table for nuwriter
        dd if=/dev/zero of=${DEPLOY_DIR_IMAGE}/MBR.scdard.bin bs=1 count=0 seek=512
        dd if=${SDCARD} of=${DEPLOY_DIR_IMAGE}/MBR.scdard.bin conv=notrunc seek=0 count=1 bs=512

        ( cd ${DEPLOY_DIR_IMAGE}; \
            ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 rootfs.ext4-sdcard; \
            nuwriter/nuwriter -c nuwriter/header-sdcard.json; \
            cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin; \

            $(cat nuwriter/pack-sdcard.json | jq 'setpath(["image",9,"offset"];"'$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)'")' > nuwriter/pack-sdcard-tmp.json); \
            cp nuwriter/pack-sdcard-tmp.json nuwriter/pack-sdcard.json; \
            rm nuwriter/pack-sdcard-tmp.json; \
            nuwriter/nuwriter -p nuwriter/pack-sdcard.json; \
            cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin; \
            ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin ${IMAGE_BASENAME}-${MACHINE}-sdcard.pack; \
            rm rootfs.ext4-sdcard; \
            rm -rf $(date "+%m%d-*"); \
        )

        # 0x400
        dd if=${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin of=${SDCARD} conv=notrunc seek=2 bs=512
	# 0x10000
        dd if=${DEPLOY_DIR_IMAGE}/ddrimg_tfa.bin of=${SDCARD} conv=notrunc seek=128 bs=512
        # 0x20000
        dd if=${DEPLOY_DIR_IMAGE}/bl2-ma35d1.dtb of=${SDCARD} conv=notrunc seek=256 bs=512
        # 0x30000
        dd if=${DEPLOY_DIR_IMAGE}/bl2-ma35d1.bin of=${SDCARD} conv=notrunc seek=384 bs=512
        # 0x40000
        dd if=${DEPLOY_DIR_IMAGE}/$(basename ${KERNEL_DEVICETREE}) of=${SDCARD} conv=notrunc seek=512 bs=512
        # 0x80000
        dd if=${DEPLOY_DIR_IMAGE}/u-boot-initial-env.bin-sdcard of=${SDCARD} conv=notrunc seek=1024 bs=512
        # 0x100000
        dd if=${DEPLOY_DIR_IMAGE}/fip.bin-sdcard of=${SDCARD} conv=notrunc seek=2048 bs=512
        # 0x200000
        dd if=${DEPLOY_DIR_IMAGE}/Image-${MACHINE}.bin of=${SDCARD} conv=notrunc seek=4096 bs=512
        # root fs
        dd if=${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
    fi
}

