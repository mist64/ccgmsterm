	.feature labels_without_colons, loose_char_term, loose_string_term
	.macpack longbranch

; ccgms term 2021 source based on 5.5 source
; by craig smith 01/1988. 2017/2018/2019/2020/2021 mods by alwyz
; 1200baud.wordpress.com
;
; as of 1/1/2021 I am no longer maintaining ccgms. thanks! - alwyz
;
; EASYFLASH VERSION IS TURNED ON BY CHANGING VALUE OF EFBYTE TO $01
;
; Easyflash version gives option of loading/saving phonebook to cart
; and removes Swiftlink options
;
; BUILD with 64tass. Example:
;
; c:\c64\64tass\64tass.exe -C -B -i c:\c64\64tass\ccgms2021source.txt -o c:\c64\64tass\output.prg %1 %2 %3 %4 %5 %6 %7 %8 %9 2>c64error.txt
; if %errorlevel% == 1 echo errors occured!>>c64error.txt
;
; Some recent changelog stuff:
;
;5-14-2020 v2020 beta 2
; first public beta. rewrite of pretty much everything.... file transfers finally incorporate flow control. they never did before.
; resetvectors removed. re-wrote and optimized all modem drivers. removed a bunch of spaghetti code of my own making...
;
;5-16-2020 v2020 beta 3
; f3 disablexfer improvements
; multi-receive disablexfer imrovements / trying to prevent crashing on multidownloads (noted on up9600)
; added punter handshake delays from ultimate version back in. baudrates faster than 2400 are definitely having problems with handshakes so its back!
; added jsr call to rsopen to baudrate changer. see if that fixes some weirdness
;
;5-17-2020 v2020 beta 4
; found a bug on the original punter sourcecode that incorrectly references pbuf+11
; bytes as delay 1 on 0 off, but in truth it is 1 off 0 on, so ive set both to delay on now
; update... ahh fuck it, no matter what, add delays every chance we can.... i disabled every opportunity to bypass delay around pnt106.
;
;5-18-2020 v2020 beta 5
; fixing some possible issues with multi-upload. crashes between files. enablexfer not getting turned back on at the right time?
; re-did cf1 multi-upload enable/disablexfer calls... seems good now
;
;5-19-2020 v2020 beta 6
; merged easyflash version into this one. only added 2 blocks. easier for maintaining
; still have some room from $5000-$5100 for more code/routines if need be. And can always add more code at $5c00 before the end
;
;5-21-2020 v2020 beta 7
; did some tweaks to autodialer. try counter now works to 99, and dial unlisted had some weird
; issues with that so that has been sorted as well. found one bug in the bottom screen
; display routine which has probably been there since ccgms 2017, but its good now.
;
;5-23-2020 v2020 beta 8
; easyflash false positive with reu detect. since ef and reu cant work together, added
; provisions at startup to prevent easyflash mode from even looking for an reu
;
;6-30-2020 v2021 beta 1
; doing some bugfixing. dial unlisted doesnt restore bottom of screen after dial. now it does. cosmetic fix.
; abort punter crashes stack pointer because i bypassed jump table and apparently that is neccessary so its back in the
; calls from dowmen and f3 routines.
;
;9-22-2020 v2021 pre-beta2
; bo zimmermans firmware (and maybe others) take issue with atdt, and prefer using atd instead for bbsing (uploads/downloads issue). hopefully this
; is the only issue with firmware compatibility. willing to solve this issue on the software side, though i'd prefer firmware uses a better standard.
; but fuck it, it's 2020 and who gives a shit anymore about standards on an 8 bit computer from the 1980s? so i added an atd/atdt menu option
;
;12-08-2020 v2021 final
; well it's been fun. it was my dream at 10 years old to mod this program.
; now i make the one everyone uses. it's been an honor and a privilege.
; there might still be bugs but they're minor if anything.
;
;commodore color graphics
;manipulation system terminal
;by craig smith
;
;version 2021 - 12/2020 by alwyz - this is my last version. good luck to the next modder! maybe someone will add xmodem-1k and 80 columns.
;version 2020 - 2020 by alwyz
;ultimate version - 2019 by alwyz
;version 2019 - 2019 by alwyz
;version 2017 - 2017 by alwyz
;version 5.5 -- jan 1988
;version 5.0 -- jan 1988
;version 4.5 -- may 1987
;version 4.1 -- oct 1986
;version 4.0 -- date unknown
; mods by greg pfoutz,w/permission
;version 3.0 -- aug 1985
;
modreg = $dd01
datdir = $dd03
frmevl = $ad9e
outnum = $bdcd
ldv    = $fb
status = $90
dv     = $ba
lognum = $05
modem  = $02
secadr = $03
space  = $02
untalk = $ffab
unlstn = $ffae
load   = $ffd5
save   = $ffd8
setlfs = $ffba
setnam = $ffbd
open   = $ffc0
chkin  = $ffc6
chkout = $ffc9
chrin  = $ffcf
chrout = $ffd2
getin  = $ffe4
close  = $ffc3
clrchn = $ffcc
clall  = $ffe7
readst = $ffb7
plot   = $fff0
listen = $ffb1
second = $ff93
talk   = $ffb4
tksa   = $ff96
unlsn  = $ffae
untlk  = $ffab
acptr  = $ffa5
ciout  = $ffa8
rstkey = $fe56
norest = $fe72
return = $febc
oldout = $f1ca
oldchk = $f21b
ochrin = $f157
ogetin = $f13e
oldirq = $ea31
oldnmi = $fe47
findfn  = $f30f
devnum  = $f31f
nofile  = $f701
numfil = $98
locat  = $fb
nlocat = $fd
xmobuf = $fd
backgr = $d021
border = $d020
textcl = 646
clcode = $e8da
scrtop = 648
line   = 214
column = 211
llen   = 213
qmode  = 212
imode  = 216
bcolor = 0
tcolor = 15
cursor = 95    ;cursor "_"
left   = $9d
cursfl = $fe
buffst = $b2
bufptr = $b0
grasfl = $0313
duplex = $12
tempch = $05
tempcl = $06
revtabup = $0380
buftop = $cafd
bufptrreu = $cafe
buffstreu = $caff
crcz = $cb00; use mulfil since its a punter/xmodem thing
mulfil = $cb00 ; punter only
endmulfil = $cc00 ;end area for multipunter
crclo = $cc00;crc fIX;temp for runtime tables;use tempbuf and numbuf
crchi = $cd00;crc fix;temp for runtime tables
tempbuf = $cc00 ; dialer temp buf to print on screen after connect. check for busy and all that.
numbuf = $cd00 ; dialer number buffer. holds phone number and port number
pbuf = $cd00;punter buffer. can use same area as xmodem crc hi and phone buffer
ribuf = $ce00 ; rs232 receive input buffer points to $f7. no output buffers used on any modems in this release.
inpbuf = $cf00
configarea = $5100
mulcnt = 2047
mulfln = 2046
mlsall = 2045
mulskp = 2044
max    = $02
outstat = $a9
jiffies = $a2
begpos = $07
endpos = $ac
bufflg = $0b
buffl2 = $0c
buffoc = $10
baudof = $0299
rtail  = $029b
rhead  = $029c
rfree  = $029d ; used for swiftlink only
rflow  = $029e ; not used
enabl  = $02a1
pnt10  = inpbuf
pnt11  = $028d
pnt14  = $02a1
pbuf2  = $0400
xmoscn = pbuf2
can    = 24
ack    = 6
nak    = 21
eot    = 4
soh    = 1
crc    = 67
cpmeof = 26
ca = 193  ;cap letters!
b  = 194
c  = 195
d  = 196
e  = 197
f  = 198
g  = 199
h  = 200
i  = 201
l  = 204
o  = 207
m  = 205
n  = 206
cp = 208
q  = 209
cr = 210
cs = 211
t  = 212
u  = 213
v  = 214
w  = 215
cx = 216
cy = 217
z  = 219

	.segment "S07FF"
	.word $0801
	.segment "S0801"
	.byte $0d,$08,$0a,00,$9e,$34,$30
	.byte $39,$36,00,00,00
	jmp prestart

	.include "punter.s"
	;about 40 bytes still free here to play with before $1000
	.include "main.s"
	.include "macro.s"
	.include "params.s"
	.include "rs232.s"
	.include "reu.s"
	.include "theme.s"
	.include "easyflash.s"
	.include "config.s"
	.include "credits.s"

endprg .byte 0
endall
	.end
