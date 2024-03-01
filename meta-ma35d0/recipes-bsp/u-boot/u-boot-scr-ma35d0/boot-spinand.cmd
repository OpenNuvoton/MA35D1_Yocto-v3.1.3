echo "Booting from SPINAND ..."
mtd list
setenv bootargs noinitrd ubi.mtd=${spinand_ubiblock} root=ubi0:rootfs rootfstype=ubifs rw rootwait=1 console=ttyS0,115200n8 rdinit=/sbin/init mem=${kernelmem}
mtd read kernel ${kernel_addr_r}
mtd read device-tree ${fdt_addr_r}
booti ${kernel_addr_r} - ${fdt_addr_r}

