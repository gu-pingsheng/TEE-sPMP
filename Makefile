# below homes is submodules of this repo
export SBI_HOME=$(shell pwd)/opensbi
# export LINUX_HOME=$(shell pwd)/riscv-linux
export LINUX_HOME=$(shell pwd)/debian-linux-kernel
export RISCV_ROOTFS_HOME=$(shell pwd)/riscv-rootfs
export NEMU_HOME=$(shell pwd)/NEMU

# sub-directories of the submodules
DTS_HOME=$(SBI_HOME)/dts
DTS_NAME=system.dts
FW_FDT_PATH=$(DTS_HOME)/xiangshan.dtb
IMG=$(SBI_HOME)/build/platform/generic/firmware/fw_payload.bin
PLATFORM=generic
FW_PAYLOAD_PATH=$(LINUX_HOME)/vmlinux.bin
# FW_PAYLOAD_PATH=

# LINUX_CONFIG
# LINUX_CONFIG=fpga_defconfig
LINUX_CONFIG=nanhu_fpga_defconfig
LINUX_INIT_CONFIG=init_defconfig

# arch and cross compile infomation
export ARCH=riscv
export ISA=riscv64
export CROSS_COMPILE=riscv64-unknown-linux-gnu-
export CROSS_COMPILE_OBJCOPY=$(CROSS_COMPILE)objcopy
export RISCV=/nfs/home/share/riscv/

# NEMU settings
NEMU_BINARY=$(NEMU_HOME)/build/riscv64-nemu-interpreter

.PHONY: init linux opensbi all clean

all: opensbi
	@echo "make linux with Penglai-TEE success"	

opensbi: linux dts 
	$(MAKE) -C $(SBI_HOME) PLATFORM=$(PLATFORM) CROSS_COMPILE=$(CROSS_COMPILE) FW_FDT_PATH=$(FW_FDT_PATH) FW_PAYLOAD_PATH=$(FW_PAYLOAD_PATH)

linux:
	$(MAKE) -C $(LINUX_HOME) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(LINUX_CONFIG) 
	RISCV_ROOTFS_HOME=$(RISCV_ROOTFS_HOME) $(MAKE) -C $(LINUX_HOME) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) vmlinux
	cd $(LINUX_HOME); $(CROSS_COMPILE_OBJCOPY) -O binary vmlinux vmlinux.bin
	
dts:
	cd $(SBI_HOME)/dts; dtc -O dtb -o xiangshan.dtb $(DTS_NAME)

init: 
	git submodule update --init --recursive
	cd NEMU; make riscv64-tee_defconfig; make -j8
	$(MAKE) -C $(RISCV_ROOTFS_HOME)/apps/busybox
	$(MAKE) -C $(LINUX_HOME) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) ${LINUX_INIT_CONFIG} 
	RISCV_ROOTFS_HOME=$(RISCV_ROOTFS_HOME) $(MAKE) -C $(LINUX_HOME) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) vmlinux
	$(MAKE) -C $(RISCV_ROOTFS_HOME)/apps/penglai-sdk
	$(MAKE) -C $(RISCV_ROOTFS_HOME)/apps/penglai-driver
	$(MAKE) -C $(LINUX_HOME) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) ${LINUX_CONFIG} 
	$(MAKE) -C $(LINUX_HOME) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) vmlinux
	@echo "initialization success"

penglai-sdk:
	$(MAKE) -C $(RISCV_ROOTFS_HOME)/apps/penglai-sdk
	$(MAKE) -C $(RISCV_ROOTFS_HOME)/apps/penglai-driver
	
run:
	$(NEMU_BINARY) $(IMG) 

nemu:
	$(MAKE) -C $(NEMU_HOME) -j32

nemu-pmptable:
	$(MAKE) -C $(NEMU_HOME) riscv64-tee-pmptable_defconfig
	$(MAKE) -C $(NEMU_HOME) -j32

nemu-menu:
	$(MAKE) -C $(NEMU_HOME) menuconfig

nemu-clean:
	$(MAKE) -C $(NEMU_HOME) clean

	$(MAKE) -C $(SBI_HOME) clean
	$(MAKE) -C $(LINUX_HOME) clean

