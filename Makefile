BOOT_OUTPUT = ./out/boot/boot.o ./out/boot/boot32.o
BOOT_FILES = ./bin/boot.bin $(BOOT_OUTPUT)
KERNEL_FILES = ./out/kernel.S.o ./out/kernel.o
K_INCLUDES = -I./src
K_FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

#region BOOT FILES BUILD

./out/boot/boot.o: ./src/boot/boot.S
	gcc -c -nostdlib -o ./out/boot/boot.o ./src/boot/boot.S

./out/boot/boot32.o: ./src/boot/boot32.S
	gcc -c -nostdlib -o ./out/boot/boot32.o ./src/boot/boot32.S

./bin/boot.bin: $(BOOT_OUTPUT)
	ld -nostdlib --oformat binary -T ./src/boot/boot.ld -o ./bin/boot.bin $(BOOT_OUTPUT)

#endregion BOOT FILES BUILD

#region KERNEL FILES BUILD

./out/kernel.S.o: ./src/kernel.S
	gcc -c -nostdlib -g -gstabs -o ./out/kernel.S.o ./src/kernel.S

./bin/kernel.bin: $(KERNEL_FILES)
	ld -g -relocatable $(KERNEL_FILES) -o ./out/kernelfull.o
	gcc $(K_FLAGS) -T ./src/linker.ld -o ./bin/kernel.bin ./out/kernelfull.o

./out/kernel.o: ./src/kernel.c
	gcc $(K_INCLUDES) $(K_FLAGS) -std=gnu99 -c ./src/kernel.c -o ./out/kernel.o

#endregion KERNEL FILES BUILD

#region GENERAL ROUTINES

all: ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

run:
	qemu-system-x86_64 -hda ./bin/os.bin

build_run:
	sh ./run-debug.sh

clean:
	rm -rf $(BOOT_FILES) $(KERNEL_FILES) ./bin/os.bin ./out/kernelfull.o ./bin/kernel.bin

#endregion GENERAL ROUTINES
