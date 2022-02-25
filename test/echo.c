#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "inout.h"

int
main(int argc, char **argv) {
	while (!feof(stdin)) {
		int c = _inbyte(0);
		_outbyte(c);
	}
}
