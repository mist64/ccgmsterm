#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

extern int xmodemTransmit(unsigned char *src, int srcsz, int use_1k);
extern int xmodemReceive(unsigned char *dest, int destsz, int crc);

FILE *f;

int
_inbyte(unsigned short timeout) {
	int c = fgetc(stdin);
	fprintf(stderr, "***** SERVER: <--- %02X\n", (unsigned char)c);
	return c;
}

void
_outbyte(int c) {
	fprintf(stderr, "***** SERVER: ---> %02X\n", (unsigned char)c);
	fputc(c, stdout);
	fflush(stdout);
}


void
announce(char *s) {
	sleep(4);
	printf("\r\n%s\r\n", s);
	fflush(stdout);
}

int
main(int argc, char **argv) {
	while (!feof(stdin)) {
		int c = _inbyte(0);

		_outbyte(c);
	}
}
