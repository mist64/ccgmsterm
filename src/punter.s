; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; PUNTER transfer protocol
;
; The original CCGMS Term contained a re-assembled version of the PUNTER
; protocol. It has been replaced by the original source and its comments from
;     https://www.lemon64.com/forum/viewtopic.php?t=56823
;     https://groups.google.com/g/net.micro.cbm/c/NWEcf_15nkk/m/MKtq7fyetMYJ
;     [Message-ID: <692@utcs.UUCP>]
; with the CCGMS Term patches applied.

lastch	= inpbuf
pnt11	= $028d

startloc	= $c000
c64	= 1
pnta	= $62
bufptr	= $64
stat	= $96

;codebuf	             	; buffer for incoming 3 chr codes
bitpnt		= codebuf+$03	; bit pointer for allowable matches
bitcnt		= codebuf+$04	; bit counter (0 to 4)
bitpat		= codebuf+$05	; bit pattern for searches
timer1		= codebuf+$06	; timer for non-received characters (2)
gbsave		= codebuf+$08	; location to save good bad signal needed
bufcount	= codebuf+$09	; number of chrs to buffer into block
delay		= codebuf+$0b	; delay for wait period
skpdelay	= codebuf+$0c	; delay skip counter
endflag		= codebuf+$0d	; flag to indicate last block
check		= codebuf+$0e	; save place for checksum (4)
check1		= codebuf+$12	; secondary checksum holding place (4)
bufidx		= codebuf+$16	; index of current buffer (0 or 1)
recsize		= codebuf+$17	; size of received buffer
maxsize		= codebuf+$18	; maximum block size
blocknum	= codebuf+$19	; block number (2)
filetype	= codebuf+$1b	; file type (from basic)
stack		= codebuf+$1c	; stack pointer at entry
dontdash	= codebuf+$1d	; flag to suppress dashes and colons
specmode	= codebuf+$1e	; flag to send special start code
buffer		= $0400      	; buffer for block

;
; header offsets
;
; checksums	= 0-3
POS_BLKSIZE	= 4
POS_BLKNUM	= 5 ; & 6
POS_PAYLOAD	= 7

; [XXX get rid of jump table nonsense]
punter_accept:		; [XXX unused]
	lda #00
	.byte $2c
punter_receive:
	lda #03
	.byte $2c
punter_transmit:
	lda #06
	.byte $2c
punter_rectype:
	lda #09
	.byte $2c
punter_trantype:
	lda #12
	.byte $2c
punter_terminal:	; [XXX unused]
	lda #15
	nop
	jmp over

punter_reset:
	jmp reset	; [XXX remove indirection]

over:
	sta pnta
	tsx
	stx stack
	lda #<table
	clc
	adc pnta
	sta jmppoint+1
	lda #>table
	adc #0
	sta jmppoint+2
jmppoint:
	jmp table

table	jmp accept	; [XXX unused]
	jmp receive
	jmp transmit
	jmp rectype
	jmp trantype
	jmp terminal	; [XXX unused]

;----------------------------------------------------------------------
codes:
CODE_GOO = * - codes
	.byte "GOO"
CODE_BAD = * - codes
	.byte "BAD"
CODE_ACK = * - codes
	.byte "ACK"
CODE_S_B = * - codes
	.byte "S/B"
CODE_SYN = * - codes
	.byte "SYN"
CODE_XXX = * - codes

MASK_GOO = 1 << 0
MASK_BAD = 1 << 1
MASK_ACK = 1 << 2
MASK_S_B = 1 << 3
MASK_SYN = 1 << 4

;----------------------------------------------------------------------
; read and check code from modem
accept:
	; save required bit pattern
	sta bitpat
	; clear 3 char window
	lda #0
	sta codebuf
	sta codebuf+1
	sta codebuf+2

accept_loop:
	; clear timer
	lda #0
	sta timer1
	sta timer1+1

@loop1:	; get char from modem
	jsr check_abort
	jsr pmodget
	lda stat
	bne @nodata	; nothing received

	; shift 3 char window, add new char
	lda codebuf+1
	sta codebuf
	lda codebuf+2
	sta codebuf+1
	lda lastch
	sta codebuf+2

	lda #0
	sta bitcnt	; clear bit counter
	lda #1
	sta bitpnt	; initialize bit pointer

@loop2:	; check this code word?
	lda bitpat
	bit bitpnt
	beq @skip	; no

	; compare code word
	ldy bitcnt
	ldx #0
:	lda codebuf,x
	cmp codes,y
	bne @skip
	iny
	inx
	cpx #3
	bne :-
	jmp @match

@skip:	; next code word
	asl bitpnt	; next mask
	lda bitcnt
	clc
	adc #3
	sta bitcnt	; next code word ptr
	cmp #CODE_XXX
	bne @loop2
	jmp check_cancel; loop to accept_loop unless cancelled

@match:	lda #$FF	; set timer to -1
	sta timer1
	sta timer1+1
	jmp @loop1	; next char

@nodata:
	inc timer1
	bne :+
	inc timer1+1
:	lda timer1+1
	ora timer1
	beq @end	; timer reached 0 -> match found

	lda timer1	; [XXX does nothing]
	cmp #7		; [XXX does nothing]

	lda timer1+1
	cmp #20		; 20*256 = 5120 iterations yet?
	jcc @loop1	; no, next char

	lda #1		; timeout
	sta stat
	jmp dodelay

@end:	lda #0
	sta stat	; OK
	rts

	nop		; [XXX unused]

;----------------------------------------------------------------------
; get character from modem
pmodget:
	tya
	pha
	jsr modget
	bcs @1
	sta lastch
	lda #0
	sta stat
	pla
	tay
	jmp @2
@1:	lda #2
	sta stat
	lda #0
	sta lastch
	pla
	tay
@2:	pha
	lda #3
	sta FA		; current device [XXX ???]
	pla
	rts

;----------------------------------------------------------------------
; send a code
sendcode:
	jsr clear232
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout
	ldx #0
:	lda codes,y
	jsr chrout
	iny
	inx
	cpx #3
	bne :-
	jmp clrchn

;----------------------------------------------------------------------
; receive one block, plus handshaking
receive_block:
	sta gbsave	; save "GOO"/"BAD" code
	jsr puntdelay	; ["modded this. handshaking delay"]
	lda #0		; delay 0 on 1 off. [originally was off]
	sta delay

@loop1:	lda #2		; retries
	sta pnta
	ldy gbsave
	jsr sendcode	; send "GOO" or "BAD" code

@loop2:	lda #MASK_ACK
	jsr accept
	lda stat
	beq @again

	dec pnta
	bne @loop2

	jmp @loop1

@again:	; request block
	jsr puntdelay	; ["modded this. handshaking delay"]
	ldy #CODE_S_B
	jsr sendcode

	; EOT?
	lda endflag
	beq @recv

	; EOT
	lda gbsave
	beq @eot	; "GOO", then EOT, otherwise retry

@recv:	; receive block
	lda buffer+POS_BLKSIZE
	sta bufcount
	sta recsize
	jsr recmodem	; wait for block

	; handle status
	lda stat
	cmp #STAT_GOOD	; good block
	beq @good
	cmp #STAT_NODATA; blank input
	beq @again
	cmp #STAT_SHORT	; loss of signal
	beq @good
	cmp #STAT_ACK	; "ACK" signal
	beq @again
@good:	rts

@eot:	; finalize transmission
	; receive "SYN"
	lda #MASK_SYN
	jsr accept
	lda stat
	bne @again	; no -> send "S/B" again

	lda #10		; retries
	sta bufcount
@retry:
	; answer "SYN"
	ldy #CODE_SYN
	jsr sendcode

	; receive "S/B"
	; [XXX checks for single "S/B"; transmit sends it 3x]
	lda #MASK_S_B
	jsr accept
	lda stat
	beq :+

	dec bufcount
	bne @retry

:	rts

;----------------------------------------------------------------------
; transmit one block
transmit_block:
	lda #0		; ["add delay back in"]
	sta delay

@again:	jsr puntdelay	; ["modded this. handshaking delay"]

	; send GOO
	lda specmode
	beq :+
	ldy #CODE_GOO
	jsr sendcode
	jsr puntdelay	; ["modded this. handshaking delay"]
:
	; repeat until we have code from receiver
	lda #MASK_GOO|MASK_BAD|MASK_S_B
	jsr accept
	lda stat
	bne @again	; if no signal, wait again

	; reset flag to send GOO at the start
	lda #0
	sta specmode

	; not GOO: resend old block
	lda bitcnt
	cmp #CODE_GOO
	bne @resend

	; has all data been sent?
	lda endflag
	bne @eot	; yes, send finalize handshake

	inc blocknum
	bne :+
	inc blocknum+1
:
	; is it a pre-created file type header block?
	jsr thisbuf
	ldy #POS_BLKNUM	; [XXX ldy #POS_BLKNUM+1]
	iny
	lda (bufptr),y
	cmp #$ff
	bne @data	; no, create block from disk data

	; file type block: just checksum it, then send it
	lda #1
	sta endflag	; last one
	lda bufidx
	eor #1
	sta bufidx
	jsr thisbuf
	jsr create_dummy_block
	jmp @send

@data:	jsr create_data_block; create block from disk data

@send:	lda #'-'
	.byte $2c
@resend:
	lda #':'
	jsr prtdash

	; send ACK, expect S/B
	ldy #CODE_ACK
	jsr sendcode
	lda #MASK_S_B
	jsr accept
	lda stat
	bne @send

	; get size of block
	jsr thisbuf
	ldy #POS_BLKSIZE
	lda (bufptr),y
	sta bufcount

	; transmit alternate buffer
	jsr altbuf
	jsr clear232
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout
	ldy #0
:	lda (bufptr),y
	jsr chrout
	iny
	cpy bufcount
	bne :-
	jsr clrchn

	lda #0		; not end of transmission
	rts

@eot:	; end of transmission handshake
	lda #'*'
	jsr prtdash

	; send ACK, expect S/B
	ldy #CODE_ACK
	jsr sendcode
	lda #MASK_S_B
	jsr accept
	lda stat
	bne @eot	; if not, resend "ack" signal

	; send SYN, expect SYN
	lda #10		; retries
	sta bufcount
:	ldy #CODE_SYN
	jsr sendcode
	lda #MASK_SYN
	jsr accept
	lda stat
	beq :+
	dec bufcount
	bne :-

	; send S/B, expect anything
:	lda #3		; retries
	sta bufcount
:	ldy #CODE_S_B
	jsr sendcode
	lda #0
	jsr accept	; just wait
	dec bufcount
	bne :-

	lda #1		; end of transmission
	rts

;----------------------------------------------------------------------
STAT_GOOD	= 1 << 0
STAT_NODATA	= 1 << 1
STAT_SHORT	= 1 << 2
STAT_ACK	= 1 << 3

;----------------------------------------------------------------------
;receive a block from the modem, raw
;
; stat returns with:
;
;  STAT_GOOD	buffered all characters successfully
;  STAT_NODATA	bit 1 - no characters received at all
;  STAT_SHORT	insufficient characters received
;  STAT_ACK	"ACK" signal received
;
recmodem:
	ldy #0		; start index

@loop1:	lda #0		; clear timers
	sta timer1
	sta timer1+1

@loop2:	jsr check_abort
	jsr pmodget
	lda stat
	bne @nochr	; no character received

	lda lastch
	sta buffer,y	; save chr in buffer
	cpy #3		; chr one of the first 3
	bcs @rcm3	; no, skip code check

	sta codebuf,y	; save chr in code buffer
	cpy #2		; on the 3rd chr
	bne @rcm3	; no, don't look at chrs yet

	; check for a "ACK" code
	lda codebuf
	cmp #'A'
	bne @rcm3
	lda codebuf+1
	cmp #'C'
	bne @rcm3
	lda codebuf+2
	cmp #'K'
	beq @ack1

@rcm3:	iny		; inc index
	cpy bufcount	; buffered all chrs
	bne @loop1	; no, buffer next

	lda #STAT_GOOD	; buffered all characters successfully
	sta stat
	rts

@ack1:	; "ACK" found, set timer to -1
	lda #$ff
	sta timer1
	sta timer1+1
	jmp @loop2	; see if there is another chr

@nochr:	inc timer1	; inc timer
	bne :+
	inc timer1+1
:	lda timer1
	ora timer1+1	; timer now at zero
	beq @ack2	; "ACK" found with no following chrs

	lda timer1	; [XXX does nothing]
	cmp #6		; [XXX does nothing]

	lda timer1+1
	cmp #16		; time out yet
	bne @loop2	; no, get next chr

	lda #STAT_NODATA; no characters received at all
	sta stat
	cpy #0
	beq :+
	lda #STAT_SHORT	; insufficient characters received
	sta stat
:	jmp dodelay

@ack2:	lda #STAT_ACK	; "ack" signal received
	sta stat
	rts

;----------------------------------------------------------------------
; create next data block for transmission
create_data_block:
	lda bufidx
	eor #1
	sta bufidx
	jsr thisbuf	; read block into "this" buffer

	; set block number
	ldy #POS_BLKNUM
	lda blocknum
	clc
	adc #1
	sta (bufptr),y	; lo
	iny
	lda blocknum+1
	adc #0
	sta (bufptr),y	; hi
	jsr disablexfer

	; read data from file into block
	ldx #LFN_FILE
	jsr chkin
	ldy #POS_PAYLOAD
:	jsr chrin
	sta (bufptr),y
	iny
	jsr readst
	bne @eof	; EOF or error
	cpy maxsize
	bne :-

	; block full
	tya
	pha		; save size of block
	jmp create_block_cont

@eof:	tya
	pha		; save size of block

	; last block: set block number (hi) to $FF
	ldy #POS_BLKNUM
	iny
	lda #$ff
	sta (bufptr),y
	jmp create_block_cont

;----------------------------------------------------------------------
; create dummy (header) block
create_dummy_block:
	pha		; save size of block
			; [XXX this is garbage data]

;----------------------------------------------------------------------
; common code for block creation
create_block_cont:
	jsr clrchn
	jsr reset
	jsr dodelay2
	jsr reset

	; set bufcount for checksum
	ldy #POS_BLKSIZE
	lda (bufptr),y
	sta bufcount

	; put next block size into current block
	jsr altbuf
	pla
	ldy #POS_BLKSIZE
	sta (bufptr),y

	; checksum
	jsr checksum	; [XXX jmp]
	rts

;----------------------------------------------------------------------
; set bufptr to current buffer
thisbuf:
	lda #<buffer
	sta bufptr
	lda bufidx
	clc
	adc #>buffer
	sta bufptr+1
	rts

;----------------------------------------------------------------------
; set bufptr to alternate buffer
altbuf:
	lda #<buffer
	sta bufptr
	lda bufidx
	eor #1
	clc
	adc #>buffer
	sta bufptr+1
	rts

;----------------------------------------------------------------------
; calculate checksum
checksum:
	lda #0
	sta check1
	sta check1+1
	sta check1+2
	sta check1+3
	ldy #POS_BLKSIZE
@1:	lda check1
	clc
	adc (bufptr),y
	sta check1
	bcc :+
	inc check1+1
:	lda check1+2
	eor (bufptr),y
	sta check1+2
	lda check1+3
	rol		;set or clear carry flag
	rol check1+2
	rol check1+3
	iny
	cpy bufcount
	bne @1
	ldy #0
	lda check1
	sta (bufptr),y
	iny
	lda check1+1
	sta (bufptr),y
	iny
	lda check1+2
	sta (bufptr),y
	iny
	lda check1+3
	sta (bufptr),y
	rts

;----------------------------------------------------------------------
; transmit a file
transmit:
	lda #0
	sta endflag
	sta skpdelay
	sta dontdash
	lda #1
	sta bufidx
	lda #$ff
	sta blocknum
	sta blocknum+1

	; create first block: no payload
	jsr altbuf
	ldy #POS_BLKSIZE
	lda #POS_PAYLOAD
	sta (bufptr),y
	; and block number 0
	jsr thisbuf
	ldy #POS_BLKNUM
	lda #0
	sta (bufptr),y
	iny
	sta (bufptr),y

:	jsr transmit_block
	beq :-

rec3:	lda #0
	sta lastch
	rts

;----------------------------------------------------------------------
; receive file contents
receive:
	lda #1
	sta blocknum
	lda #0
	sta blocknum+1
	sta endflag
	sta bufidx
	sta buffer+POS_BLKNUM
	sta buffer+POS_BLKNUM+1
	sta skpdelay

	lda #POS_PAYLOAD
	sta buffer+POS_BLKSIZE

	lda #CODE_GOO
@loop:	jsr receive_block

	lda endflag
	bne rec3

	; CRC ok?
	jsr match
	bne @crcbad

	jsr clrchn

	; skip if empty
	lda bufcount
	cmp #POS_PAYLOAD
	beq @skip

	; write to disk
	jsr disablexfer
	ldx #LFN_FILE
	jsr chkout
	ldy #POS_PAYLOAD
:	lda buffer,y
	jsr chrout
	iny
	cpy bufcount
	bne :-
	jsr clrchn

@skip:
	; blocknum (hi) == $FF? then EOT
	lda buffer+POS_BLKNUM+1
	cmp #$ff
	bne :+
	lda #1
	sta endflag
	lda #'*'
	.byte $2c
:	lda #'-'
	jsr goobad
	jsr reset
	lda #0
	jmp @loop

@crcbad:
	jsr clrchn
	lda #':'
	jsr goobad
	lda recsize
	sta buffer+POS_BLKSIZE
	lda #CODE_BAD
	jmp @loop

;----------------------------------------------------------------------
; verify checksums
match:
	lda buffer
	sta check
	lda buffer+1
	sta check+1
	lda buffer+2
	sta check+2
	lda buffer+3
	sta check+3
	jsr thisbuf
	lda recsize
	sta bufcount
	jsr checksum
	lda buffer
	cmp check
	bne @bad
	lda buffer+1
	cmp check+1
	bne @bad
	lda buffer+2
	cmp check+2
	bne @bad
	lda buffer+3
	cmp check+3
	bne @bad
	lda #0
	rts

@bad:	lda #1
	rts

;----------------------------------------------------------------------
; receive file type block
rectype:
	lda #0
	sta blocknum
	sta blocknum+1
	sta endflag
	sta bufidx
	sta skpdelay

	; [XXX ???]
	lda #POS_PAYLOAD	; [XXX lda #POS_PAYLOAD+1]
	clc
	adc #1
	sta buffer+POS_BLKSIZE

	; receive file type block
	lda #CODE_GOO
@loop:	jsr receive_block
	lda endflag
	bne @end

	; CRC ok?
	jsr match
	bne @crcbad

	; extract file type
	lda buffer+POS_PAYLOAD
	sta filetype
	lda #1
	sta endflag
	lda #CODE_GOO	; [XXX jmp one instruction above]
	jmp @loop

@crcbad:
	lda recsize
	sta buffer+POS_BLKSIZE
	lda #CODE_BAD
	jmp @loop

@end:	lda #0
	sta lastch
	rts

;----------------------------------------------------------------------
; transmit file type block
trantype:
	lda #0
	sta endflag
	sta skpdelay
	lda #1
	sta bufidx
	sta dontdash
	lda #255
	sta blocknum
	sta blocknum+1

	; set file type block size: one payload byte
	jsr altbuf
	ldy #POS_BLKSIZE
	lda #POS_PAYLOAD	; [XXX lda #POS_PAYLOAD+1]
	clc
	adc #1
	sta (bufptr),y

	; set block number $FFFF
	jsr thisbuf
	ldy #POS_BLKNUM
	lda #255
	sta (bufptr),y
	iny
	sta (bufptr),y

	; fill file type
	ldy #POS_PAYLOAD
	lda filetype
	sta (bufptr),y

	; flag: send GOO once at the start
	lda #1
	sta specmode

:	jsr transmit_block
	beq :-

	lda #0
	sta lastch	; no user abort
	rts

;----------------------------------------------------------------------
; timing delay
dodelay:
	inc skpdelay
	lda skpdelay
	cmp #3
	bcc :+
	lda #0
	sta skpdelay
:
;	lda delay	; delay is always forced on no matter what now
;	beq dodelay2
;	bne dod3
	nop

dodelay2:
	ldx #0
@1:	ldy #0
@2:	iny
	bne @2
	inx
	;cpx #120
	bne @1
dod3	rts

;----------------------------------------------------------------------
; print dash, colon, or star
prtdash:
	pha
	lda blocknum
	ora blocknum+1
	beq :+
	lda dontdash
	bne :+
	pla
	jsr goobad
	pha
:	pla
	rts

;----------------------------------------------------------------------
; reset RS232 port
reset:
	jsr enablexfer
terminal:
	rts

; [XXX patch; should be inline]
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; cancel transmission if we encounter 3 CRs in a row
check_cancel:
	ldx #0
:	lda buffer,x
	cmp #CR
	bne :+
	inx
	cpx #3
	bcc :-
	jmp punter_cancel
:	jmp accept_loop
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

;----------------------------------------------------------------------
; check for commodore key
check_abort:
	lda SHFLAG	; is commodore
	cmp #SHFLAG_CBM	; key down
	bne @1
@2:	pla
	tsx
	cpx stack
	bne @2
@1:	lda #1
	sta lastch
	rts

;----------------------------------------------------------------------
punter_cancel:
	tsx		; [XXX just assign stack pointer]
	cpx stack
	beq :+
	pla
	sec
	bcs punter_cancel
:	lda #$80
	sta lastch
	jsr clrchn	; [XXX jmp]
	rts

	brk		; [XXX unused]
	brk
