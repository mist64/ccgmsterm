#!/bin/sh

#
# XMODEM/PUNTER Test Program
#
# * run this script
# * run CCGMS in VICE using "make runup" (or runup9600, runsw)
# * follow the instructions in CCGMS (press F1, F3 etc.)
#
# The test should print
#   PUNTER OK
# after a PUNTER upload and
#   PART1 OK
#   PART2 OK
# after two XMODEM downloads and two uploads.
#
# * repeat with all three XMODEM variants!

set -e

cc -o xfer xfer.c xmodem.c crc16.c punter.c

socat -d -d tcp-l:25232,fork,reuseaddr system:"./xfer"
