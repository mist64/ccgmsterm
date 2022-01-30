all:
	ca65 -g ccgms.s
	cl65 -g -C ccgms.cfg ccgms.o -o ccgms.prg -Ln ccgms.sym

usb: all
	cp ccgms.prg /Volumes/C64; diskutil eject /Volumes/C64
