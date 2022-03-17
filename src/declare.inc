; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Global constants
;

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

buftop	= $c7fd
bufptrreu = $c7fe
buffstreu = $c7ff
xmodem_buffer	= $c800; 1 KB, overlaps with mulfil
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
endpos	= $ac
buffer_ptr	= $b0 ; 2 bytes
buffst	= $b2
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
KEYD	= $0277 ; keyboard buffer
RPTFLA	= $028a	; key repeat flag
KOUNT	= $028b	; counter for timing delay between key repeats
SHFLAG	= $028d ; bitfield: modifier keys currently pressed
 SHFLAG_SHIFT	= 1
 SHFLAG_CBM	= 2
 SHFLAG_CTRL	= 4
KEYLOG	= $028f
MODE	= $0291
RIDBE   = $029b
RIDBS   = $029c
RODBS   = $029d
RODBE   = $029e
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
findfn	= $f30f
devnum	= $f31f
nofile	= $f701
COLTAB  = $e8da	; PETSCII codes for the colors 0-15
LDTB2	= $ecf0	; line offsets low

; logical file numbers
LFN_FILE	= 2	; for upload/download
LFN_PRINTER     = 4	; printing buffers
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

PROTOCOL_PUNTER		= 0
PROTOCOL_XMODEM		= 1
PROTOCOL_XMODEM_CRC	= 2
PROTOCOL_XMODEM_1K	= 3
