# CCGMS Term 2021

*Commodore Color Graphics Manipulation System Terminal*<br/>
*by Craig Smith (1985-1988), alwyz (2017-2020)*

* based on 5.5 source by Craig Smith 01/1988.
* 2017/2018/2019/2020/2021 mods by alwyz, http://1200baud.wordpress.com (as of 1/1/2021 I am no longer maintaining ccgms. thanks! - alwyz)
* cleaned up and converted to ca65 by Michael Steil, 2022

## Build

Build with make & ca65

	make

## EasyFlash

The EasyFlash version gives you the option of loading/saving phonebook to cart and removes Swiftlink options

EasyFlash is turned on by changing value of `efbyte` to $01.

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
* found a bug on the original punter sourcecode that incorrectly references pbuf+11 bytes as delay 1 on 0 off, but in truth it is 1 off 0 on, so ive set both to delay on now update... ahh fuck it, no matter what, add delays every chance we can.... i disabled every opportunity to bypass delay around pnt106.

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
well it's been fun. it was my dream at 10 years old to mod this program. now i make the one everyone uses. it's been an honor and a privilege. there might still be bugs but they're minor if anything.

good luck to the next modder! maybe someone will add xmodem-1k and 80 columns.
