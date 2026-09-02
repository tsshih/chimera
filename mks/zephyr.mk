VENV := .venv
FW := fw
UPSTREAMS_DIR ?= $(CURDIR)/upstreams
RENODE_PATH := $(firstword $(wildcard $(UPSTREAMS_DIR)/renode*))
ZEPHYR_BASE_REL := third_party/zephyr
ZEPHYR_SDK_DIR ?= $(UPSTREAMS_DIR)/zephyr-sdk-llvm
BOARD ?= renode_riscv32

export ZEPHYR_SDK_INSTALL_DIR := $(ZEPHYR_SDK_DIR)
export ZEPHYR_TOOLCHAIN_VARIANT := zephyr/llvm
export BOARD_ROOT := $(CURDIR)/$(FW)

export PATH := $(CURDIR)/$(VENV)/bin:$(RENODE_PATH):$(PATH)

.PHONY: install/zephyr/requirements
install/zephyr/requirements:
	@ sudo apt update && \
		sudo apt install -y --no-install-recommends \
		git cmake ninja-build gperf ccache dfu-util \
		device-tree-compiler wget python3-dev python3-pip \
		python3-setuptools python3-tk python3-wheel xz-utils file \
		make gcc libsdl2-dev libmagic1


.PHONY: activate/venv
activate/venv:
	@ source $(VENV)/bin/activate


.PHONY: install/zephyr/python/requirements
install/zephyr/python/requirements: activate/venv
	@ pip install west


.PHONY: install/toolchain
install/toolchain:
	@ sudo apt update
	@ sudo apt install -y clang \
		  lld \
		  llvm \
		  device-tree-compiler \
		  ninja-build


.PHONY: install/zephyr/proj
install/zephyr/proj:
	@ mkdir -p $(FW)/.west
	@ printf "[manifest]\npath = .\nfile = west.yml\n\n[zephyr]\nbase = $(ZEPHYR_BASE_REL)\n" > $(FW)/.west/config
	@ cd $(FW) && west update
	@ $(VENV)/bin/pip install -r $(FW)/$(ZEPHYR_BASE_REL)/scripts/requirements-base.txt


.PHONY: install/zephyr/sdk
install/zephyr/sdk:
	@ cd $(FW) && west sdk install -T -l -d $(ZEPHYR_SDK_DIR)


.PHONY: install/zephyr
install/zephyr: install/zephyr/proj install/zephyr/sdk
	@ Install Zephyr done


.PHONY: build/fw
build/fw:
	@ cd $(FW) && west build -p always -b $(BOARD) \
		$(ZEPHYR_BASE_REL)/samples/hello_world

.PHONY: run/renode
run/renode: build/fw
	@ renode --disable-gui --console simulator/renode_riscv32.resc
