BOOT_OUTPUT = ./out/boot/boot.o ./out/boot/boot32.o
BOOT_FILES = ./bin/boot.bin $(BOOT_OUTPUT)
KERNEL_FILES = ./out/kernel.S.o

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
	gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./out/kernelfull.o

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
