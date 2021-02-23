FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#PACKAGECONFIG_GL = " ${@bb.utils.contains('DISTRO_FEATURES', 'opengl', 'gles2', '', d)} "
PACKAGECONFIG_append = " examples directfb tslib "
#QT_CONFIG_FLAGS += " -no-sse2 -no-opengles3 "

