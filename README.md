# Using repo to download source

repo init -u git://github.com/OpenNuvoton/MA35D1_yocto-3.1.3.git -m  meta-ma35d1/base/ma35d1.xml
repo sync

# Build yocto
DISTRO=nvt-ma35d1 MACHINE=ma35d1-evb source  sources/init-build-env build

###### Usage:
	MACHINE=<machine> DISTRO=<distro> source sources/init-build-env <build-dir>
	<machine>    machine name
	<distro>     distro name
	<build-dir>  build directory

# Step by step to build yocto
To build and use the yocto, do the following:
```
$ repo init -u git://github.com/OpenNuvoton/MA35D1_yocto-3.1.3.git -m meta-ma35d1/base/ma35d1.xml
$ repo sync
$ DISTRO=nvt-ma35d1 MACHINE=ma35d1-evb source  sources/init-build-env build
$ bitbake core-image-minimal
```
