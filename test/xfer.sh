#!/bin/sh

#
# XMODEM/PUNTER Test Program
#
# See "make test".
#
# It should print:
#    ***** TEST_XFER: PUNTER OK
#    ***** TEST_XFER: XMODEM; client: XMODEM, server: 512B/CHKSUM: OK
#    ***** TEST_XFER: XMODEM; client: XMODEM, server: 1KB/CRC16:   OK
#    ***** TEST_XFER: XMODEM; client: XMODEM-CRC, server: 512B/CHKSUM: OK
#    ***** TEST_XFER: XMODEM; client: XMODEM-CRC, server: 1KB/CRC16:   OK
#    ***** TEST_XFER: XMODEM; client: XMODEM-1K, server: 512B/CHKSUM: OK
#    ***** TEST_XFER: XMODEM; client: XMODEM-1K, server: 1KB/CRC16:   OK
#    ***** TEST_XFER: Succeeded!

set -e

cc -o xfer xfer.c xmodem.c crc16.c punter.c

#socat -d -d tcp-l:25232,fork,reuseaddr system:"./xfer"
socat -d -d tcp-l:25232,reuseaddr system:"./xfer"
