BOOTLOADER_ASM_FLAGS	:= -f bin -I $(PROJECT_DIR)/bootloader/source/

bootloader:
	@echo Building: bootloader.o
	@$(ASM) $(BOOTLOADER_ASM_FLAGS) $(PROJECT_DIR)/bootloader/source/bootloader.asm -o $(BUILD_DIR)/bootloader.o
