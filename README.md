# CCGMS *Future*

*Commodore Color Graphics Manipulation System Terminal*<br/>
*by Craig Smith (1985-1988), alwyz (2017-2020), Michael Steil (2022)*

* based on 5.5 source by [Craig Smith](https://github.com/spathiwa) 01/1988.
* 2017/2018/2019/2020/2021 mods by [alwyz](http://1200baud.wordpress.com)
* cleaned up and converted to ca65 by [Michael Steil](https://www.pagetable.com/), 2022 (refer to branch ccgmsterm2021 for the last alwyz version)
* further improvements by Michael Steil

## Features

* 40 column color PETSCII and ASCII/ANSI terminal modes
* Serial drivers
	* user port (300-2400 baud)
	* UP9600 (300-9600 baud)
	* SwiftLink $DE00/$DF00/$D700/NMI (300-38400 baud)
* File transfer protocols:
	* Punter
	* Multi-Punter
	* XMODEM
	* XMODEM-CRC
	* XMODEM-1K 🔴

* Correct timing for NTSC and PAL 🔴
* Phone book
	* stores BBS addresses, user names, and passwords
	* autodialer
* Configuration and phone book load/save
	* disk
	* EasyFlash Cartridge
* DOS command and directory function (drives #8-30)
* Macros
* Screenshots
* Themes
* REU buffer (64 KB)

## Missing Features

* [RR-Net support](https://github.com/mist64/ccgmsterm/issues/1)
* [WiC64 support](https://github.com/mist64/ccgmsterm/issues/3)
* [80 column support](https://github.com/mist64/ccgmsterm/issues/2)
* YMODEM/ZMODEM/HMODEM protocols
* IDE64 compatibility
* Additional cartridges (e.g. Lt. Kernal)
* 100% support for hardware acceleration devices (SuperCPU etc). Certain conditions may affect file transfer handshake timing.

## Known Bugs

* [#5](https://github.com/mist64/ccgmsterm/issues/5): XMODEM (and possibly PUNTER) transmission may be broken for UP9600 devices
* [#10](https://github.com/mist64/ccgmsterm/issues/10): XMODEM/1K may fail for SwiftLink cartridges with a real 6551 chip

## Changes since CCGMS Future 0.1

* rewrote RS232 driver model – this may cause regressions; needs testing, especially PUNTER and Multi-PUNTER
* cleaned up memory layout
* changed "Graphics", "C/G", "Anscii" wording to (imho) clearer "PETSCII" and "ASCII"
* changed "Author's Message" to (imho) clearer "Instructions"
* fixed ASCII<->PETSCII conversion of codes 0x60 and 0x7B (was caused by off-by-one errors)

## Build

Build with make & [ca65](https://github.com/cc65/cc65).

Regular build:

	make

EasyFlash build:

	EASYFLASH=1 make

The EasyFlash version gives you the option of loading/saving the phonebook to cart and removes Swiftlink.

In either case, the resulting file will be `build/ccgmsterm.prg`.

## Running in VICE

To run CCGMS in x64sc with SwiftLink at $DE00:

	make runsw

x64sc with User Port:

	make runup

x64sc VICE with UP9600 ([receiving OK but sending broken as of VICE 3.6.2](https://sourceforge.net/p/vice-emu/bugs/1219/)):

	make runup9600

The x64sc command line has changed recently, so these need at least VICE 3.6.

## Changelog

### 2022-02-25: Future 0.1

* Fixed timing for PAL in User Port and UP9600 drivers
* Implemented XMODEM-1K
	* protocol XMODEM-1K forces 1K on upload
	* any XMODEM protocol will accept 1K blocks on download
* XMODEM-CRC autodetect on upload
	* protocols XMODEM-CRC/-1K will force CRC on download
	* any XMODEM protocol will accept CRC on upload

### 2020-12-08: v2021 final
* Punter stack and Unlisted dialer bugs have been eliminated
* Support in autodialer for Zimodem and related WiFi device firmware that prefer an ATD prefix to ATDT.

### 2020-09-22: v2021 pre-beta2
bo zimmermans firmware (and maybe others) take issue with atdt, and prefer using atd instead for bbsing (uploads/downloads issue). hopefully this  is the only issue with firmware compatibility. willing to solve this issue on the software side, though i'd prefer firmware uses a better standard. but fuck it, it's 2020 and who gives a shit anymore about standards on an 8 bit computer from the 1980s? so i added an atd/atdt menu option

### 2020-06-30: v2021 beta 1
* doing some bugfixing. dial unlisted doesnt restore bottom of screen after dial. now it does. cosmetic fix.
* abort punter crashes stack pointer because i bypassed jump table and apparently that is neccessary so its back in the calls from dowmen and f3 routines.

### 2020-05-23: v2020 beta 8
* easyflash false positive with reu detect. since ef and reu cant work together, added provisions at startup to prevent easyflash mode from even looking for an reu

### 2020-05-21: v2020 beta 7
* did some tweaks to autodialer. try counter now works to 99, and dial unlisted had some weird issues with that so that has been sorted as well.
* found one bug in the bottom screen display routine which has probably been there since ccgms 2017, but its good now.

### 2020-05-19: v2020 beta 6
* merged easyflash version into this one. only added 2 blocks. easier for maintaining
* still have some room from $5000-$5100 for more code/routines if need be. And can always add more code at $5c00 before the end

### 2020-05-18: v2020 beta 5
* fixing some possible issues with multi-upload. crashes between files. enablexfer not getting turned back on at the right time?
*  re-did cf1 multi-upload enable/disablexfer calls... seems good now

### 2020-05-17: v2020 beta 4
* found a bug on the original punter sourcecode that incorrectly references var "delay" as delay 1 on 0 off, but in truth it is 1 off 0 on, so ive set both to delay on now update... ahh fuck it, no matter what, add delays every chance we can.... i disabled every opportunity to bypass delay around pnt106.

### 2020-05-16: v2020 beta 3
* f3 disablexfer improvements
* multi-receive disablexfer imrovements / trying to prevent crashing on multidownloads (noted on up9600)
* added punter handshake delays from ultimate version back in. baudrates faster than 2400 are definitely having problems with handshakes so its back!
* added jsr call to rsopen to baudrate changer. see if that fixes some weirdness

### 2020-05-14: v2020 beta 2
* first public beta. rewrite of pretty much everything....
* file transfers finally incorporate flow control. they never did before.
* resetvectors removed.
* re-wrote and optimized all modem drivers.
* removed a bunch of spaghetti code of my own making...

### ultimate version
* 2019 by alwyz

### version 2019
* 2019 by alwyz

### version 2017
* 2017 by alwyz

### Historic Versions
by Craig Smith

* version 5.5 -- jan 1988
* version 5.0 -- jan 1988
* version 4.5 -- may 1987
* version 4.1 -- oct 1986
* version 4.0 -- date unknown (mods by greg pfoutz,w/permission)
* version 3.0 -- aug 1985
