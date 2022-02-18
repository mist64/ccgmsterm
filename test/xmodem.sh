#!/bin/sh

#
# XMODEM Test Program
#
# * run this script
# * configure CCGMS to use SwiftLink/$DE00 in config.s
# * configure CCGMS to use XMODEM, XMODEM-CRC or XMODEM-1K
# * run CCGMS in VICE using "make run"
# * follow the instructions in CCGMS (press F1, F3 etc.)
#
# The test should print
#   PART1 OK
#   PART2 OK
# after two downloads and two uploads.
#
# * repeat with the other two XMODEM variants

set -e

cc -o xmodem main.c xmodem.c crc16.c

socat -d -d tcp-l:25232,fork,reuseaddr system:"./xmodem"
