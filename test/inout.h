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

