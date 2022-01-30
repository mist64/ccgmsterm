all:
	ca65 -g ccgms.s
	cl65 -g -C ccgms.cfg ccgms.o -o ccgms.prg -Ln ccgms.sym -m ccgs.map
	hexdump -C ccgms.prg > /tmp/2; hexdump -C ccgms_2021_orig.prg > /tmp/1; ksdiff /tmp/[12]

usb: all
	cp ccgms.prg /Volumes/C64; diskutil eject /Volumes/C64
