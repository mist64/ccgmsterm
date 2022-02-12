EASYFLASH ?= 0

all:
	mkdir -p build
	ca65 -g src/ccgmsterm.s -o build/ccgmsterm.o -DEASYFLASH=$(EASYFLASH)
	cl65 -g -C src/ccgmsterm.cfg build/ccgmsterm.o -o build/ccgmsterm.prg -Ln build/ccgmsterm.sym -m build/ccgmsterm.map

# use this to compare the binary with the original "2021" release binary
compare:
	mkdir -p build
	ca65 -g src/ccgmsterm.s -o build/ccgmsterm_2021.o -DBIN_2021 -DEASYFLASH=0
	cl65 -g -C src/ccgmsterm.cfg build/ccgmsterm_2021.o -o build/ccgmsterm_2021.prg -Ln build/ccgmsterm_2021.sym -m build/ccgmsterm_2021.map

	dd if=/dev/zero of=/tmp/0801.bin bs=1 count=2049 2> /dev/null
	cat /tmp/0801.bin ccgms_2021_orig.prg > /tmp/1.bin
	cat /tmp/0801.bin build/ccgmsterm_2021.prg > /tmp/2.bin
	hexdump -C /tmp/1.bin > /tmp/1
	hexdump -C /tmp/2.bin > /tmp/2
	diff -u /tmp/[12]

clean:
	rm -rf build
