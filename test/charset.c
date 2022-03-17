#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "inout.h"

int
main(int argc, char **argv) {
	unsigned char c = 0x20;
	for (;;) {
		if ((c & 0x1f) == 0) {
			fputc(13, stdout);
			fflush(stdout);
		}
		fputc(c, stdout);
		c++;
		if (c > 0x7f) {
			c = 0x20;
		}
	}
}
