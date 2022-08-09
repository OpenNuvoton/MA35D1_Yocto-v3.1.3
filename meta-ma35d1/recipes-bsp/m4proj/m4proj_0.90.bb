
DESCRIPTION = "ma35d1 M4 BSP suppporting ma35d1 ev boards."
DEPENDS = " gcc-arm-none-eabi-native nu-eclipse-native "

inherit deploy

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://Library/CMSIS/CMSIS_END_USER_LICENCE_AGREEMENT.pdf;md5=2cd7232123b57896151a579127c8b51b"

SRCREV= "master"

SRC_URI = "git://github.com/OpenNuvoton/MA35D1_RTP_BSP.git;protocol=https;branch=master"

PV = "M4-BSP"
S = "${WORKDIR}/git"
B =  "${WORKDIR}/build"

export CROSS_COMPILE = "${RECIPE_SYSROOT_NATIVE}/${datadir}/gcc-arm-none-eabi/bin/arm-none-eabi-"
export GCC_PATH = "${RECIPE_SYSROOT_NATIVE}/${datadir}/gcc-arm-none-eabi/bin"
export NUECLIPSE = "${RECIPE_SYSROOT_NATIVE}/${datadir}/nu-eclipse"
export DISPLAY= ":99"

python do_compile() {
    import os
    import subprocess
    import shutil
    import fnmatch
    os.environ["PATH"] += os.pathsep + d.getVar('GCC_PATH',1)
    f = open('gcc_log.txt', "w+")
    root = os.getcwd()
    os.chdir(d.getVar('S',1))
    f.write("PATH="+os.environ["PATH"]+"\n")
    f.write("S="+d.getVar('S',1)+"\n")
    f.write("NUECLIPSE="+d.getVar('NUECLIPSE',1))
    f.write("\n======= m480-bsp =======\n")
    for dirPath, dirNames, fileNames in os.walk("SampleCode"):
        for file in fnmatch.filter(fileNames, '*.cproject'):
            if not os.path.isdir(dirPath+"/Release"):
                f.write("dirPath="+dirPath+"\n")
                if not os.path.isdir("Temp"):
                    os.mkdir("Temp")
                else:
                    shutil.rmtree("Temp")
                    os.mkdir("Temp")
                cmd = d.getVar('NUECLIPSE',1)+"/eclipse/eclipse -nosplash --launcher.suppressErrors -application org.eclipse.cdt.managedbuilder.core.headlessbuild -data Temp -cleanBuild all -import "+dirPath + "\n"
                f.write("cmd="+cmd+"\n")
                f.flush()
                retcode = subprocess.call(cmd,shell=True,stdout=f)
                shutil.rmtree("Temp")
    os.chdir(root)
    f.close()
}

python do_install() {
    import os
    import subprocess
    import shutil
    import fnmatch

    f = open('install_log.txt', "w+")
    root = os.getcwd()
    os.chdir(d.getVar('S',1))

    subprocess.call("mkdir -p " + d.getVar('D',1) + d.getVar('exec_prefix',1)+ "/m4proj",shell=True,stdout=f)
    f.write("S="+d.getVar('S',1)+"\n")
    f.write("NUECLIPSE="+d.getVar('NUECLIPSE',1)+"\n")
    #f.write("PDK_INSTALL_DIR_RECIPE="+d.getVar('PDK_INSTALL_DIR_RECIPE',1)+"\n")
    f.write("======= m480-bsp =======\n")
    for dirPath, dirNames, fileNames in os.walk("SampleCode"):
        for file in fnmatch.filter(fileNames, '*.elf'):
            cmd = "cp "+ dirPath + "/" + file +" "+ d.getVar('D',1) + d.getVar('exec_prefix',1) + "/m4proj"
            f.write("cmd="+cmd+"\n")
            subprocess.call(cmd,shell=True,stdout=f)

    for file in os.listdir(d.getVar('D',1) + d.getVar('exec_prefix',1) + "/m4proj"):
        if fnmatch.fnmatch(file, '*.elf'):
            cmdx = d.getVar('GCC_PATH',1) + "/arm-none-eabi-objcopy -O binary " + d.getVar('D',1) + d.getVar('exec_prefix',1) + "/m4proj/"+ file + " " + d.getVar('D',1) + d.getVar('exec_prefix',1) + "/m4proj/" + os.path.basename(file).split('.')[0] + ".bin"
            f.write("cmdx="+cmdx+"\n")
            subprocess.call(cmdx,shell=True,stdout=f)
    subprocess.call("chmod 644 " + d.getVar('D',1) + d.getVar('exec_prefix',1)+ "/m4proj/*",shell=True,stdout=f)
    os.chdir(root)
    f.close()
}

do_deploy() {
    install -d ${DEPLOYDIR}/${BOOT_TOOLS}/m4proj
    cp -rf ${D}/${exec_prefix}/m4proj/* ${DEPLOYDIR}/${BOOT_TOOLS}/m4proj/
}

INSANE_SKIP_${PN} = "arch"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
FILES_${PN} += "${exec_prefix}/m4proj/*"
PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(ma35d1)"
addtask deploy after do_install

