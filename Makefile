export PATH:=$(abspath bin):$(PATH)
EASYFLASH ?= 0
EXOMIZER ?= 0

EXO_PATH := build/bin/exomizer
EXO_ARGS := sfx sys -q -n -T4 -M256 -Di_perf=2

ifeq ($(EXOMIZER),1)
RUN_PRG = build/ccgmsterm-exo.prg
else
RUN_PRG = build/ccgmsterm.prg
endif

.PHONY: all
all: $(EXO_PATH)
	mkdir -p build
	ca65 -g src/ccgmsterm.s -o build/ccgmsterm.o -DEASYFLASH=$(EASYFLASH)
	cl65 -g -C src/ccgmsterm.cfg build/ccgmsterm.o -o build/ccgmsterm.prg -Ln build/ccgmsterm.sym -m build/ccgmsterm.map
ifeq ($(EXOMIZER),1)
	$(EXO_PATH) $(EXO_ARGS) -o build/ccgmsterm-exo.prg build/ccgmsterm.prg
endif

$(EXO_PATH):
	[ -d exomizer/src ] || git submodule update --init exomizer
	mkdir -p build/bin
	$(MAKE) -C exomizer/src CFLAGS="-Wall -Wstrict-prototypes -pedantic -O3"
	cp exomizer/src/exomizer build/bin

build/disk.d64:
	c1541 -format ccgms,fu d64 build/disk.d64 -write test/crc16.h a

# run with User Port interface
.PHONY: runup
runup: all build/disk.d64
	x64sc -silent -autostartprgmode 1 +cart +rsuserup9600 -userportdevice 2 -rsuserdev 0 -rsuserbaud 2400 -rsdev1 localhost:25232 -rsdev1baud 2400 -8 build/disk.d64 build/ccgmsterm.prg

# run with UP9600 interface
.PHONY: runup9600
runup9600: all build/disk.d64
	x64sc -silent -autostartprgmode 1 +cart -rsuserup9600 -userportdevice 2 -rsuserdev 0 -rsuserbaud 9600 -rsdev1 localhost:25232 -rsdev1baud 9600 -8 build/disk.d64 build/ccgmsterm.prg

# run with SwiftLink/DE interface
.PHONY: runsw
runsw: all build/disk.d64
	x64sc -silent -autostartprgmode 1 +cart -acia1 -acia1base 0xDE00 -acia1irq 1 -acia1mode 1 -myaciadev 0 -rsdev1 localhost:25232 -rsdev1baud 9600 -8 build/disk.d64 $(RUN_PRG)

.PHONY: usb
usb: all
	cp build/ccgmsterm.prg /Volumes/C64/; diskutil unmountDisk force /Volumes/C64

.PHONY: clean
clean:
	rm -rf build
