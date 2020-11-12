# Using repo to download source

repo init -u git://github.com/NUA3500/yocto-3.1.3.git -m  meta-nua3500/base/nua3500.xml

repo sync

# Build yocto

DISTRO=nvt-nua3500-fb MACHINE=nua3500-evb source  sources/init-build-env build

###### Usage:
	MACHINE=<machine> DISTRO=<distro> source sources/init-build-env <build-dir>
	<machine>    machine name
	<distro>     distro name
	<build-dir>  build directory

# Step by step to build yocto
To build and use the yocto, do the following:
```
$ repo init -u git://github.com/NUA3500/yocto-3.1.3.git -m meta-nua3500/base/nua3500.xml
$ repo sync
$ DISTRO=nvt-nua3500-fb MACHINE=nua3500-evb source  sources/init-build-env build
$ bitbake core-image-minimal
```
