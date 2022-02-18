#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "inout.h"

extern int xmodemTransmit(unsigned char *src, int srcsz, int use_1k);
extern int xmodemReceive(unsigned char *dest, int destsz, int crc);

FILE *f;

void
announce(char *s) {
	sleep(4);
	printf("\r\n%s\r\n", s);
	fflush(stdout);
}

int
main(int argc, char **argv) {
	char *fn_in = "crc16.h"; // just under 2 KB

	f = fopen(fn_in, "rb");
	fseek(f, 0L, SEEK_END);
	long size_in = ftell(f);
	rewind(f);
	unsigned char *data_in = malloc(size_in);
	fread(data_in, 1, size_in, f);
	fclose(f);
	int capacity = size_in * 2;

	unsigned char *data_out1 = malloc(capacity);
	unsigned char *data_out2 = malloc(capacity);

	// 512B DOWNLOAD
	announce("512b\r\n* select \x12 f3 download \x92\r\n* filename: 'a', type p");
	xmodemTransmit(data_in, size_in, 0);

	// 1KB DOWNLOAD
	announce("1kb\r\n* select \x12 f3 download \x92\r\n* filename: 'b', type p");
	xmodemTransmit(data_in, size_in, 1);

	// CHKSUM UPLOAD
	announce("chksum\r\n* select \x12 f1 upload \x92\r\n* filename: 'a'");
	sleep(5);
	int size_out1 = xmodemReceive(data_out1, capacity, 0);

	// CRC16 UPLOAD
	announce("crc16\r\n* select \x12 f1 upload \x92\r\n* filename: 'b'");
	sleep(5);
	int size_out2 = xmodemReceive(data_out2, capacity, 0);

	// compare input and output
	if (!memcmp(data_in, data_out2, size_in)) {
		fprintf(stderr, "***** SERVER: PART1 OK\n");
		announce("PART1 OK\n");
	} else {
		fprintf(stderr, "***** SERVER: PART1 BAD\n");
		announce("PART1 BAD\n");
	}
	if (!memcmp(data_in, data_out2, size_in)) {
		fprintf(stderr, "***** SERVER: PART2 OK\n");
		announce("PART2 OK\n");
	} else {
		fprintf(stderr, "***** SERVER: PART2 BAD\n");
		announce("PART2 BAD\n");
	}

//	f = fopen(fn, "wb");
//	fwrite(buf, 1, size, f);
//	fclose(f);
}
