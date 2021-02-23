SUMMARY = "NUC3500 example of image based on QT framework."
LICENSE = "Proprietary"

inherit ${@bb.utils.contains('LAYERDEPENDS', 'qt5-layer', 'populate_sdk_qt5', '', d)}

inherit core-image 

IMAGE_LINGUAS = "en-us"

PACKAGECONFIG_append = " examples accessibility "

# Define to null ROOTFS_MAXSIZE to avoid partition size restriction
IMAGE_ROOTFS_MAXSIZE = ""

#
# Multimedia part addons
#
IMAGE_MM_PART = " tiff "

#
# Display part addons
#
IMAGE_DISPLAY_PART = ""

#
# QT part Essentials
#
IMAGE_QT_MANDATORY_PART = " \
    qtbase                  \
    "

#
# QT part add-ons
#
IMAGE_QT_OPTIONAL_PART = ""

#
# QT part examples
#
IMAGE_QT_EXAMPLES_PART = " \
   qtbase-examples         \
    "

CORE_IMAGE_EXTRA_INSTALL += " \
    \
    \
    ${IMAGE_DISPLAY_PART}       \
    ${IMAGE_MM_PART}            \
    \
    ${IMAGE_QT_MANDATORY_PART}  \
    ${IMAGE_QT_OPTIONAL_PART}   \
    ${IMAGE_QT_EXAMPLES_PART}   \
    "

