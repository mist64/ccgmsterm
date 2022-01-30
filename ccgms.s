	.feature labels_without_colons, loose_char_term, loose_string_term
	.macpack longbranch

modreg	= $dd01
datdir	= $dd03
frmevl	= $ad9e
outnum	= $bdcd
ldv	= $fb
status	= $90
dv	= $ba
lognum	= $05
modem	= $02
secadr	= $03
space	= $02
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
numfil	= $98
locat	= $fb
nlocat	= $fd
xmobuf	= $fd
backgr	= $d021
border	= $d020
textcl	= 646
clcode	= $e8da
scrtop	= 648
line	= 214
column	= 211
llen	= 213
qmode	= 212
imode	= 216
bcolor	= 0
tcolor	= 15
cursor	= 95    ;cursor "_"
left	= $9d
cursfl	= $fe
buffst	= $b2
bufptr	= $b0
grasfl	= $0313
duplex	= $12
tempch	= $05
tempcl	= $06
revtabup = $0380
buftop	= $cafd
bufptrreu = $cafe
buffstreu = $caff
crcz	= $cb00; use mulfil since its a punter/xmodem thing
mulfil	= $cb00 ; punter only
endmulfil = $cc00 ;end area for multipunter
crclo	= $cc00;crc fIX;temp for runtime tables;use tempbuf and numbuf
crchi	= $cd00;crc fix;temp for runtime tables
tempbuf	= $cc00 ; dialer temp buf to print on screen after connect. check for busy and all that.
numbuf	= $cd00 ; dialer number buffer. holds phone number and port number
pbuf	= $cd00;punter buffer. can use same area as xmodem crc hi and phone buffer
ribuf	= $ce00 ; rs232 receive input buffer points to $f7. no output buffers used on any modems in this release.
inpbuf	= $cf00
configarea = $5100
mulcnt	= 2047
mulfln	= 2046
mlsall	= 2045
mulskp	= 2044
max	= $02
outstat	= $a9
jiffies	= $a2
begpos	= $07
endpos	= $ac
bufflg	= $0b
buffl2	= $0c
buffoc	= $10
baudof	= $0299
rtail	= $029b
rhead	= $029c
rfree	= $029d ; used for swiftlink only
rflow	= $029e ; not used
enabl	= $02a1
pnt10	= inpbuf
pnt11	= $028d
pnt14	= $02a1
pbuf2	= $0400
xmoscn	= pbuf2
can	= 24
ack	= 6
nak	= 21
eot	= 4
soh	= 1
crc	= 67
cpmeof	= 26
ca	= 193  ;cap letters!
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

.segment "S07FF"

	.word $0801

.segment "S0801"

	.word $080d
	.word 10
	.byte $9e,'4096'
	.word 0
	.byte 0

	jmp prestart

.segment "S0812"  ;pxxxxx

	.include "punter.s"
	;about 40 bytes still free here to play with before $1000

.segment "S1000"

;start of terminal program

	.include "init.s"
	.include "main.s"
	.include "dir.s"
	.include "ansi.s"
	.include "input.s"
	.include "misc.s"
	.include "disk2.s"
	.include "macro2.s"
	.include "buffer2.s"
	.include "xmodem.s"
	.include "xfer.s"
	.include "disk.s"
	.include "multixfer.s"
	.include "buffer.s"
	.include "phonebook.s"
	.include "hayes.s"
	.include "config2.s"
	.include "viewmg.s"
	.include "macro.s"
	.include "params.s"
	.include "rs232.s"
	.include "reu.s"
	.include "theme.s"
	.include "easyflash.s"

.segment "S5100"

	.include "config.s"

.segment "S5C00"

	.include "credits.s"

endprg	.byte 0
endall
	.end
