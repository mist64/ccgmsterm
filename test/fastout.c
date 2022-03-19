#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "inout.h"

int
main(int argc, char **argv) {
	char l = 'A';
	char c = '0';
	for (;;) {
		fputc(l, stdout);
		fputc(c, stdout);
		c++;
		if (c > '9') {
			fputc(13, stdout);
			fflush(stdout);
			l++;
			if (l > 'Z') {
				l = 'A';
			}
			c = '0';
		}
	}
}
