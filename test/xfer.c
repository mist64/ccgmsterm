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
automate(char *s) {
	printf("\x03%s\x03", s);
	fflush(stdout);
}

char *
config_str(int i) {
	switch (i) {
		case 0: return "XMODEM";
		case 1: return "XMODEM-CRC";
		case 2: return "XMODEM-1K";
	}
	return NULL;
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

	int failed = 0;

	sleep(4);
	printf("\r\nxfer test...\r\n");
	fflush(stdout);
	sleep(1);

#define F1 "\x85"
#define F3 "\x86"
#define F7 "\x88"
#define CR "\r"

	// PUNTER DOWNLOAD
	automate(F3 "A" CR);
	sleep(1);
	punter_xmit(data_in, size_in);

	sleep(5);

	// PUNTER UPLOAD
	automate(F1 "A" CR);
	sleep(1);
	data_out_punter_index = 0;
	punter_recv();
	sleep(8);

	// compare input and output
	int good = !memcmp(data_in, data_out_punter, size_in);
	fprintf(stderr, "***** TEST_XFER: PUNTER %s\n", good ? "OK" : "BAD");
	if (!good) {
		failed++;
	}

	for (int i = 0; i < 3; i++) {
		// switch protocol
		// 0: XMODEM
		// 1: XMODEM-CRC
		// 2: XMODEM-1K
		automate(F7 "P" CR); // // "F7", "P", "RETURN"
		sleep(1);

		// XMODEM 512B DOWNLOAD
		automate(F3 "B" CR "P" CR);
		sleep(1);
		xmodemTransmit(data_in, size_in, 0);
		sleep(4);

		// XMODEM CHKSUM UPLOAD
		automate(F1 "B" CR);
		sleep(1);
		int size_out1 = xmodemReceive(data_out1, capacity, 0);
		sleep(4);

		// compare input and output
		good = !memcmp(data_in, data_out1, size_in);
		fprintf(stderr, "***** TEST_XFER: XMODEM; client: %s, server: 512B/CHKSUM: %s\n", config_str(i), good ? "OK" : "BAD");
		if (!good) {
			failed++;
		}

		// XMODEM 1KB DOWNLOAD
		automate(F3 "C" CR "P" CR);
		sleep(1);
		xmodemTransmit(data_in, size_in, 1);
		sleep(4);

		// XMODEM CRC16 UPLOAD
		automate(F1 "C" CR);
		sleep(1);
		int size_out2 = xmodemReceive(data_out2, capacity, 0);
		sleep(4);

		int good = !memcmp(data_in, data_out2, size_in);
		fprintf(stderr, "***** TEST_XFER: XMODEM; client: %s, server: 1KB/CRC16:   %s\n", config_str(i), good ? "OK" : "BAD");
		if (!good) {
			failed++;
		}
	}
	if (failed == 0) {
		fprintf(stderr, "***** TEST_XFER: Succeeded!\n");
		printf("\r\nxfer test succeeded!\r\n");
		fflush(stdout);
	} else {
		fprintf(stderr, "***** TEST_XFER: Failed!\n");
		printf("\r\nxfer test failed!\r\n");
		fflush(stdout);
	}
}

//	fprintf(stderr, "***** SERVER: data_out_punter_index %d\n", data_out_punter_index);
//	f = fopen("/tmp/xxx", "wb");
//	fwrite(data_out_punter, 1, data_out_punter_index, f);
//	fclose(f);
