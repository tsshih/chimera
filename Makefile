RENODE_VERSION := latest

UPSTREAMS_DIR := $(CURDIR)/upstreams
TOOLCHAIN_PATH := $(UPSTREAMS_DIR)/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi/bin
RENODE_PATH := $(firstword $(wildcard $(UPSTREAMS_DIR)/renode*))

export PATH := $(TOOLCHAIN_PATH):$(RENODE_PATH):$(PATH)

include mks/zephyr.mk

.PHONY: download/renode
download/renode:
	@ mkdir -p $(UPSTREAMS_DIR)
	@ wget https://builds.renode.io/renode-$(RENODE_VERSION).linux-portable.tar.gz -O $(UPSTREAMS_DIR)/renode-$(RENODE_VERSION).linux-portable.tar.gz


.PHONY: install/renode
install/renode: download/renode
	@ tar -zxvf $(UPSTREAMS_DIR)/renode-$(RENODE_VERSION).linux-portable.tar.gz -C $(UPSTREAMS_DIR)
	@ rm $(UPSTREAMS_DIR)/renode-$(RENODE_VERSION).linux-portable.tar.gz


.PHONY: clean
clean:
	@ rm -rf build

.PHONY: renode/start
renode/start:
	@ renode --disable-gui --console simulator/riscv.resc
