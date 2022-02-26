export PATH:=$(abspath bin):$(PATH)
EASYFLASH ?= 0
EXOMIZER ?= 0

ifeq ($(EXOMIZER),1)
	EXO_PATH := build/bin/exomizer
	EXO_ARGS := sfx sys -q -n -T4 -M256 -Di_perf=2
else
	EXO_PATH :=
endif

ifeq ($(EASYFLASH),0)
LABEL = ccgms
else
LABEL = ccgms-ezflash
endif

.PHONY: all
all: $(EXO_PATH)
	mkdir -p build
	ca65 -g src/ccgmsterm.s -o build/ccgmsterm.o -DEASYFLASH=$(EASYFLASH)
	cl65 -g -C src/ccgmsterm.cfg build/ccgmsterm.o -o build/ccgmsterm.prg -Ln build/ccgmsterm.sym -m build/ccgmsterm.map
ifeq ($(EXOMIZER),1)
	$(EXO_PATH) $(EXO_ARGS) -o build/ccgmsterm-exo.prg build/ccgmsterm.prg
	c1541 -format $(LABEL),fu d64 build/disk.d64 -write build/ccgmsterm-exo.prg ccgms
else
	c1541 -format $(LABEL),fu d64 build/disk.d64 -write build/ccgmsterm.prg ccgms
endif

$(EXO_PATH):
	[ -d exomizer/src ] || git submodule update --init exomizer
	mkdir -p build/bin
	$(MAKE) -C exomizer/src CFLAGS="-Wall -Wstrict-prototypes -pedantic -O3"
	cp exomizer/src/exomizer build/bin

.PHONY: run
run: all
	x64sc +cart -acia1 -acia1base 0xDE00 -acia1irq 1 -acia1mode 1 -myaciadev 0 -rsdev1 localhost:25232 -rsdev1baud 9600 build/disk.d64

.PHONY: usb
usb: all
	cp build/ccgmsterm.prg /Volumes/C64/; diskutil unmountDisk force /Volumes/C64

.PHONY: clean
clean:
	rm -rf build
