# CCGMS Term *Future*

*Commodore Color Graphics Manipulation System Terminal*<br/>
*by Craig Smith (1985-1988), alwyz (2017-2020), Michael Steil (2022-)*

* based on 5.5 source by [Craig Smith](https://github.com/spathiwa) 01/1988.
* 2017/2018/2019/2020/2021 mods by [alwyz](http://1200baud.wordpress.com)
* cleaned up and converted to ca65 by [Michael Steil](https://www.pagetable.com/), 2022 (refer to branch ccgmsterm2021 for the last alwyz version)
* further improvements by Michael Steil

## Features

* 40 column Color Graphics PETSCII / ASCII / ANSI terminal modes
* Serial drivers
	* User Port (2400)
	* UP9600
	* Swiftlink (DE, DF, D7)
* Baud Rates from 300-38.4k
* File transfer protocols:
	* Punter
	* Multi-Punter
	* Xmodem
	* Xmodem-CRC
* 17XX REU Buffer 64k Support
* Easyflash Cartridge Phonebook / Configuration load/save
* Autodialer phonebook to store all of your BBS addresses, user names, and passwords
* DOS Wedge with support for drives #8-30
* Macros, Screenshots, Themes, and lots of little extras
* NTSC and PAL compatible for proper user port timing.

## Missing Features

* RR-Net Support.
* IDE64 Compatibility.
* 80 Column Emulation.
* Protocols for XModem-1k / YModem / ZModem / HModem
* Support for devices other than a 17XX REU, Easyflash, and Swiftlink which use the cartridge port (Lt. Kernal I’m looking at you)
* 100% support for hardware acceleration devices (SuperCPU etc). Certain conditions may affect file transfer handshake timing.

## Build

Build with make & [ca65](https://github.com/cc65/cc65).

Regular build:

	make

EasyFlash build:

	EASYFLASH=1 make

The EasyFlash version gives you the option of loading/saving the phonebook to cart and removes Swiftlink.

In either case, the resulting file will be `build/ccgmsterm.prg`.

## Changelog

### Historic Versions
by Craig Smith

* version 3.0 -- aug 1985
* version 4.0 -- date unknown (mods by greg pfoutz,w/permission)
* version 4.1 -- oct 1986
* version 4.5 -- may 1987
* version 5.0 -- jan 1988
* version 5.5 -- jan 1988

### version 2017
*  2017 by alwyz

### version 2019
* 2019 by alwyz

### ultimate version
* 2019 by alwyz

### 5-14-2020 v2020 beta 2
* first public beta. rewrite of pretty much everything....
* file transfers finally incorporate flow control. they never did before.
* resetvectors removed.
* re-wrote and optimized all modem drivers.
* removed a bunch of spaghetti code of my own making...

### 5-16-2020 v2020 beta 3
* f3 disablexfer improvements
* multi-receive disablexfer imrovements / trying to prevent crashing on multidownloads (noted on up9600)
* added punter handshake delays from ultimate version back in. baudrates faster than 2400 are definitely having problems with handshakes so its back!
* added jsr call to rsopen to baudrate changer. see if that fixes some weirdness

### 5-17-2020 v2020 beta 4
* found a bug on the original punter sourcecode that incorrectly references var "delay" as delay 1 on 0 off, but in truth it is 1 off 0 on, so ive set both to delay on now update... ahh fuck it, no matter what, add delays every chance we can.... i disabled every opportunity to bypass delay around pnt106.

### 5-18-2020 v2020 beta 5
* fixing some possible issues with multi-upload. crashes between files. enablexfer not getting turned back on at the right time?
*  re-did cf1 multi-upload enable/disablexfer calls... seems good now

### 5-19-2020 v2020 beta 6
* merged easyflash version into this one. only added 2 blocks. easier for maintaining
* still have some room from $5000-$5100 for more code/routines if need be. And can always add more code at $5c00 before the end

### 5-21-2020 v2020 beta 7
* did some tweaks to autodialer. try counter now works to 99, and dial unlisted had some weird issues with that so that has been sorted as well.
* found one bug in the bottom screen display routine which has probably been there since ccgms 2017, but its good now.

### 5-23-2020 v2020 beta 8
* easyflash false positive with reu detect. since ef and reu cant work together, added provisions at startup to prevent easyflash mode from even looking for an reu

### 6-30-2020 v2021 beta 1
* doing some bugfixing. dial unlisted doesnt restore bottom of screen after dial. now it does. cosmetic fix.
* abort punter crashes stack pointer because i bypassed jump table and apparently that is neccessary so its back in the calls from dowmen and f3 routines.

### 9-22-2020 v2021 pre-beta2
bo zimmermans firmware (and maybe others) take issue with atdt, and prefer using atd instead for bbsing (uploads/downloads issue). hopefully this  is the only issue with firmware compatibility. willing to solve this issue on the software side, though i'd prefer firmware uses a better standard. but fuck it, it's 2020 and who gives a shit anymore about standards on an 8 bit computer from the 1980s? so i added an atd/atdt menu option

### 12-08-2020 v2021 final
* Punter stack and Unlisted dialer bugs have been eliminated
* Support in autodialer for Zimodem and related WiFi device firmware that prefer an ATD prefix to ATDT.
