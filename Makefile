all:
	ca65 -g ccgmsterm.s
	cl65 -g -C ccgmsterm.cfg ccgmsterm.o -o ccgmsterm.prg -Ln ccgmsterm.sym -m ccgmsterm.map
	@which md5 > /dev/null && md5 -r ccgmsterm.prg || true
	@which md5sum > /dev/null && md5sum ccgmsterm.prg || true

	@#dd if=/dev/zero of=/tmp/0801.bin bs=1 count=2049 2> /dev/null
	@#cat /tmp/0801.bin ccgms_2021_orig.prg > /tmp/1.bin
	@#cat /tmp/0801.bin ccgmsterm.prg > /tmp/2.bin
	@#hexdump -C /tmp/1.bin > /tmp/1
	@#hexdump -C /tmp/2.bin > /tmp/2
	@#diff -u /tmp/[12]

clean:
	rm -f *.o *.map *.sym *.prg
