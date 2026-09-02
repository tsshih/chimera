VENV := .venv
FW := fw
ZEPHYR_BASE_REL := third_party/zephyr

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

.PHONY: install/zephyr
install/zephyr:
	@ mkdir -p $(FW)/.west
	@ printf "[manifest]\npath = .\nfile = west.yml\n\n[zephyr]\nbase = $(ZEPHYR_BASE_REL)\n" > $(FW)/.west/config
	@ cd $(FW) && west update
	@ $(VENV)/bin/pip install -r $(FW)/$(ZEPHYR_BASE_REL)/scripts/requirements-base.txt


export ZEPHYR_TOOLCHAIN_VARIANT ?= host
# BOARD ?= qemu_riscv32
BOARD ?= native_sim

.PHONY: build/hello
build/hello:
	@ cd $(FW) && west build -p always -b $(BOARD) $(ZEPHYR_BASE_REL)/samples/hello_world

.PHONY: run/hello
run/hello:
	@ cd $(FW) && west build -t run

.PHONY: build/fw
build/fw:
	@ echo build/fw
