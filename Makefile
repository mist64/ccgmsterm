EASYFLASH ?= 0

all:
	mkdir -p build
	ca65 -g src/ccgmsterm.s -o build/ccgmsterm.o -DEASYFLASH=$(EASYFLASH)
	cl65 -g -C src/ccgmsterm.cfg build/ccgmsterm.o -o build/ccgmsterm.prg -Ln build/ccgmsterm.sym -m build/ccgmsterm.map

# use this to *quickly* compare the binary with the original "2021" release binary
md5:
	@which md5 > /dev/null && md5 -r build/ccgmsterm.prg || true
	@which md5sum > /dev/null && md5sum build/ccgmsterm.prg || true

# use this to compare the binary with the original "2021" release binary
compare: all
	dd if=/dev/zero of=/tmp/0801.bin bs=1 count=2049 2> /dev/null
	cat /tmp/0801.bin ccgms_2021_orig.prg > /tmp/1.bin
	cat /tmp/0801.bin build/ccgmsterm.prg > /tmp/2.bin
	hexdump -C /tmp/1.bin > /tmp/1
	hexdump -C /tmp/2.bin > /tmp/2
	diff -u /tmp/[12]

clean:
	rm -rf build
