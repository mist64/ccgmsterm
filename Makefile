EASYFLASH ?= 0

all:
	mkdir -p build
	ca65 -g src/ccgmsterm.s -o build/ccgmsterm.o -DEASYFLASH=$(EASYFLASH)
	cl65 -g -C src/ccgmsterm.cfg build/ccgmsterm.o -o build/ccgmsterm.prg -Ln build/ccgmsterm.sym -m build/ccgmsterm.map

clean:
	rm -rf build
