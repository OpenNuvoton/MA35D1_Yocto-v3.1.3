inherit image_types

DEPENDS = " python3-nuwriter-native gcc-arm-none-eabi-native"

IMAGE_TYPEDEP_nand = "ubi"
do_image_nand[depends] = "virtual/trusted-firmware-a:do_deploy \
		          ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                          virtual/kernel:do_deploy \
                          virtual/bootloader:do_deploy \
                          python3-nuwriter-native:do_install \
                          jq-native:do_populate_sysroot \
                          mtd-utils-native:do_populate_sysroot \
                          m4proj:do_deploy \
                         "

IMAGE_TYPEDEP_spinand = "ubi"
do_image_spinand[depends] = "virtual/trusted-firmware-a:do_deploy \
                             ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                             virtual/kernel:do_deploy \
                             virtual/bootloader:do_deploy \
                             python3-nuwriter-native:do_install \
                             jq-native:do_populate_sysroot \
                             mtd-utils-native:do_populate_sysroot \
                             m4proj:do_deploy \
                             ${@bb.utils.contains('IMAGE_FSTYPES', 'nand', '${IMAGE_BASENAME}:do_image_nand', '', d)} \
                            "

IMAGE_TYPEDEP_spinand = "jffs2"
do_image_spinor[depends] = "virtual/trusted-firmware-a:do_deploy \
                             ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                             virtual/kernel:do_deploy \
                             virtual/bootloader:do_deploy \
                             python3-nuwriter-native:do_install \
                             jq-native:do_populate_sysroot \
                             mtd-utils-native:do_populate_sysroot \
                             m4proj:do_deploy \
                             ${@bb.utils.contains('IMAGE_FSTYPES', 'nand', '${IMAGE_BASENAME}:do_image_nand', '', d)} \
                             ${@bb.utils.contains('IMAGE_FSTYPES', 'spinand', '${IMAGE_BASENAME}:do_image_spinand', '', d)} \
                            "

IMAGE_TYPEDEP_sdcard = "ext4"
do_image_sdcard[depends] = "parted-native:do_populate_sysroot \
                            virtual/trusted-firmware-a:do_deploy \
                            ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} \
                            virtual/kernel:do_deploy \
                            virtual/bootloader:do_deploy \
                            python3-nuwriter-native:do_install \
                            jq-native:do_populate_sysroot \
                            m4proj:do_deploy \
                            ${@bb.utils.contains('IMAGE_FSTYPES', 'nand', '${IMAGE_BASENAME}:do_image_nand', '', d)} \
                            ${@bb.utils.contains('IMAGE_FSTYPES', 'spinand', '${IMAGE_BASENAME}:do_image_spinand', '', d)} \
                            ${@bb.utils.contains('IMAGE_FSTYPES', 'spinor', '${IMAGE_BASENAME}:do_image_spinor', '', d)} \
                           "
NUWRITER_DIR="${RECIPE_SYSROOT_NATIVE}${datadir}/nuwriter"
M4_OPJCOPY="${RECIPE_SYSROOT_NATIVE}${datadir}/gcc-arm-none-eabi/arm-none-eabi/bin/objcopy"

IMAGE_CMD_spinand() {
	if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-enc-spinand.pack ]; then
		rm ${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-enc-spinand.bin -f
		rm ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-enc-spinand.pack -f
		rm ${DEPLOY_DIR_IMAGE}/pack-${IMAGE_BASENAME}-${MACHINE}-enc-spinand.bin -f
	elif [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-spinand.pack ]; then
		rm ${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-spinand.bin -f
		rm ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-spinand.pack -f
		rm ${DEPLOY_DIR_IMAGE}/pack-${IMAGE_BASENAME}-${MACHINE}-spinand.bin -f
	fi

	ENC=""
	FIPDIR=""
	RTP_BIN=${TFA_M4_BIN}
	rm ${DEPLOY_DIR_IMAGE}/fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand -f
	rm ${DEPLOY_DIR_IMAGE}/fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand -f
	if [ "${SECURE_BOOT}" = "yes" ]; then
		FIPDIR="fip/"
		ENC="enc_"
		rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand -f
		rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand -f
		(cd ${DEPLOY_DIR_IMAGE}; mkdir -p ${FIPDIR}; \
		cat ${NUWRITER_DIR}/enc_fip.json | jq -r ".header.secureboot = \"yes\"" | \
		jq -r ".header.aeskey = \"${AES_KEY}\"" | jq -r ".header.ecdsakey = \"${ECDSA_KEY}\"" \
		> ${FIPDIR}enc_fip.json; \
	cp ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/tee-header_v2-optee.bin ${FIPDIR}/enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}tee-header_v2-optee.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/tee-pager_v2-optee.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}tee-pager_v2-optee.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/u-boot.bin-spinand ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}u-boot.bin-spinand; \
	rm -rf $(date "+%m%d-*");)
	if [ "${TFA_LOAD_M4}" = "yes" ]; then
		(cd ${DEPLOY_DIR_IMAGE}; \
		cp ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ${FIPDIR}enc.bin; \
		nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
			cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}rtp_bin; \
		rm -rf $(date "+%m%d-*");)
		RTP_BIN="rtp_bin"
	fi
	rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}enc.bin;
	fi

	# Generate the FIP image  with the bl2.bin and required Device Tree
	if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
		if [ "${TFA_LOAD_M4}" = "no" ]; then
			${DEPLOY_DIR_IMAGE}/fiptool create \
				--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
				--tos-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-header_v2-optee.bin \
				--tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-pager_v2-optee.bin \
				--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-spinand \
				${DEPLOY_DIR_IMAGE}/${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand
		else
			if [ -f ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ]; then
				${DEPLOY_DIR_IMAGE}/fiptool create \
					--scp-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}${RTP_BIN} \
					--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
					--tos-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-header_v2-optee.bin \
					--tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-pager_v2-optee.bin \
					--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-spinand \
					${DEPLOY_DIR_IMAGE}/${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand
			else
				bberror "Could not found ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN}"
            fi
		fi
		(cd ${DEPLOY_DIR_IMAGE}; ln -sf ${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand fip.bin-spinand)
	else
		if [ "${TFA_LOAD_M4}" = "no" ]; then
			${DEPLOY_DIR_IMAGE}/fiptool create \
				--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
				--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-spinand \
				${DEPLOY_DIR_IMAGE}/${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand
		else
			if [ -f ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ]; then
				${DEPLOY_DIR_IMAGE}/fiptool create \
					--scp-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}${RTP_BIN} \
					--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
					--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-spinand \
					${DEPLOY_DIR_IMAGE}/${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand
			else
				bberror "Could not found ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN}"
			fi
		fi
		(cd ${DEPLOY_DIR_IMAGE}; ln -sf ${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinand fip.bin-spinand)
	fi

	(cd ${DEPLOY_DIR_IMAGE}; ubinize ${UBINIZE_ARGS} -o u-boot-initial-env.ubi-spinand u-boot-initial-env-spinand-ubi.cfg)

	if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi ]; then
		if [ "${SECURE_BOOT}" = "no" ]; then
			(cd ${DEPLOY_DIR_IMAGE}; \
			cp ${NUWRITER_DIR}/*-spinand.json  nuwriter; \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-spinand; \
			nuwriter/nuwriter -c nuwriter/header-spinand.json; \
			cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-spinand.bin; \
			nuwriter/nuwriter -p nuwriter/pack-spinand.json; \
			cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-spinand.bin; \
			ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-spinand.bin ${IMAGE_BASENAME}-${MACHINE}-spinand.pack; \
			rm -rf $(date "+%m%d-*");)
			if [ -f ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-spinand.dtb ]; then
				rm ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-spinand.dtb
				rm ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-spinand.bin
			fi
		else
			(cd ${DEPLOY_DIR_IMAGE}; \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 rootfs.ext4-sdcard; \
			$(cat ${NUWRITER_DIR}/header-spinand.json | jq -r ".header.secureboot = \"yes\"" | \
			jq -r ".header.aeskey = \"${AES_KEY}\"" | jq -r ".header.ecdsakey = \"${ECDSA_KEY}\"" \
			> nuwriter/header-spinand.json); \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-spinand; \
			nuwriter/nuwriter -c nuwriter/header-spinand.json; \
			cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-enc-spinand.bin; \
			cp conv/enc_bl2-ma35d1.dtb enc_bl2-ma35d1-spinand.dtb; \
			cp conv/enc_bl2-ma35d1.bin enc_bl2-ma35d1-spinand.bin; \
			echo "{\""publicx"\": \""$(head -6 conv/header_key.txt | tail +6)"\", \
			\""publicy"\": \""$(head -7 conv/header_key.txt | tail +7)"\", \
			\""aeskey"\": \""$(head -2 conv/header_key.txt | tail +2)"\"}" | \
			jq  > nuwriter/otp_key-spinand.json; \
			$(cat ${NUWRITER_DIR}/pack-spinand.json | \
			jq 'setpath(["image",1,"file"];"enc_bl2-ma35d1-spinand.dtb")' | \
			jq 'setpath(["image",2,"file"];"enc_bl2-ma35d1-spinand.bin")' > nuwriter/pack-spinand.json); \
			nuwriter/nuwriter -p nuwriter/pack-spinand.json; \
			cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-enc-spinand.bin; \
			ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-enc-spinand.bin ${IMAGE_BASENAME}-${MACHINE}-enc-spinand.pack; \
			rm -rf $(date "+%m%d-*");)
		fi
	fi
}

IMAGE_CMD_spinor() {
	if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-enc-spinor.pack ]; then
		rm ${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-enc-spinor.bin -f
		rm ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-enc-spinor.pack -f
		rm ${DEPLOY_DIR_IMAGE}/pack-${IMAGE_BASENAME}-${MACHINE}-enc-spinor.bin -f
	elif [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-spinor.pack ]; then
		rm ${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-spinor.bin -f
		rm ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-spinor.pack -f
		rm ${DEPLOY_DIR_IMAGE}/pack-${IMAGE_BASENAME}-${MACHINE}-spinor.bin -f
	fi

	ENC=""
	FIPDIR=""
	RTP_BIN=${TFA_M4_BIN}
	rm ${DEPLOY_DIR_IMAGE}/fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand -f
	rm ${DEPLOY_DIR_IMAGE}/fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand -f
	if [ "${SECURE_BOOT}" = "yes" ]; then
		FIPDIR="fip/"
		ENC="enc_"
		rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinor -f
		rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinor -f
		(cd ${DEPLOY_DIR_IMAGE}; mkdir -p ${FIPDIR}; \
		cat ${NUWRITER_DIR}/enc_fip.json | jq -r ".header.secureboot = \"yes\"" | \
		jq -r ".header.aeskey = \"${AES_KEY}\"" | jq -r ".header.ecdsakey = \"${ECDSA_KEY}\"" \
		> ${FIPDIR}enc_fip.json; \
	cp ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/tee-header_v2-optee.bin ${FIPDIR}/enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}tee-header_v2-optee.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/tee-pager_v2-optee.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}tee-pager_v2-optee.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/u-boot.bin-spinor ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}u-boot.bin-spinor; \
	rm -rf $(date "+%m%d-*");)
	if [ "${TFA_LOAD_M4}" = "yes" ]; then
		(cd ${DEPLOY_DIR_IMAGE}; \
		cp ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ${FIPDIR}enc.bin; \
		nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
			cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}rtp_bin; \
		rm -rf $(date "+%m%d-*");)
		RTP_BIN="rtp_bin"
	fi
	rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}enc.bin;
	fi

	# Generate the FIP image  with the bl2.bin and required Device Tree
	if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
		if [ "${TFA_LOAD_M4}" = "no" ]; then
			${DEPLOY_DIR_IMAGE}/fiptool create \
				--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
				--tos-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-header_v2-optee.bin \
				--tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-pager_v2-optee.bin \
				--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-spinor \
				${DEPLOY_DIR_IMAGE}/${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinor
		else
			if [ -f ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ]; then
				${DEPLOY_DIR_IMAGE}/fiptool create \
					--scp-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}${RTP_BIN} \
					--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
					--tos-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-header_v2-optee.bin \
					--tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-pager_v2-optee.bin \
					--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-spinor \
					${DEPLOY_DIR_IMAGE}/${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinor
			else
				bberror "Could not found ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN}"
            fi
		fi
		(cd ${DEPLOY_DIR_IMAGE}; ln -sf ${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinor fip.bin-spinor)
	else
		if [ "${TFA_LOAD_M4}" = "no" ]; then
			${DEPLOY_DIR_IMAGE}/fiptool create \
				--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
				--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-spinor \
				${DEPLOY_DIR_IMAGE}/${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinor
		else
			if [ -f ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ]; then
				${DEPLOY_DIR_IMAGE}/fiptool create \
					--scp-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}${RTP_BIN} \
					--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
					--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-spinor \
					${DEPLOY_DIR_IMAGE}/${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinor
			else
				bberror "Could not found ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN}"
			fi
		fi
		(cd ${DEPLOY_DIR_IMAGE}; ln -sf ${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-spinor fip.bin-spinor)
	fi

	if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.jffs2 ]; then
		if [ "${SECURE_BOOT}" = "no" ]; then
			(cd ${DEPLOY_DIR_IMAGE}; \
			cp ${NUWRITER_DIR}/*-spinor.json  nuwriter; \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-spinor; \
			nuwriter/nuwriter -c nuwriter/header-spinor.json; \
			cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-spinor.bin; \
			nuwriter/nuwriter -p nuwriter/pack-spinor.json; \
			cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-spinor.bin; \
			ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-spinor.bin ${IMAGE_BASENAME}-${MACHINE}-spinor.pack; \
			rm -rf $(date "+%m%d-*");)
			if [ -f ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-spinor.dtb ]; then
				rm ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-spinor.dtb
				rm ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-spinor.bin
			fi
		else
			(cd ${DEPLOY_DIR_IMAGE}; \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 rootfs.ext4-sdcard; \
			$(cat ${NUWRITER_DIR}/header-spinor.json | jq -r ".header.secureboot = \"yes\"" | \
			jq -r ".header.aeskey = \"${AES_KEY}\"" | jq -r ".header.ecdsakey = \"${ECDSA_KEY}\"" \
			> nuwriter/header-spinor.json); \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-spinor; \
			nuwriter/nuwriter -c nuwriter/header-spinor.json; \
			cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-enc-spinor.bin; \
			cp conv/enc_bl2-ma35d1.dtb enc_bl2-ma35d1-spinor.dtb; \
			cp conv/enc_bl2-ma35d1.bin enc_bl2-ma35d1-spinor.bin; \
			echo "{\""publicx"\": \""$(head -6 conv/header_key.txt | tail +6)"\", \
			\""publicy"\": \""$(head -7 conv/header_key.txt | tail +7)"\", \
			\""aeskey"\": \""$(head -2 conv/header_key.txt | tail +2)"\"}" | \
			jq  > nuwriter/otp_key-spinor.json; \
			$(cat ${NUWRITER_DIR}/pack-spinor.json | \
			jq 'setpath(["image",1,"file"];"enc_bl2-ma35d1-spinor.dtb")' | \
			jq 'setpath(["image",2,"file"];"enc_bl2-ma35d1-spinor.bin")' > nuwriter/pack-spinor.json); \
			nuwriter/nuwriter -p nuwriter/pack-spinor.json; \
			cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-enc-spinor.bin; \
			ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-enc-spinor.bin ${IMAGE_BASENAME}-${MACHINE}-enc-spinor.pack; \
			rm -rf $(date "+%m%d-*");)
		fi
	fi
}

IMAGE_CMD_nand() {
	if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-enc-nand.pack ]; then
		rm ${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-enc-nand.bin -f
		rm ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-enc-nand.pack -f
		rm ${DEPLOY_DIR_IMAGE}/pack-${IMAGE_BASENAME}-${MACHINE}-enc-nand.bin -f
	elif [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-nand.pack ]; then
		rm ${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-nand.bin -f
		rm ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-nand.pack -f
		rm ${DEPLOY_DIR_IMAGE}/pack-${IMAGE_BASENAME}-${MACHINE}-nand.bin -f
	fi

	ENC=""
	FIPDIR=""
    RTP_BIN=${TFA_M4_BIN}
	rm ${DEPLOY_DIR_IMAGE}/fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand -f
	rm ${DEPLOY_DIR_IMAGE}/fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand -f
	if [ "${SECURE_BOOT}" = "yes" ]; then
		FIPDIR="fip/"
		ENC="enc_"
		rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand -f
		rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand -f
		(cd ${DEPLOY_DIR_IMAGE}; mkdir -p ${FIPDIR}; \
		cat ${NUWRITER_DIR}/enc_fip.json | jq -r ".header.secureboot = \"yes\"" | \
		jq -r ".header.aeskey = \"${AES_KEY}\"" | jq -r ".header.ecdsakey = \"${ECDSA_KEY}\"" \
		> ${FIPDIR}enc_fip.json; \
	cp ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/tee-header_v2-optee.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}tee-header_v2-optee.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/tee-pager_v2-optee.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}tee-pager_v2-optee.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/u-boot.bin-nand ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}u-boot.bin-nand; \
	rm -rf $(date "+%m%d-*");)
	if [ "${TFA_LOAD_M4}" = "yes" ]; then
		(cd ${DEPLOY_DIR_IMAGE}; \
		cp ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ${FIPDIR}enc.bin; \
		nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
			cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}rtp_bin; \
		rm -rf $(date "+%m%d-*");)
		RTP_BIN="rtp_bin"
	fi
	rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}enc.bin;
	fi

	# Generate the FIP image  with the bl2.bin and required Device Tree
	if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
	if [ "${TFA_LOAD_M4}" = "no" ]; then
			${DEPLOY_DIR_IMAGE}/fiptool create \
				--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
				--tos-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-header_v2-optee.bin \
				--tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-pager_v2-optee.bin \
				--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-nand \
			${DEPLOY_DIR_IMAGE}/${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand
	else
			if [ -f ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ]; then
				${DEPLOY_DIR_IMAGE}/fiptool create \
					--scp-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}${RTP_BIN} \
					--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
					--tos-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-header_v2-optee.bin \
					--tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-pager_v2-optee.bin \
					--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-nand \
				${DEPLOY_DIR_IMAGE}/${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand
			else
				bberror "Could not found ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN}"
			fi
	fi
		(cd ${DEPLOY_DIR_IMAGE}; ln -sf ${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand fip.bin-nand)
	else
		if [ "${TFA_LOAD_M4}" = "no" ]; then
			${DEPLOY_DIR_IMAGE}/fiptool create \
				--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
				--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-nand \
				${DEPLOY_DIR_IMAGE}/${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand
		else
			if [ -f ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ]; then
				${DEPLOY_DIR_IMAGE}/fiptool create \
					--scp-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}${RTP_BIN} \
					--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
					--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-nand \
					${DEPLOY_DIR_IMAGE}/${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand
			else
				bberror "Could not found ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN}"
			fi
		fi
		(cd ${DEPLOY_DIR_IMAGE}; ln -sf ${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-nand fip.bin-nand)
	fi

   (cd ${DEPLOY_DIR_IMAGE}; ubinize ${UBINIZE_ARGS} -o u-boot-initial-env.ubi-nand u-boot-initial-env-nand-ubi.cfg)

	if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi ]; then
		if [ "${SECURE_BOOT}" = "no" ]; then
			(cd ${DEPLOY_DIR_IMAGE}; \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-nand; \
			cp ${NUWRITER_DIR}/*-nand.json  nuwriter; \
			nuwriter/nuwriter -c nuwriter/header-nand.json; \
			cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-nand.bin; \
			nuwriter/nuwriter -p nuwriter/pack-nand.json; \
			cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-nand.bin; \
			ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-nand.bin ${IMAGE_BASENAME}-${MACHINE}-nand.pack; \
			rm -rf $(date "+%m%d-*");)
			if [ -f ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-nand.dtb ]; then
				rm ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-nand.dtb
				rm ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-nand.bin
			fi
		else
			(cd ${DEPLOY_DIR_IMAGE}; \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ubi rootfs.ubi-nand; \
			$(cat ${NUWRITER_DIR}/header-nand.json | jq -r ".header.secureboot = \"yes\"" | \
			jq -r ".header.aeskey = \"${AES_KEY}\"" | jq -r ".header.ecdsakey = \"${ECDSA_KEY}\"" \
			> nuwriter/header-nand.json); \
			nuwriter/nuwriter -c nuwriter/header-nand.json; \
			cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-enc-nand.bin; \
			cp conv/enc_bl2-ma35d1.dtb enc_bl2-ma35d1-nand.dtb; \
			cp conv/enc_bl2-ma35d1.bin enc_bl2-ma35d1-nand.bin; \
			echo "{\""publicx"\": \""$(head -6 conv/header_key.txt | tail +6)"\", \
			\""publicy"\": \""$(head -7 conv/header_key.txt | tail +7)"\", \
			\""aeskey"\": \""$(head -2 conv/header_key.txt | tail +2)"\"}" | \
			jq  > nuwriter/otp_key-nand.json; \
			$(cat ${NUWRITER_DIR}/pack-nand.json | \
			jq 'setpath(["image",1,"file"];"enc_bl2-ma35d1-nand.dtb")' | \
			jq 'setpath(["image",2,"file"];"enc_bl2-ma35d1-nand.bin")' > nuwriter/pack-nand.json); \
			nuwriter/nuwriter -p nuwriter/pack-nand.json; \
			cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-enc-nand.bin; \
			ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-enc-nand.bin ${IMAGE_BASENAME}-${MACHINE}-enc-nand.pack; \
			rm -rf $(date "+%m%d-*");) \
		fi
	fi
}

SDCARD ?= "${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.sdcard"

# Boot partition size [in KiB]
BOOT_SPACE ?= "32768"

# Set alignment in KiB
IMAGE_ROOTFS_ALIGNMENT ?= "4096"

IMAGE_CMD_sdcard() {
	BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} - 1 )
	if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.pack ]; then
	rm ${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.bin -f
		rm ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.pack -f
		rm ${DEPLOY_DIR_IMAGE}/pack-${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.bin -f
	elif [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-sdcard.pack ]; then
	rm ${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin -f
		rm ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}-${MACHINE}-sdcard.pack -f
		rm ${DEPLOY_DIR_IMAGE}/pack-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin -f
	fi
    
	ENC=""
	FIPDIR=""
	RTP_BIN=${TFA_M4_BIN}
	rm ${DEPLOY_DIR_IMAGE}/fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard -f
	rm ${DEPLOY_DIR_IMAGE}/fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard -f
	if [ "${SECURE_BOOT}" = "yes" ]; then
		FIPDIR="fip/"
		ENC="enc_"
		rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard -f
		rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard -f
		(cd ${DEPLOY_DIR_IMAGE}; mkdir -p ${FIPDIR}; \
		cat ${NUWRITER_DIR}/enc_fip.json | jq -r ".header.secureboot = \"yes\"" | \
		jq -r ".header.aeskey = \"${AES_KEY}\"" | jq -r ".header.ecdsakey = \"${ECDSA_KEY}\"" \
		> ${FIPDIR}/enc_fip.json; \
	cp ${DEPLOY_DIR_IMAGE}/bl31-${TFA_PLATFORM}.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/tee-header_v2-optee.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}tee-header_v2-optee.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/tee-pager_v2-optee.bin ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}tee-pager_v2-optee.bin; \
	rm -rf $(date "+%m%d-*"); \
	cp ${DEPLOY_DIR_IMAGE}/u-boot.bin-sdcard ${FIPDIR}enc.bin; \
	nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
	cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}u-boot.bin-sdcard; \
	rm -rf $(date "+%m%d-*");)
	if [ "${TFA_LOAD_M4}" = "yes" ]; then
		(cd ${DEPLOY_DIR_IMAGE}; \
		cp ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ${FIPDIR}enc.bin; \
		nuwriter/nuwriter -c ${FIPDIR}enc_fip.json>/dev/null; \
			cat conv/enc_enc.bin conv/header.bin >${FIPDIR}${ENC}rtp_bin; \
		rm -rf $(date "+%m%d-*");)
		RTP_BIN="rtp_bin"
	fi
	rm ${DEPLOY_DIR_IMAGE}/${FIPDIR}enc.bin;
	fi

	# Generate the FIP image  with the bl2.bin and required Device Tree
	if ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'true', 'false', d)}; then
		if [ "${TFA_LOAD_M4}" = "no" ]; then
			${DEPLOY_DIR_IMAGE}/fiptool create \
				--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
				--tos-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-header_v2-optee.bin \
				--tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-pager_v2-optee.bin \
				--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-sdcard \
				${DEPLOY_DIR_IMAGE}/${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard
		else
			if [ -f ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ]; then
				${DEPLOY_DIR_IMAGE}/fiptool create \
					--scp-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}${RTP_BIN} \
					--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
					--tos-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-header_v2-optee.bin \
					--tos-fw-extra1 ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}tee-pager_v2-optee.bin \
					--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-sdcard \
					${DEPLOY_DIR_IMAGE}/${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard
			else
				bberror "Could not found ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN}"
			fi
		fi
		(cd ${DEPLOY_DIR_IMAGE}; ln -sf ${ENC}fip_with_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard fip.bin-sdcard)
	else
		if [ "${TFA_LOAD_M4}" = "no" ]; then
			${DEPLOY_DIR_IMAGE}/fiptool create \
				--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
				--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-sdcard \
				${DEPLOY_DIR_IMAGE}/${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard
		else
			if [ -f ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN} ]; then
				${DEPLOY_DIR_IMAGE}/fiptool create \
					--scp-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}${RTP_BIN} \
					--soc-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}bl31-${TFA_PLATFORM}.bin \
					--nt-fw ${DEPLOY_DIR_IMAGE}/${FIPDIR}${ENC}u-boot.bin-sdcard \
					${DEPLOY_DIR_IMAGE}/${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard
			else
				bberror "Could not found ${DEPLOY_DIR_IMAGE}/${TFA_M4_BIN}"
			fi
		fi
		(cd ${DEPLOY_DIR_IMAGE}; ln -sf ${ENC}fip_without_optee-${IMAGE_BASENAME}-${MACHINE}.bin-sdcard fip.bin-sdcard)
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
		if [ "${SECURE_BOOT}" = "no" ]; then
			(cd ${DEPLOY_DIR_IMAGE}; \
			cp ${NUWRITER_DIR}/*-sdcard.json  nuwriter; \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 rootfs.ext4-sdcard; \
			nuwriter/nuwriter -c nuwriter/header-sdcard.json; \
			cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin; \
			$(cat nuwriter/pack-sdcard.json | jq 'setpath(["image",8,"offset"];"'$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)'")' > nuwriter/pack-sdcard-tmp.json); \
			cp nuwriter/pack-sdcard-tmp.json nuwriter/pack-sdcard.json; \
			rm nuwriter/pack-sdcard-tmp.json; \
			nuwriter/nuwriter -p nuwriter/pack-sdcard.json; \
			cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin; \
			ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin ${IMAGE_BASENAME}-${MACHINE}-sdcard.pack; \
			rm -rf $(date "+%m%d-*");)
			if [ -f ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-sdcard.dtb ]; then
				rm ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-sdcard.dtb
				rm ${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-sdcard.bin
			fi
		else
			(cd ${DEPLOY_DIR_IMAGE}; \
			ln -sf ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 rootfs.ext4-sdcard; \
			$(cat ${NUWRITER_DIR}/header-sdcard.json | jq -r ".header.secureboot = \"yes\"" | \
			jq -r ".header.aeskey = \"${AES_KEY}\"" | jq -r ".header.ecdsakey = \"${ECDSA_KEY}\"" \
			> nuwriter/header-sdcard.json); \
			nuwriter/nuwriter -c nuwriter/header-sdcard.json; \
			cp conv/enc_bl2-ma35d1.dtb enc_bl2-ma35d1-sdcard.dtb; \
			cp conv/enc_bl2-ma35d1.bin enc_bl2-ma35d1-sdcard.bin; \
			echo "{\""publicx"\": \""$(head -6 conv/header_key.txt | tail +6)"\", \
			\""publicy"\": \""$(head -7 conv/header_key.txt | tail +7)"\", \
			\""aeskey"\": \""$(head -2 conv/header_key.txt | tail +2)"\"}" | \
			jq  > nuwriter/otp_key-sdcard.json; \
			cp conv/header.bin header-${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.bin; \
			$(cat ${NUWRITER_DIR}/pack-sdcard.json | \
			jq 'setpath(["image",2,"file"];"enc_bl2-ma35d1-sdcard.dtb")' | \
			jq 'setpath(["image",3,"file"];"enc_bl2-ma35d1-sdcard.bin")' | \
			jq 'setpath(["image",8,"offset"];"'$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + \
			${IMAGE_ROOTFS_ALIGNMENT} \* 1024)'")' > nuwriter/pack-sdcard.json); \
			nuwriter/nuwriter -p nuwriter/pack-sdcard.json; \
			cp pack/pack.bin pack-${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.bin; \
			ln -sf pack-${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.bin ${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.pack; \
			rm -rf $(date "+%m%d-*");)
		fi

		if [ "${SECURE_BOOT}" = "no" ]; then
			# 0x400
			dd if=${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-sdcard.bin of=${SDCARD} conv=notrunc seek=2 bs=512
			# 0x20000
			dd if=${DEPLOY_DIR_IMAGE}/bl2-ma35d1.dtb of=${SDCARD} conv=notrunc seek=256 bs=512
			# 0x30000
			dd if=${DEPLOY_DIR_IMAGE}/bl2-ma35d1.bin of=${SDCARD} conv=notrunc seek=384 bs=512
		else
			# 0x400
			dd if=${DEPLOY_DIR_IMAGE}/header-${IMAGE_BASENAME}-${MACHINE}-enc-sdcard.bin of=${SDCARD} conv=notrunc seek=2 bs=512
			# 0x20000
			dd if=${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-sdcard.dtb of=${SDCARD} conv=notrunc seek=256 bs=512
			# 0x30000
			dd if=${DEPLOY_DIR_IMAGE}/enc_bl2-ma35d1-sdcard.bin of=${SDCARD} conv=notrunc seek=384 bs=512
		fi
		# 0x40000
		dd if=${DEPLOY_DIR_IMAGE}/u-boot-initial-env.bin-sdcard of=${SDCARD} conv=notrunc seek=512 bs=512
		# 0xC0000
		dd if=${DEPLOY_DIR_IMAGE}/fip.bin-sdcard of=${SDCARD} conv=notrunc seek=1536 bs=512
		# 0x2c0000
		dd if=${DEPLOY_DIR_IMAGE}/$(basename ${KERNEL_DEVICETREE}) of=${SDCARD} conv=notrunc seek=5632 bs=512
		# 0x300000
		dd if=${DEPLOY_DIR_IMAGE}/Image-${MACHINE}.bin of=${SDCARD} conv=notrunc seek=6144 bs=512
		# root fs
		dd if=${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.ext4 of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${BOOT_SPACE_ALIGNED} \* 1024 + ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
	fi
}

