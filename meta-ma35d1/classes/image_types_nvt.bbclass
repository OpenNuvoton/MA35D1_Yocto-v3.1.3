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
                            "

IMAGE_TYPEDEP_sdcard = "ext2"
do_image_sdcard[depends] = "parted-native:do_populate_sysroot \
                            virtual/trusted-firmware-a:do_deploy \
                            ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                            virtual/kernel:do_deploy \
                            virtual/bootloader:do_deploy \
                            python3-nuwriter-native:do_deploy \
                            jq-native:do_populate_sysroot \
                           "

# Generate the FIP image  with the bl2.bin and required Device Tree
generate_fip_image(){
if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
    ${DEPLOY_DIR_IMAGE}/fiptool create \
        --soc-fw ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin \
        --tos-fw ${DEPLOY_DIR_IMAGE}/tee-header_v2-optee.bin \
        --tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/tee-pager_v2-optee.bin \
        --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin \
        ${DEPLOY_DIR_IMAGE}/fip_with_optee.bin
    (cd ${DEPLOY_DIR_IMAGE}; ln -sf fip_with_optee.bin fip.bin)
else
    ${DEPLOY_DIR_IMAGE}/fiptool create \
        --soc-fw ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin \
        --nt-fw ${DEPLOY_DIR_IMAGE}/u-boot.bin \
        ${DEPLOY_DIR_IMAGE}/fip_without_optee.bin
    (cd ${DEPLOY_DIR_IMAGE}; ln -sf fip_without_optee.bin fip.bin)
fi
}

IMAGE_CMD_spinand() {
    BLKZ=$(expr ${SPINAND_BLKZ} \* 1024)
    BL12_ADDR=$(expr ${SPINAND_BLKZ} \* 5)
    BL12_DTB=$(expr ${SPINAND_BLKZ} \* 6)
    generate_fip_image
    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi ]; then
        (cd ${DEPLOY_DIR_IMAGE}; \
         ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-spinand; \
         nuwriter/nuwriter -c nuwriter/header-spinand.json; \
         cp conv/header.bin header-spinand.bin; \
         nuwriter/nuwriter -p nuwriter/pack-spinand.json; \
         cp pack/pack.bin pack-spinand.bin; \
         ln -sf pack-spinand.bin ${IMAGE_BASENAME}-${MACHINE}-spinand.pack; \
         rm rootfs.ubi-spinand \
        )
    fi
} 

IMAGE_CMD_nand() {
    generate_fip_image
    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi ]; then
        (cd ${DEPLOY_DIR_IMAGE}; \
         ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-nand; \
         nuwriter/nuwriter -c nuwriter/header-nand.json; \
         cp conv/header.bin header-nand.bin; \
         nuwriter/nuwriter -p nuwriter/pack-nand.json; \
         cp pack/pack.bin pack-nand.bin; \
         ln -sf pack-nand.bin ${IMAGE_BASENAME}-${MACHINE}-nand.pack; \
         rm rootfs.ubi-nand \
        )
    fi
}

#if 0
IMAGE_CMD_sdcard() {
    generate_fip_image
    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext2 ]; then
        ( cd ${DEPLOY_DIR_IMAGE}; \
         ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext2 rootfs.ext2-sdcard; \
         nuwriter/nuwriter -c nuwriter/header-sdcard.json; \
         cp conv/header.bin header-sdcard.bin; \
         nuwriter/nuwriter -p nuwriter/pack-sdcard.json; \
         cp pack/pack.bin pack-sdcard.bin; \
         ln -sf pack-sdcard.bin ${IMAGE_BASENAME}-${MACHINE}-sdcard.pack; \
         rm rootfs.ext2-sdcard \
        )
    fi
}
#else

SDCARD = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.sdcard"

# Boot partition size [in KiB]
BOOT_SPACE ?= "32768"

# Set alignment in KiB
IMAGE_ROOTFS_ALIGNMENT ?= "4096"

IMAGE_CMD_sdcard() {
#   BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
    BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} - 1)
    generate_fip_image
    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext2 ]; then

        SDCARD_SIZE=$(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ $ROOTFS_SIZE \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${SDCARD_FREE_SIZE})

        # Initialize a sparse file
        dd if=/dev/zero of=${SDCARD} bs=1 count=0 seek=$(expr 1024 \* ${SDCARD_SIZE})
        echo "========================================================================="
        echo ${BOOT_SPACE_ALIGNED}
        echo $(expr ${IMAGE_ROOTFS_ALIGNMENT} + ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED})
        parted -s ${SDCARD} mklabel msdos
        parted -s ${SDCARD} unit KiB mkpart primary $(expr ${BOOT_SPACE_ALIGNED} + ${IMAGE_ROOTFS_ALIGNMENT}) $(expr ${BOOT_SPACE_ALIGNED} + ${IMAGE_ROOTFS_ALIGNMENT} + $ROOTFS_SIZE)

        # MBR table for nuwriter
        dd if=/dev/zero of=${DEPLOY_DIR_IMAGE}/MBR.scdard.bin bs=1 count=0 seek=512
        dd if=${SDCARD} of=${DEPLOY_DIR_IMAGE}/MBR.scdard.bin conv=notrunc seek=0 count=1 bs=512

        ( cd ${DEPLOY_DIR_IMAGE}; \
            ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext2 rootfs.ext2-sdcard; \
            nuwriter/nuwriter -c nuwriter/header-sdcard.json; \
            cp conv/header.bin header-sdcard.bin; \

            $(cat nuwriter/pack-sdcard.json | jq 'setpath(["image",9,"offset"];"'$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)'")' > nuwriter/pack-sdcard-tmp.json); \
            cp nuwriter/pack-sdcard-tmp.json nuwriter/pack-sdcard.json; \
            rm nuwriter/pack-sdcard-tmp.json; \
            nuwriter/nuwriter -p nuwriter/pack-sdcard.json; \
            cp pack/pack.bin pack-sdcard.bin; \
            ln -sf pack-sdcard.bin ${IMAGE_BASENAME}-${MACHINE}-sdcard.pack; \
            rm rootfs.ext2-sdcard; \
            rm -rf $(date "+%m%d-*"); \
        )

        # 0x400
        dd if=${DEPLOY_DIR_IMAGE}/header-sdcard.bin of=${SDCARD} conv=notrunc seek=2 bs=512
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
        dd if=${DEPLOY_DIR_IMAGE}/fip.bin of=${SDCARD} conv=notrunc seek=2048 bs=512
        # 0x200000
        dd if=${DEPLOY_DIR_IMAGE}/Image-${MACHINE}.bin of=${SDCARD} conv=notrunc seek=4096 bs=512
        # root fs
        dd if=${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext2 of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
    fi
}
#endif

