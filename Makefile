EASYFLASH ?= 0

all:
	mkdir -p build
	ca65 -g src/ccgmsterm.s -o build/ccgmsterm.o -DEASYFLASH=$(EASYFLASH)
	cl65 -g -C src/ccgmsterm.cfg build/ccgmsterm.o -o build/ccgmsterm.prg -Ln build/ccgmsterm.sym -m build/ccgmsterm.map


run: all
	c1541 -format ccgms,fu d64 build/disk.d64 -write build/ccgmsterm.prg
	x64sc +cart -acia1 -acia1base 0xDE00 -acia1irq 1 -acia1mode 1 -myaciadev 0 -rsdev1 localhost:25232 -rsdev1baud 9600 build/disk.d64

usb: all
	cp build/ccgmsterm.prg /Volumes/C64/ && diskutil unmountDisk force /Volumes/C64

clean:
	rm -rf build
