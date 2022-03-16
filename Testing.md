# CCGMS Testing

## Transfer Test

The command

        make test

will build CCGMS with automation support and run an automated test in VICE for all file transfer protocols and their combinations.

It should print

        ***** TEST_XFER: PUNTER OK
        ***** TEST_XFER: XMODEM; client: XMODEM, server: 512B/CHKSUM: OK
        ***** TEST_XFER: XMODEM; client: XMODEM, server: 1KB/CRC16:   OK
        ***** TEST_XFER: XMODEM; client: XMODEM-CRC, server: 512B/CHKSUM: OK
        ***** TEST_XFER: XMODEM; client: XMODEM-CRC, server: 1KB/CRC16:   OK
        ***** TEST_XFER: XMODEM; client: XMODEM-1K, server: 512B/CHKSUM: OK
        ***** TEST_XFER: XMODEM; client: XMODEM-1K, server: 1KB/CRC16:   OK
        ***** TEST_XFER: Succeeded!

You will have to quit VICE manually after the test has finished.

The test uses the User Port driver at 2400 baud and takes about 5 minutes. You can speed it up using warp mode. With minimal modifications to the Makefile, you can run the test with other drivers and/or on real hardware.

## Echo

This test echos all input. Run the server like this:

        cd test
        sh echo.sh

 Running any of these

        make runup     # User Port
        make runup9600 # UP9600
        make runsw     # SwiftLink/DE

will connect to the server.

## Slowout

This test server prints characters slowly.

        cd test
        sh slowout.sh

## Fastout

This test server prints characters at the full data rate.

        cd test
        sh fastout.sh

It can easily overflow the 256 byte CCGMS input buffer if printing cannot keep up. The pattern printed makes it easy to see when characters are dropped.