; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Global constants
;

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

BCOLOR	= 0
TCOLOR	= 15

ascii_mode	= $0313	; PETSCII or ASCII

revtabup = $0380

buftop	= $cafd
bufptrreu = $cafe
buffstreu = $caff
mulfil	= $cb00	; punter only
endmulfil = $cc00 ;end area for multipunter
crclo	= $cc00	; temp for runtime tables;use tempbuf and numbuf
crchi	= $cd00	; temp for runtime tables
tempbuf	= $cc00	; dialer temp buf to print on screen after connect. check for busy and all that.
numbuf	= $cd00	; dialer number buffer. holds phone number and port number
codebuf	= $cd00	; punter buffer. can use same area as xmodem crc hi and phone buffer
ribuf	= $ce00 ; rs232 receive input buffer (we don't use an output buffer)
inpbuf	= $cf00
SCREENS_BASE	= $e000	; 4 saved screens

tmp07e8	= $07e8	; temp. filename storage for file selection from directory
mulskp	= $07fc
mlsall	= $07fd
mulfln	= $07fe
mulcnt	= $07ff

rtail	= RIDBE ; friendlier name
rhead	= RIDBS ; friendlier name
rfree	= RODBS ; re-purposed; SwiftLink only

.ifdef BIN_2021
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
.endif

; register saving, used by rs_user, swiftlink, up9600
rsotm	= $97
rsotx	= $9e
rsoty	= $9f

; zero page
tmp02	= $02
max	= $02
tmp03	= $03
tmp04	= $04
tempch	= $05    ; saved character
tmp05	= $05
tempcl	= $06    ; saved character color
tmp06	= $06
begpos	= $07
tmp0b   = $0b
bufflg	= $0b    ; $80: 0: disk, 1: buffer; $40: 1: delay
buffl2	= $0c
buffer_open	= $10
half_duplex	= $12
zpoutstr	= $22 ; 2 bytes
tmp9e	= $9e
tmp9f	= $9f
inbits	= $a8
outstat	= $a9	; re-used KERNAL symbol RER/RINONE
inbyte	= $aa
endpos	= $ac
buffer_ptr	= $b0 ; 2 bytes
buffst	= $b2
outbits	= $b4
outbit	= $b5
outbyte	= $b6
tmpfd	= $fd
cursor_flag	= $fe


; BASIC symbols
outnum	= $bdcd

; KERNAL symbols
status	= $90
DFLTN	= $99
DFLTO	= $9a
JIFFIES	= $a2	; TIME+2
FA	= $ba
LSTX	= $c5	; last key pressed
NDX     = $c6   ; number of characters in keyboard queue
BLNSW   = $cc   ; cursor blinking
LDTB1   = $d9   ; screen line link table
RIBUF	= $f7	; RS232 buffer
RPTFLA	= $028a	; key repeat flag
KOUNT	= $028b	; counter for timing delay between key repeats
SHFLAG	= $028d ; bitfield: modifier keys currently pressed
 SHFLAG_SHIFT	= 1
 SHFLAG_CBM	= 2
 SHFLAG_CTRL	= 4
KEYLOG	= $028f
MODE	= $0291
ENABL	= $02a1

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
COLTAB  = $e8da	; PETSCII codes for the colors 0-15
LDTB2	= $ecf0	; line offsets low

; logical file numbers
LFN_FILE	= 2	; for upload/download
LFN_PRINTER     = 4	; printing buffers
LFN_MODEM	= 5
LFN_DIR 	= 13
LFN_DISK_CMD    = 15

DEV_MODEM	= $02	; modem device
SA_MODEM	= $03	; modem secondary address

HILITE		= $02	; extension: draw next char reverse
SETCSR		= $03
CR		= $0d
LCKCASE		= $08
LOCASE		= $0e
CSR_DOWN	= $11
RVSON		= $12
HOME		= $13
DEL		= $14
CSR_RIGHT	= $1d
CSR_UP		= $91
RVSOFF		= $92
CLR		= $93
INST		= $94
CSR_LEFT	= $9d
UNDERLINE	= $a4

BLACK		= $90
WHITE		= $05
RED		= $1c
CYAN		= $9f
PURPLE		= $9c
GREEN		= $1e
BLUE		= $1f
YELLOW		= $9e
ORANGE		= $81
BROWN		= $95
LTRED		= $96
DKGRAY		= $97
GRAY		= $98
LTGREEN		= $99
LTBLUE		= $9a
LTGRAY		= $9b

CURSOR	= '_'	; cursor, ASCII "_"

MODEM_TYPE_USERPORT	= 0
MODEM_TYPE_UP9600	= 1
MODEM_TYPE_SWIFTLINK_DE	= 2
MODEM_TYPE_SWIFTLINK_DF	= 3
MODEM_TYPE_SWIFTLINK_D7	= 4

BAUD_300	= 0
BAUD_1200	= 1
BAUD_2400	= 2
BAUD_4800	= 3
BAUD_9600	= 4
BAUD_19200	= 5
BAUD_38400	= 6

PROTOCOL_PUNTER		= 0
PROTOCOL_XMODEM		= 1
PROTOCOL_XMODEM_CRC	= 2
