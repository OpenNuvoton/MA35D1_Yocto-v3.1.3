DEPENDS += " mtd-utils-native python3-nuwriter-native"

do_deploy[depends] = "virtual/trusted-firmware-a:do_deploy virtual/kernel:do_deploy virtual/bootloader:do_deploy ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'virtual/optee-os:do_deploy', '',d)} python3-nuwriter-native:do_install mtd-utils-native:do_populate_sysroot jq-native:do_populate_sysroot"

python do_deploy() {
    import os
    import glob
    import shutil
    import shlex
    import subprocess
    import json
    from datetime import datetime
    current_directory = os.getcwd()
    machine_features = d.getVar('MACHINE_FEATURES', True)
    nd = d.getVar('NUWRITER_DIR')
    nj = os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), "nuwriter")
    u = ["ubinize"]+shlex.split(d.getVar('UBINIZE_ARGS'))+["-o","u-boot-initial-env.ubi-initramfs","u-boot-initial-env-initramfs-ubi.cfg"]
    def dels(suffix):
        for prefix in ["header-", "", "pack-"]:
            file_path = os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), f"{prefix}{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}{suffix}")
            if os.path.exists(file_path):
                os.remove(file_path)
    def delf(file):
        file_path = os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), f"{file}")
        if os.path.exists(file_path):
            os.remove(file_path)
    def run(par,path):
        cmd = f"nuwriter/nuwriter -{par} {path}"
        subprocess.run(cmd, shell=True, check=True)
    if os.path.exists(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), f"{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-enc-spinand-initramfs.pack")):
        dels("-enc-spinand-initramfs.pack")
    elif os.path.exists(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), f"{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-spinand-initramfs.pack")):
        dels("-spinand-initramfs.pack")
    enc = ""
    fip_dir = ""
    rtp_bin = d.getVar('TFA_SCP_BIN')
    delf("fip_with_optee-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}.bin-spinand")
    delf("fip_without_optee-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}.bin-spinand")
    os.chdir(d.getVar('DEPLOY_DIR_IMAGE'))
    subprocess.run(u,check=True)
    if d.getVar('SECURE_BOOT') == "yes":
        fip_dir = "fip/"
        enc = "enc_"
        os.makedirs(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), fip_dir), exist_ok=True)
        with open(os.path.join(nd, "enc_fip.json"), "r") as infile:
            data = json.load(infile)
        data["header"]["secureboot"] = "yes"
        data["header"]["aeskey"] = d.getVar('AES_KEY')
        data["header"]["ecdsakey"] = d.getVar('ECDSA_KEY')
        with open(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), f"{fip_dir}enc_fip.json"), "w") as outfile:
            json.dump(data, outfile, indent=4)
        for img_name in [f"bl31-{d.getVar('TFA_PLATFORM')}.bin","tee-header_v2-optee.bin","tee-pager_v2-optee.bin","u-boot.bin-spinand"]:
            simg = f"{d.getVar('DEPLOY_DIR_IMAGE')}/{img_name}"
            eimg = os.path.join(fip_dir, "enc.bin")
            shutil.copy(simg, eimg)
            run("c",f"{fip_dir}/enc_fip.json")
            output_path = os.path.join(fip_dir,f"{enc}{img_name}")
            with open(output_path, "wb") as outfile:
                outfile.write(open("conv/enc_enc.bin", "rb").read())
                outfile.write(open("conv/header.bin", "rb").read())
            subprocess.run(f"rm -rf $(date '+%m%d-*')", shell=True, check=True)
        if d.getVar('TFA_LOAD_SCP') == "yes":
            simg = f"{d.getVar('DEPLOY_DIR_IMAGE')}/{d.getVar('TFA_SCP_BIN')}"
            eimg = os.path.join(fip_dir, "enc.bin")
            shutil.copy(simg, eimg)
            run("c", f"{fip_dir}/enc_fip.json")
            output_path = os.path.join(fip_dir, f"{enc}{img_name}.bin")
            with open(output_path, "wb") as outfile:
                outfile.write(open("conv/enc_enc.bin", "rb").read())
                outfile.write(open("conv/header.bin", "rb").read())
        delf("{fipdir}enc.bin")
    if not os.path.exists(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), "Image-initramfs")):
        os.symlink(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),f"Image-initramfs-{d.getVar('MACHINE')}.bin"),os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"Image-initramfs"))
    if "optee" in machine_features:
        if d.getVar('TFA_LOAD_SCP') == "yes":
            fip_command = [f"{d.getVar('DEPLOY_DIR_IMAGE')}/fiptool","create","--scp-fw",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}{d.getVar('TFA_SCP_BIN')}","--soc-fw",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}bl31-{d.getVar('TFA_PLATFORM')}.bin","--tos-fw", f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}tee-header_v2-optee.bin","--tos-fw-extra1",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}tee-pager_v2-optee.bin","--nt-fw",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}u-boot.bin-spinand",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{enc}fip_with_optee-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}.bin-spinand-initramfs"]
            subprocess.run(fip_command, check=True)
        else:
            fip_command = [f"{d.getVar('DEPLOY_DIR_IMAGE')}/fiptool","create","--soc-fw",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}bl31-{d.getVar('TFA_PLATFORM')}.bin","--tos-fw", f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}tee-header_v2-optee.bin","--tos-fw-extra1",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}tee-pager_v2-optee.bin","--nt-fw",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}u-boot.bin-spinand",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{enc}fip_with_optee-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}.bin-spinand-initramfs"]
            subprocess.run(fip_command, check=True)
        if not os.path.exists(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"fip.bin-spinand-initramfs")):
            os.symlink(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), f"{enc}fip_with_optee-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}.bin-spinand-initramfs"),os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"fip.bin-spinand-initramfs"))
    else:
        if d.getVar('TFA_LOAD_SCP') == "yes":
            fip_command = [f"{d.getVar('DEPLOY_DIR_IMAGE')}/fiptool", "create","--scp-fw", f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}{d.getVar('TFA_SCP_BIN')}","--soc-fw",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}bl31-{d.getVar('TFA_PLATFORM')}.bin","--nt-fw", f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}u-boot.bin-spinand",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{enc}fip_without_optee-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}.bin-spinand-initramfs"]
            subprocess.run(fip_command, check=True)
        else:
            fip_command = [f"{d.getVar('DEPLOY_DIR_IMAGE')}/fiptool", "create","--soc-fw", f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}bl31-{d.getVar('TFA_PLATFORM')}.bin","--nt-fw",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{fip_dir}{enc}u-boot.bin-spinand",f"{d.getVar('DEPLOY_DIR_IMAGE')}/{enc}fip_without_optee-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}.bin-spinand-initramfs"]
            subprocess.run(fip_command, check=True)
        if not os.path.exists(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'), "fip.bin-spinand-initramfs")):
            os.symlink(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),f"{enc}fip_without_optee-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}.bin-spinand-initramfs"),os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"fip.bin-spinand-initramfs"))
    if d.getVar('SECURE_BOOT') == "no":
        for file_path in glob.glob(os.path.join(nd, "*-spinand-initramfs.json")):
            shutil.copy(file_path, "nuwriter")
        run("c","nuwriter/header-spinand-initramfs.json")
        shutil.copy(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"conv/header.bin"),os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),f"header-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-spinand-initramfs.bin"))
        run("p","nuwriter/pack-spinand-initramfs.json")
        shutil.copy(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"pack/pack.bin"),os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),f"pack-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-spinand-initramfs.bin"))
        if not os.path.exists(f"{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-spinand-initramfs.pack"):
            os.symlink(f"pack-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-spinand-initramfs.bin",f"{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-spinand-initramfs.pack")
        subprocess.run(f"rm -rf $(date '+%m%d-*')", shell=True, check=True)
        if os.path.exists(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"enc_bl2-ma35d1-spinand.dtb")):
            os.remove(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"enc_bl2-ma35d1-spinand.dtb"))
            os.remove(os.path.join(d.getVar('DEPLOY_DIR_IMAGE'),"enc_bl2-ma35d1-spinand.bin"))
    else:
        with open(os.path.join(nd, "header-spinand-initramfs.json"),"r") as f:
            header_data = json.load(f)
        header_data["header"]["secureboot"] = "yes"
        header_data["header"]["aeskey"] = d.getVar('AES_KEY')
        header_data["header"]["ecdsakey"] = d.getVar('ECDSA_KEY')
        with open("nuwriter/header-spinand-initramfs.json", "w") as f:
            json.dump(header_data,f,indent=4)
        run("c","nuwriter/header-spinand-initramfs.json")
        shutil.copy("conv/header.bin",f"header-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-enc-spinand-initramfs.bin")
        shutil.copy("conv/enc_bl2-ma35d1.dtb","enc_bl2-ma35d1-spinand.dtb")
        shutil.copy("conv/enc_bl2-ma35d1.bin","enc_bl2-ma35d1-spinand.bin")
        with open("conv/header_key.txt", "r") as f:
            header_key_lines=f.readlines()
        otp_key = {"publicx": header_key_lines[5].strip(),"publicy": header_key_lines[6].strip(),"aeskey": header_key_lines[1].strip()}
        with open("nuwriter/otp_key-spinand.json","w") as f:
            json.dump(otp_key,f,indent=4)
        with open(os.path.join(nd, "pack-spinand-initramfs.json"),"r") as f:
            pack_data = json.load(f)
        pack_data["image"][1]["file"]="enc_bl2-ma35d1-spinand.dtb"
        pack_data["image"][2]["file"]="enc_bl2-ma35d1-spinand.bin"
        with open("nuwriter/pack-spinand-initramfs.json", "w") as f:
            json.dump(pack_data,f,indent=4)
        run("p","nuwriter/pack-spinand-initramfs.json")
        shutil.copy("pack/pack.bin", f"pack-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-enc-spinand-initramfs.bin")
        if not os.path.exists(f"{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-enc-spinand-initramfs.pack"):
            os.symlink(f"pack-{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-enc-spinand-initramfs.bin",f"{d.getVar('INITRAMFS_IMAGE')}-{d.getVar('MACHINE')}-enc-spinand-initramfs.pack")
        subprocess.run(f"rm -rf $(date '+%m%d-*')",shell=True, check=True)
    os.chdir(current_directory)
}

addtask do_deploy after do_image_complete
