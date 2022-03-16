export PATH:=$(abspath bin):$(PATH)
EASYFLASH ?= 0
EXOMIZER ?= 0
AUTOMATION ?= 0
DEFAULT_DRIVER ?= 0
DEFAULT_BAUDRATE ?= 2400

EXO_PATH := build/bin/exomizer
EXO_ARGS := sfx sys -q -n -T4 -M256 -Di_perf=2

ifeq ($(EXOMIZER),1)
RUN_PRG = build/ccgmsterm-exo.prg
else
RUN_PRG = build/ccgmsterm.prg
endif

.PHONY: all
all: $(EXO_PATH) build/rs232.lib
	mkdir -p build

	ca65 -g src/ccgmsterm.s -o build/ccgmsterm.o -DEASYFLASH=$(EASYFLASH) -DAUTOMATION=$(AUTOMATION) -DDEFAULT_DRIVER=$(DEFAULT_DRIVER) -DDEFAULT_BAUDRATE=$(DEFAULT_BAUDRATE)

	cl65 -g -C src/ccgmsterm.cfg \
		-o build/ccgmsterm.prg \
		-Ln build/ccgmsterm.sym -m build/ccgmsterm.map \
		build/ccgmsterm.o \
		build/rs232.lib
ifeq ($(EXOMIZER),1)
	$(EXO_PATH) $(EXO_ARGS) -o build/ccgmsterm-exo.prg build/ccgmsterm.prg
endif

$(EXO_PATH):
	[ -d exomizer/src ] || git submodule update --init exomizer
	mkdir -p build/bin
	$(MAKE) -C exomizer/src CFLAGS="-Wall -Wstrict-prototypes -pedantic -O3"
	cp exomizer/src/exomizer build/bin

build/rs232.lib:
	mkdir -p build
	ca65 -g rs232lib/rs232.s -o build/rs232.o
	ca65 -g rs232lib/rs232_userport.s -o build/rs232_userport.o
	ca65 -g rs232lib/rs232_up9600.s -o build/rs232_up9600.o
	ca65 -g rs232lib/rs232_swiftlink.s -o build/rs232_swiftlink.o
	ar65 a build/rs232.lib build/rs232.o build/rs232_userport.o build/rs232_up9600.o build/rs232_swiftlink.o

build/disk.d64:
	c1541 -format ccgms,fu d64 build/disk.d64

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

.PHONY: testup
testup:
	(cd test; ./xfer.sh 2>&1 | grep TEST_XFER) &
	AUTOMATION=1 make clean all runup

.PHONY: testsw
testsw:
	(cd test; ./xfer.sh 2>&1 | grep TEST_XFER) &
	AUTOMATION=1 DEFAULT_DRIVER=2 DEFAULT_BAUDRATE=9600 make clean all runsw

.PHONY: clean
clean:
	rm -rf build
