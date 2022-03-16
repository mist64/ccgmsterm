// Punter Transfer Protocol
//
// Copyright (c) 2003,2016, Per Olofsson. All rights reserved.
// This file is licensed under the BSD 2-Clause License.
//
// https://github.com/MagerValp/CGTerm
//
// Modified by Michael Steil to match the protocol variant in CCGMS.
// Search for "#ifdef CCGMS" for code additions.

#define CCGMS

#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern int _inbyte(unsigned short timeout);
extern void _outbyte(int c);
extern int xfer_save_data(unsigned char *data, int length);

unsigned char xfer_buffer[4096];
int xfer_cancel = 0;

void xfer_send_byte(unsigned char c) {
	_outbyte(c);
}

signed int xfer_recv_byte(int timeout) {
	return _inbyte(timeout);
}

signed int xfer_recv_byte_error(int timeout, int errorcnt) {
	return _inbyte(timeout);
}

#define xfer_saved_bytes 0

void menu_update_xfer_progress(char *message, int a, int b) {
  fprintf(stderr, "menu_update_xfer_progress: %s\n", message);
}

#define gfx_vbl(...)

#define MIN(a,b) \
  ({ __typeof__ (a) _a = (a); \
     __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

void punter_fail(char *message) {
  fprintf(stderr, "punter_fail: %s\n", message);
  menu_update_xfer_progress(message, xfer_saved_bytes, 0);
  gfx_vbl();
}


void punter_retry(char *message) {
  fprintf(stderr, "punter_retry: %s\n", message);
  menu_update_xfer_progress(message, xfer_saved_bytes, 0);
  gfx_vbl();
}


void punter_send_string(char *s) {
  fprintf(stderr, "punter_send_string: %s\n", s);
  while (*s) {
    xfer_send_byte(*s++);
  }
}


int punter_recv_string(char *sendstring, char *recvstring) {
  int c, bytecnt;
  int errorcnt;

  fprintf(stderr, "punter_recv_string: sending \"%s\"\n", sendstring);
  memset(recvstring, 'a', 4);
  if (sendstring) {
	punter_send_string(sendstring);
  }
  bytecnt = 0;
  errorcnt = 10;
  while (bytecnt != 3) {
    while ((c = xfer_recv_byte(1000)) < 0 && errorcnt-- && (xfer_cancel == 0)) {
      fprintf(stderr, "punter_recv_string: timeout %d\n", errorcnt);
      punter_send_string(sendstring);
      fprintf(stderr, "punter_recv_string: sending \"%s\"\n", sendstring);
      bytecnt = 0;
    }
    if (errorcnt && (xfer_cancel == 0)) {
      recvstring[bytecnt++] = c;
    } else {
      return(0);
    }
  }
  recvstring[3] = 0;
  fprintf(stderr, "punter_recv_string: received \"%s\"\n", recvstring);

  return(3);
}


int punter_handshake(char *sendstring, char *waitstring) {
  char p[4];
  int l = 0;
  int errorcnt = 10;

  fprintf(stderr, "punter_handshake: %s -> %s\n", sendstring, waitstring);

  while (errorcnt--) {
    l = punter_recv_string(sendstring, p);
    if (l == 3) {
      if (strcmp(waitstring, p) == 0) {
	fprintf(stderr, "punter_handshake: got \"%s\", done\n", waitstring);
	return(1);
      } else if (strcmp(sendstring, p) == 0) {
	fprintf(stderr, "punter_handshake: got echoed \"%s\", failed\n", sendstring);
	return(0);
      } else {
	if (strcmp("ACK", waitstring) == 0) {
	  if (strcmp("CKA", p) == 0) {
	    xfer_recv_byte(100);
	    xfer_recv_byte(100);
	    return(1);
	  }
	  if (strcmp("KAC", p) == 0) {
	    xfer_recv_byte(100);
	    return(1);
	  }
	}
      }
    }
  }
  fprintf(stderr, "punter_handshake: failed\n");
  return(0);
}


void punter_checksum(int len, unsigned short *c1, unsigned short *c2) {
  unsigned short cksum = 0;
  unsigned short clc = 0;
  unsigned char *data = xfer_buffer + 4;

  len -= 4;
  while (len--) {
    cksum += *data;
    clc ^= *data++;
    clc = (clc<<1) | (clc>>15);
  }
  *c1 = cksum;
  *c2 = clc;
}


int punter_checksum_verify(int len) {
  unsigned short cksum;
  unsigned short clc;
  punter_checksum(len, &cksum, &clc);
  if (cksum == (xfer_buffer[0] | (xfer_buffer[1]<<8))) {
    if (clc == (xfer_buffer[2] | (xfer_buffer[3]<<8))) {
      return(1);
    }
  }
  fprintf(stderr, "punter_checksum_verify: cksum = %04x (%04x)\n", cksum, xfer_buffer[0] | (xfer_buffer[1]<<8));
  fprintf(stderr, "punter_checksum_verify:   clc = %04x (%04x)\n", clc, xfer_buffer[2] | (xfer_buffer[3]<<8));
  return(0);
}


void punter_checksum_create(int len) {
  unsigned short cksum;
  unsigned short clc;
  punter_checksum(len, &cksum, &clc);
  xfer_buffer[0] = cksum & 0xff;
  xfer_buffer[1] = cksum >> 8;
  xfer_buffer[2] = clc & 0xff;
  xfer_buffer[3] = clc >> 8;
}


unsigned short punter_next_blocknum(void) {
  return(xfer_buffer[5] | (xfer_buffer[6]<<8));
}


signed int punter_recv_block(int len) {
  signed int c;
  int bytecnt;
  int errorcnt = 10;

 restart:
  fprintf(stderr, "punter_recv_block: receiving %d byte block\n", len);
  punter_send_string("S/B");
  bytecnt = 0;
  while (bytecnt < len) {
    if ((c = xfer_recv_byte_error(500, 10)) < 0) {
      if (bytecnt == 3) {
	if (strncmp("S/B", (char *)xfer_buffer, 3) == 0) {
	  menu_update_xfer_progress("Transfer canceled by remote", xfer_saved_bytes, 0);
	  gfx_vbl();
	  return(-1);
	}
      }
      menu_update_xfer_progress("Block timed out, retrying", xfer_saved_bytes, 0);
      gfx_vbl();
      if (punter_handshake("BAD", "ACK")) {
	if (errorcnt--) {
	  goto restart;
	} else {
	  menu_update_xfer_progress("Block timed out", xfer_saved_bytes, 0);
	  gfx_vbl();
	  return(-1);
	}
      } else {
	menu_update_xfer_progress("Handshake timed out", xfer_saved_bytes, 0);
	gfx_vbl();
	fprintf(stderr, "punter_recv_block: bad handshake timeout\n");
	return(-1);
      }
    }
    fprintf(stderr, "punter_recv_block: received byte %3d: %02x '%c'\n", bytecnt, c, c >= 0x20 && c < 0x7f ? c : '.');
    xfer_buffer[bytecnt++] = c;
    if (bytecnt == 4) {
      if (strncmp("ACK", (char *)xfer_buffer, 3) == 0) {
	menu_update_xfer_progress("Lost sync, retrying...", xfer_saved_bytes, 0);
	gfx_vbl();
	if (xfer_buffer[3] == 'A') {
	  goto restart;
	} else {
	  fprintf(stderr, "punter_recv_block: skipping late ack\n");
	  xfer_buffer[0] = xfer_buffer[3];
	  bytecnt = 1;
	}
      }
    }
    if (bytecnt == 8) {
      if (strncmp("ACKACK", (char *)xfer_buffer + 2, 6) == 0) {
	menu_update_xfer_progress("Lost sync, retrying...", xfer_saved_bytes, 0);
	gfx_vbl();
	fprintf(stderr, "punter_recv_block: lost sync, restarting block\n");
	goto restart;
      }
      if (strncmp("CKACKA", (char *)xfer_buffer + 2, 6) == 0) {
	menu_update_xfer_progress("Lost sync, retrying...", xfer_saved_bytes, 0);
	gfx_vbl();
	fprintf(stderr, "punter_recv_block: lost sync, restarting block\n");
	goto restart;
      }
      if (strncmp("KACKAC", (char *)xfer_buffer + 2, 6) == 0) {
	menu_update_xfer_progress("Lost sync, retrying...", xfer_saved_bytes, 0);
	gfx_vbl();
	fprintf(stderr, "punter_recv_block: lost sync, restarting block\n");
	goto restart;
      }
    }
  }
  if (punter_checksum_verify(bytecnt)) {
    if (punter_handshake("GOO", "ACK") == 0) {
      menu_update_xfer_progress("Handshake timed out", xfer_saved_bytes, 0);
      gfx_vbl();
      fprintf(stderr, "punter_recv_block: goo handshake timeout\n");
      return(-1);
    }
    menu_update_xfer_progress("Downloading...", xfer_saved_bytes, 0);
    gfx_vbl();
    if (len <= 8) {
      fprintf(stderr, "punter_recv_block: short block, returning %d\n", xfer_buffer[4]);
      return(xfer_buffer[4]);
    }
    if (xfer_save_data(xfer_buffer + 7, len - 7)) {
      fprintf(stderr, "punter_recv_block: returning %d\n", xfer_buffer[4]);
      return(xfer_buffer[4]);
    } else {
      punter_fail("Write error!");
      gfx_vbl();
      return(-1);
    }
  } else {
    menu_update_xfer_progress("Checksum failed, retrying", xfer_saved_bytes, 0);
    gfx_vbl();
    fprintf(stderr, "punter_recv_block: checksum failed\n");
    if (punter_handshake("BAD", "ACK")) {
      if (errorcnt--) {
	goto restart;
      } else {
	menu_update_xfer_progress("Checksum failed", xfer_saved_bytes, 0);
	gfx_vbl();
	return(-1);
      }
    } else {
      menu_update_xfer_progress("Handshake timed out", xfer_saved_bytes, 0);
      gfx_vbl();
      fprintf(stderr, "punter_recv_block: bad handshake timeout\n");
      return(-1);
    }
  }
}


void punter_countdown(int num) {
  char s[24];

  sprintf(s, "Starting in %d", num);
  menu_update_xfer_progress(s, xfer_saved_bytes, 0);
  gfx_vbl();
}


int punter_recv(void) {
  signed int nextblocksize;

  menu_update_xfer_progress("Starting...", xfer_saved_bytes, 0);
  gfx_vbl();

#ifdef CCGMS
  char p[4];
  int l = punter_recv_string(NULL, p);
  (void)l;
#endif

  if (punter_handshake("GOO", "ACK")) {
    punter_countdown(5);
  } else {
    punter_fail("Timed out");
    return(0);
  }

  nextblocksize = punter_recv_block(8);
  if (nextblocksize < 0) {
    punter_fail("Timed out on filetype block");
    return(0);
  }

  if (punter_handshake("GOO", "ACK")) {
    punter_countdown(4);
  } else {
    punter_fail("Handshake timeout");
    return(0);
  }

  if (punter_handshake("S/B", "SYN")) {
    punter_countdown(3);
  } else {
    punter_fail("Handshake timeout");
    return(0);
  }

  if (punter_handshake("SYN", "S/B")) {
    punter_countdown(2);
  } else {
    punter_fail("Handshake timeout");
    return(0);
  }

#ifdef CCGMS
  l = punter_recv_string(NULL, p);
  (void)l;
  l = punter_recv_string(NULL, p);
  (void)l;
  fprintf(stderr, "sleeping...\n");
  sleep(2);
  fprintf(stderr, "...done\n");
#endif

  if (punter_handshake("GOO", "ACK")) {
    punter_countdown(1);
  } else {
    punter_fail("Handshake timeout");
    return(0);
  }

  nextblocksize = punter_recv_block(7);
  if (nextblocksize < 0) {
    // error
    punter_fail("file start timeout");
    return(0);
  }

  while (punter_next_blocknum() < 0xff00 && nextblocksize >= 7) {
    nextblocksize = punter_recv_block(nextblocksize);
  }
  if (nextblocksize < 0) {
    //punter_fail("Block timeout");
    return(0);
  }

  menu_update_xfer_progress("Finishing...", xfer_saved_bytes, 0);
  gfx_vbl();

  if (punter_handshake("S/B", "SYN")) {
    punter_handshake("SYN", "S/B");
    menu_update_xfer_progress("Finished", xfer_saved_bytes, 0);
    gfx_vbl();
  } else {
    menu_update_xfer_progress("Done, but handshake timed out", xfer_saved_bytes, 0);
    gfx_vbl();
  }
  return(1);
}

void xmit_block(int len) {
  for (int i = 0; i < len; i++) {
    xfer_send_byte(xfer_buffer[i]);
  }
}

// very simple Punter transmit implementation with zero error handling
int punter_xmit(void *data, int data_len) {
  // A1
  fprintf(stderr, "punter_send: A1\n");
  punter_handshake("GOO", "GOO");

  // A2
  fprintf(stderr, "punter_send: A2\n");
  punter_handshake("ACK", "S/B");
  xfer_buffer[5] = 0xff;
  xfer_buffer[6] = 0xff;
  xfer_buffer[7] = 1; // SEQ
  punter_checksum_create(8);
  xmit_block(8);
  punter_handshake(NULL, "GOO");

  // A3
  fprintf(stderr, "punter_send: A3\n");
  punter_handshake("ACK", "S/B");
  punter_handshake("SYN", "SYN");
	punter_send_string("S/B");

  // B1
  fprintf(stderr, "punter_send: B1\n");
  punter_handshake(NULL, "GOO");

  // B2
  int max_block = 255;
  int index = 0;
  int data_ptr = 0;
  int len = 7;
  int next_len;
  int is_last_block = 0;
  do {
    int next_data_ptr = data_ptr + len - 7;
    next_len = MIN(data_len - next_data_ptr, max_block - 7) + 7;
    if (len < max_block && index) {
      index = 0xffff;
      is_last_block = 1;
    }
    fprintf(stderr, "punter_send: B2\n");
    punter_handshake("ACK", "S/B");
    xfer_buffer[5] = index & 0xff;
    xfer_buffer[6] = index >> 8;
    xfer_buffer[4] = next_len;
    memcpy(&xfer_buffer[7], &data[data_ptr], len - 7);
    punter_checksum_create(len);
    xmit_block(len);
    punter_handshake(NULL, "GOO");
    index++;
    data_ptr = next_data_ptr;
    len = next_len;
    fprintf(stderr, "punter_send: len = %d\n", len);
  } while(!is_last_block);

  // B3
  fprintf(stderr, "punter_send: B3\n");
  punter_handshake("ACK", "S/B");
  punter_handshake("SYN", "SYN");
	punter_send_string("S/B");

  return(1);
}
