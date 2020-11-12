inherit image_types

IMAGE_TYPEDEP_nand = "ubi"
do_image_nand[depends] = "virtual/trusted-firmware-a:do_deploy \
		          ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                          virtual/kernel:do_deploy \
                          virtual/bootloader:do_deploy \
                          python3-nuwriter-native:do_deploy \
                         "

IMAGE_TYPEDEP_spinand = "ubi"
do_image_spinand[depends] = "virtual/trusted-firmware-a:do_deploy \
                             ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                             virtual/kernel:do_deploy \
                             virtual/bootloader:do_deploy \
                             python3-nuwriter-native:do_deploy \
                            "

IMAGE_TYPEDEP_sdcard = "ext2"
do_image_sdcard[depends] = "virtual/trusted-firmware-a:do_deploy \
                            ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                            virtual/kernel:do_deploy \
                            virtual/bootloader:do_deploy \
                            python3-nuwriter-native:do_deploy \
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
    generate_fip_image
    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi ]; then
        (cd ${DEPLOY_DIR_IMAGE}; \
         ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-spinand; \
         nuwriter/nuwriter -c nuwriter/header.json; \
         nuwriter/nuwriter -p nuwriter/pack-spinand.json; \
         ln -sf $(readlink -f pack/pack.bin) ${IMAGE_BASENAME}-${MACHINE}-spinand.pack; \
         rm rootfs.ubi-spinand \
        )
    fi
} 

IMAGE_CMD_nand() {
    generate_fip_image
    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi ]; then
        (cd ${DEPLOY_DIR_IMAGE}; \
         ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-nand; \
         nuwriter/nuwriter -c nuwriter/header.json; \
         nuwriter/nuwriter -p nuwriter/pack-nand.json; \
         ln -sf $(readlink -f pack/pack.bin) ${IMAGE_BASENAME}-${MACHINE}-nand.pack; \
         rm rootfs.ubi-nand \
        )
    fi
}

IMAGE_CMD_sdcard() {
    generate_fip_image
    if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext2 ]; then
        ( cd ${DEPLOY_DIR_IMAGE}; \
         ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext2 rootfs.ext2-sdcard; \
         nuwriter/nuwriter -c nuwriter/header.json; \
         nuwriter/nuwriter -p nuwriter/pack-sdcard.json; \
         ln -sf $(readlink -f pack/pack.bin) ${IMAGE_BASENAME}-${MACHINE}-sdcard.pack; \
         rm rootfs.ext2-sdcard \
        )
    fi
}

