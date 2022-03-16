#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "inout.h"

extern int xmodemTransmit(unsigned char *src, int srcsz, int use_1k);
extern int xmodemReceive(unsigned char *dest, int destsz, int crc);
extern int punter_xmit(void *data, int len);
extern int punter_recv(void);

unsigned char *data_out_punter;
int data_out_punter_index;
// PUNTER callback
int xfer_save_data(unsigned char *data, int length) {
	memcpy(data_out_punter + data_out_punter_index, data, length);
	data_out_punter_index += length;
	return length;
}


FILE *f;

void
announce(char *s) {
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

	data_out_punter = malloc(capacity);
	unsigned char *data_out1 = malloc(capacity);
	unsigned char *data_out2 = malloc(capacity);

	sleep(4);

  // PUNTER DOWNLOAD
	announce("punter\r\n* select \x12 f3 download \x92\r\n* filename: 'a'");
	sleep(5);
	punter_xmit(data_in, size_in);

	sleep(5);

	// PUNTER UPLOAD
	announce("punter\r\n* select \x12 f1 upload \x92\r\n* filename: 'a'");
	data_out_punter_index = 0;
	punter_recv();

	sleep(5);

	if (!memcmp(data_in, data_out_punter, size_in) && data_out_punter_index == size_in) {
		fprintf(stderr, "***** SERVER: PUNTER OK\n");
		announce("punter ok\n");
	} else {
		fprintf(stderr, "***** SERVER: PUNTER BAD\n");
		announce("punter bad\n");
	}

	announce("now switch to xmodem:\r\n\x12 f7 \x92 \x12 p \x92 \x12 return \r\nthen:");

	// XMODEM 512B DOWNLOAD
	announce("xmodem 512b\r\n* select \x12 f3 download \x92\r\n* filename: 'a', type p");
	xmodemTransmit(data_in, size_in, 0);

	sleep(4);

	// XMODEM 1KB DOWNLOAD
	announce("xmodem 1kb\r\n* select \x12 f3 download \x92\r\n* filename: 'b', type p");
	xmodemTransmit(data_in, size_in, 1);

	sleep(4);

	// XMODEM CHKSUM UPLOAD
	announce("xmodem chksum\r\n* select \x12 f1 upload \x92\r\n* filename: 'a'");
	sleep(5);
	int size_out1 = xmodemReceive(data_out1, capacity, 0);

	sleep(4);

	// XMODEM CRC16 UPLOAD
	announce("xmodem crc16\r\n* select \x12 f1 upload \x92\r\n* filename: 'b'");
	sleep(5);
	int size_out2 = xmodemReceive(data_out2, capacity, 0);

	// compare input and output
	if (!memcmp(data_in, data_out2, size_in)) {
		fprintf(stderr, "***** SERVER: XMODEM PART1 OK\n");
		announce("xmodem part1 ok\n");
	} else {
		fprintf(stderr, "***** SERVER: XMODEM PART1 BAD\n");
		announce("xmodem part1 bad\n");
	}
	if (!memcmp(data_in, data_out2, size_in)) {
		fprintf(stderr, "***** SERVER: XMODEM PART2 OK\n");
		announce("xmodem part2 ok\n");
	} else {
		fprintf(stderr, "***** SERVER: XMODEM PART2 BAD\n");
		announce("xmodem part2 bad\n");
	}
}

//	fprintf(stderr, "***** SERVER: data_out_punter_index %d\n", data_out_punter_index);
//	f = fopen("/tmp/xxx", "wb");
//	fwrite(data_out_punter, 1, data_out_punter_index, f);
//	fclose(f);
