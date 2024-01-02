SUMMARY = "SDL demo program. You can get source from https://www.parallelrealities.co.uk/downloads/tutorials/sdl2/shooter15.tar.gz"
RDEPENDS_${PN} = "libsdl2 libsdl2-ttf libsdl2-image libsdl2-mixer"
LICENSE = "CLOSED"

SRC_URI += "file://demo.tar.gz"

do_package_qa[noexec] = "1"
do_install() {
    install -d ${D}/${bindir}/
    install -m 0755 ${WORKDIR}/demo/shooter15 ${D}/${bindir}/

    install -D ${WORKDIR}/demo/sdl2demo_gfx/* -t ${D}/${bindir}/sdl2demo_gfx/    
    install -D ${WORKDIR}/demo/sdl2demo_music/* -t ${D}/${bindir}/sdl2demo_music/
    install -D ${WORKDIR}/demo/sdl2demo_sound/* -t ${D}/${bindir}/sdl2demo_sound/
}
