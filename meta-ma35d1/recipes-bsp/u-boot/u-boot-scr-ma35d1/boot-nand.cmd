echo "Booting from NAND ..."
setenv bootargs noinitrd ubi.mtd=${nand_ubiblock} root=ubi0:rootfs rootfstype=ubifs rw rootwait=1 console=ttyS0,115200n8 rdinit=/sbin/init mem=${kernelmem}
nand read ${kernel_addr_r} kernel
nand read ${fdt_addr_r} device-tree
booti ${kernel_addr_r} - ${fdt_addr_r}
