all:
	ca65 -g ccgms.s
	cl65 -g -C ccgms.cfg ccgms.o -o ccgms.prg -Ln ccgms.sym -m ccgs.map
	dd if=/dev/zero of=/tmp/0801.bin bs=1 count=2049 2> /dev/null
	cat /tmp/0801.bin ccgms_2021_orig.prg > /tmp/1.bin
	cat /tmp/0801.bin ccgms.prg > /tmp/2.bin
	hexdump -C /tmp/1.bin > /tmp/1
	hexdump -C /tmp/2.bin > /tmp/2
	ksdiff /tmp/[12]

usb: all
	cp ccgms.prg /Volumes/C64; diskutil eject /Volumes/C64
