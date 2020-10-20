inherit image_types

IMAGE_LINK_NAME_linux.sb = ""
IMAGE_CMD_linux.sb () {

}

do_image_ram[depends] = "virtual/kernel:do_deploy \
                         virtual/bootloader:do_deploy \
			 core-image-minimal:do_image_ext2 \
                        "


SDCARD = "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.sdcard"

SDCARD_GENERATION_COMMAND_nua3500 = "generate_nvt_sdcard"

#
# Generate the boot image with the boot scripts and required Device Tree
# files
_generate_boot_image() {

}

generate_nvt_sdcard () {

}
IMAGE_CMD_ext2 () {

}
IMAGE_CMD_sdcard () {

}

