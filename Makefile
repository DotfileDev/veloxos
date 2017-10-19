# Getting project root path may be a little bit overcomplicated.
PROJECT_DIR				:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUILD_DIR				?= $(PROJECT_DIR)/build

ASM						:= nasm
CXX						:= x86_64-elf-g++

ASM_FLAGS				:= -f elf64
CXX_FLAGS				:= -std=c++17 -O2 -g0 -Wall -Wextra -Wpedantic -Werror -masm=intel
CXX_FLAGS				+= -ffreestanding
CXX_FLAGS				+= -nostartfiles -nostdlib -nostdinc -nostdinc++

IMAGE_NAME				?= veloxos.bin
FILES_TO_IMG 			:= $(BUILD_DIR)/bootloader.o

include bootloader/Makefile

.PHONY: all bootloader bochs qemu

all: bootloader
	@echo Writing:'  '$(IMAGE_NAME)
	@cat $(FILES_TO_IMG) > $(BUILD_DIR)/$(IMAGE_NAME)

bochs:
	@bochs -f $(PROJECT_DIR)/bochsrc
	
qemu:
	@qemu-system-x86_64 -drive format=raw,file=$(BUILD_DIR)/veloxos.bin

hexdump-bootloader:
	@hexdump -C $(BUILD_DIR)/bootloader.o

hexdump-image:
	@hexdump -C $(BUILD_DIR)/$(IMAGE_NAME)
