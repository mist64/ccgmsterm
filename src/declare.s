
; CIA#2 I/O (user port RS232)
cia2pb		= $dd01
cia2ddrb	= $dd03


numfil	= $98
locat	= $fb
nlocat	= $fd

backgr	= $d021
border	= $d020

textcl	= 646
scrtop	= 648
LINE	= 214
COLUMN	= 211
llen	= 213
qmode	= 212
imode	= 216

bcolor	= 0
tcolor	= 15

ascii_mode	= $0313	; PETSCII or ASCII

revtabup = $0380

buftop	= $cafd
bufptrreu = $cafe
buffstreu = $caff
mulfil	= $cb00 ; punter only
endmulfil = $cc00 ;end area for multipunter
crclo	= $cc00;crc fIX;temp for runtime tables;use tempbuf and numbuf
crchi	= $cd00;crc fix;temp for runtime tables
tempbuf	= $cc00 ; dialer temp buf to print on screen after connect. check for busy and all that.
numbuf	= $cd00 ; dialer number buffer. holds phone number and port number
codebuf	= $cd00;punter buffer. can use same area as xmodem crc hi and phone buffer
ribuf	= $ce00 ; rs232 receive input buffer points to $f7. no output buffers used on any modems in this release.
inpbuf	= $cf00

configarea = $5100

mulskp	= $07fc
mlsall	= $07fd
mulfln	= $07fe
mulcnt	= $07ff

rtail	= $029b
rhead	= $029c
rfree	= $029d ; used for swiftlink only

;cap letters!
ca	= 193
b	= 194
c	= 195
d	= 196
e	= 197
f	= 198
g	= 199
h	= 200
i	= 201
l	= 204
o	= 207
m	= 205
n	= 206
cp	= 208
q	= 209
cr	= 210
cs	= 211
t	= 212
u	= 213
v	= 214
w	= 215
cx	= 216
cy	= 217
z	= 219

; register saving, used by rs_user, swiftlink, up9600
rsotm	= $97
rsotx	= $9e
rsoty	= $9f

; zero page
tmp02	= $02
max	= $02
tmp03	= $03
tmp04	= $04
tempch	= $05
tempcl	= $06
begpos	= $07
bufflg	= $0b
buffl2	= $0c
buffer_open	= $10
half_duplex	= $12
zpoutstr	= $22 ; 2 bytes
endpos	= $ac
buffst	= $b2
buffer_ptr	= $b0 ; 2 bytes
cursor_flag	= $fe

; BASIC symbols
outnum	= $bdcd

; KERNAL symbols
status	= $90
DFLTN	= $99
DFLTO	= $9a
JIFFIES	= $a2	; TIME+2
LSTX	= $c5	; last key pressed
SHFLAG	= $028d ; bitfield: modifier keys currently pressed
 SHFLAG_SHIFT	= 1
 SHFLAG_CBM	= 2
 SHFLAG_CTRL	= 4
KEYLOG	= $028f
MODE	= $0291

untalk	= $ffab
unlstn	= $ffae
load	= $ffd5
save	= $ffd8
setlfs	= $ffba
setnam	= $ffbd
open	= $ffc0
chkin	= $ffc6
chkout	= $ffc9
chrin	= $ffcf
chrout	= $ffd2
getin	= $ffe4
close	= $ffc3
clrchn	= $ffcc
clall	= $ffe7
readst	= $ffb7
plot	= $fff0
listen	= $ffb1
second	= $ff93
talk	= $ffb4
tksa	= $ff96
unlsn	= $ffae
untlk	= $ffab
acptr	= $ffa5
ciout	= $ffa8
rstkey	= $fe56
norest	= $fe72
return	= $febc
oldout	= $f1ca
oldchk	= $f21b
ochrin	= $f157
ogetin	= $f13e
oldirq	= $ea31
oldnmi	= $fe47
findfn	= $f30f
devnum	= $f31f
nofile	= $f701
COLTAB  = $e8da ; PETSCII codes for the colors 0-15

; logical file numbers
LFN_FILE	= 2 ; for upload/download
LFN_MODEM	= 5

DEV_MODEM	= $02	; modem device
SA_MODEM	= $03	; modem secondary address

PETSCII_UNDERLINE	= $a4
PETSCII_CSR_LEFT	= $9d
PETSCII_WHITE		= $05
CURSOR	= '_'	; cursor, ASCII "_"
