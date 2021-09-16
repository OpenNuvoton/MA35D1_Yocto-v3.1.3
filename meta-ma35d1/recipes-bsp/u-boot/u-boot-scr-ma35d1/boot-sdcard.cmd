echo "Booting from SDCARD ..."
setenv bootargs root=/dev/${mmc_block} rootfstype=ext4 rw rootwait console=ttyS0,115200n8 rdinit=/sbin/init mem=${kernelmem}
mmc dev 0
mmc read ${kernel_addr_r} 0x1800 0x8000
mmc read ${fdt_addr_r} 0x200 0x80
booti ${kernel_addr_r} - ${fdt_addr_r}
