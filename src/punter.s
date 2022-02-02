;
; PUNTER
;
; The original CCGMS Term contained a re-assembled version of the PUNTER
; protocol. It has been replaced by the original source and its comments from
;     https://www.lemon64.com/forum/viewtopic.php?t=56823
;     https://groups.google.com/g/net.micro.cbm/c/NWEcf_15nkk/m/MKtq7fyetMYJ
;     [Message-ID: <692@utcs.UUCP>]
; with the CCGSM Term patches applied.

lastch	= inpbuf
pnt11	= $028d
pnt14	= $02a1

startloc	= $c000
c64	= 1
pnta	= $62
pntb	= $64
stat	= $96

;codebuf	              ;buffer for incoming 3 chr codes
bitpnt	= codebuf+$03 ;bit pointer for allowable matches
bitcnt	= codebuf+$04 ;bit counter (0 to 4)
bitpat	= codebuf+$05 ;bit pattern for searches
timer1	= codebuf+$06 ;timer for non-received characters (2)
gbsave	= codebuf+$08 ;location to save good bad signal needed
bufcount	= codebuf+$09 ;number of chrs to buffer into block
delay	= codebuf+$0b ;delay for wait period
skpdelay	= codebuf+$0c ;delay skip counter
endflag	= codebuf+$0d ;flag to indicate last block
check	= codebuf+$0e ;save place for checksum (4)
check1	= codebuf+$12 ;secondary checksum holding place (4)
bufpnt	= codebuf+$16 ;pointer to current buffer
recsize	= codebuf+$17 ;size of received buffer
maxsize	= codebuf+$18 ;maximum block size
blocknum	= codebuf+$19 ;block number (2)
filetype	= codebuf+$1b ;file type (from basic)
stack	= codebuf+$1c ;stack pointer at entry
dontdash	= codebuf+$1d ;flag to suppress dashes and colons
specmode	= codebuf+$1e ;flag to send special start code
buffer	= $0400       ;buffer for block
;
;buffer positions
;
sizepos	= 4
numpos	= 5
datapos	= 7

punter	; source code $0812
;referenced by old $c000 addresses
p49152	lda #00   ;sys 49152
	.byte $2c
p49155	lda #03   ;sys 49155
	.byte $2c
p49158	lda #06   ;sys 49158
	.byte $2c
p49161	lda #09   ;sys 49161
	.byte $2c
p49164	lda #12   ;sys 49164
	.byte $2c
p49167	lda #15   ;sys 49167
	nop
	jmp over
punter_reset	jmp reset
;
over	sta pnta
	tsx
	stx stack
	lda #<table
	clc
	adc pnta
	sta jmppoint+1
	lda #>table
	adc #$00
	sta jmppoint+2
jmppoint	jmp table
;
table	jmp accept
	jmp receive
	jmp transmit
	jmp rectype
	jmp trantype
	jmp terminal
;
codes	.byte 'GOO'
	.byte 'BAD'
	.byte 'ACK'
	.byte 'S/B'
	.byte 'SYN'
;
;accept characters and check for codes
;
accept	sta bitpat    ;save required bit pattern
	lda #$00
	sta codebuf
	sta codebuf+1
	sta codebuf+2
cd1	lda #$00
	sta timer1 ;clear timer
	sta timer1+1
cd2	jsr exit
	jsr getnum ;get#5,a$
	lda stat
	bne cd3   ;if no chr, do timer check
	lda codebuf+1
	sta codebuf
	lda codebuf+2
	sta codebuf+1
	lda lastch
	sta codebuf+2
	lda #$00
	sta bitcnt ;clear bit counter
	lda #$01
	sta bitpnt ;initialize bit pointer
cd4	lda bitpat    ;look at bit pattern
	bit bitpnt ;is bit set
	beq cd5   ;no, don't check this code word
	ldy bitcnt
	ldx #$00
cd6	lda codebuf,x
	cmp codes,y
	bne cd5
	iny
	inx
	cpx #$03
	bne cd6
	jmp cd7
;
cd5	asl bitpnt    ;shift bit pointer
	lda bitcnt
	clc
	adc #$03
	sta bitcnt
	cmp #15
	bne cd4
	jmp cd1b
;
cd7	lda #255
	sta timer1
	sta timer1+1
	jmp cd2
;
cd3	inc timer1
	bne cd9
	inc timer1+1
cd9	lda timer1+1
	ora timer1
	beq cd8
	lda timer1
	cmp #$07
	lda timer1+1
	cmp #20
	jcc cd2
	lda #$01
	sta stat
	jmp dodelay
;
cd8	lda #$00
	sta stat
	rts
;
;get# for c64
;
getnum1	nop
getnum	tya
	pha
	jsr modget
	bcs get1
	sta lastch
	lda #$00
	sta stat
	pla
	tay
	jmp dorts
;
get1	lda #$02
	sta stat
	lda #$00
	sta lastch
	pla
	tay
;
dorts	pha
	lda #$03
	sta $ba
	pla
	rts
;
;send a code
;
sendcode
	jsr clear232
	jsr enablexfer
	ldx #$05
	jsr chkout
	ldx #$00
sn1	lda codes,y
	jsr chrout
	iny
	inx
	cpx #$03
	bne sn1
	jmp clrchn
;
;do handshaking for reception end
;
rechand	sta gbsave    ;save good or bad signal as needed
	jsr puntdelay;modded this;modded this. handshaking delay
	lda #$00;delay 0 on 1 off. originally was off
	sta delay
rc1	lda #$02
	sta pnta
	ldy gbsave
	jsr sendcode ;send g/b signal
rc9	lda #%00100   ;allow "ack" signals
	jsr accept ;wait for code
	lda stat
	beq rc2   ;if ok, send g/b signal again
	dec pnta
	bne rc9
	jmp rc1
;
rc2	jsr puntdelay;modded this;modded this. handshaking delay
	ldy #$09
	jsr sendcode ;send "s/b" code
	lda endflag
	beq rc5
	lda gbsave
	beq rc6
rc5	lda buffer+sizepos
	sta bufcount
	sta recsize
	jsr recmodem ;wait for block
	lda stat
	cmp #%0001 ;check for good block
	beq rc4
	cmp #%0010 ;check for blank input
	beq rc2
	cmp #%0100 ;check for loss of signal
	beq rc4
	cmp #%1000 ;check for "ack" signal
	beq rc2
rc4	rts
;
rc6	lda #%10000   ;wait for "syn" signal
	jsr accept
	lda stat
	bne rc2   ;if not, send "s/b" again
	lda #10
	sta bufcount
rc8	ldy #12       ;send "syn" signal
	jsr sendcode
	lda #%01000 ;wait for "s/b" signal
	jsr accept
	lda stat
	beq rc7
	dec bufcount
	bne rc8
rc7	rts
;
;do handshaking for transmission end
;
tranhand	lda #$00;add delay back in
	sta delay
tx2	jsr puntdelay;modded this. handshaking delay
	lda specmode
	beq tx20
	ldy #$00
	jsr sendcode ;send a "goo" signal
	jsr puntdelay;modded this. handshaking delay
tx20	lda #%01011   ;allow "goo", "bad", and "s/b"
	jsr accept ;wait for codes
	lda stat
	bne tx2   ;if no signal, wait again
	lda #$00
	sta specmode
	lda bitcnt
	cmp #$00  ;"good" signal
	bne tx10  ;no, resend old block
	lda endflag
	bne tx4
	inc blocknum
	bne tx7
	inc blocknum+1
tx7	jsr thisbuf
	ldy #numpos ;block number high order part
	iny
	lda (pntb),y
	cmp #255
	bne tx3
	lda #$01
	sta endflag
	lda bufpnt
	eor #$01
	sta bufpnt
	jsr thisbuf
	jsr dummybl1
	jmp tx1
;
tx3	jsr dummyblk  ;yes, get new block
tx1	lda #"-"
	.byte $2c
tx10	lda #":"
	jsr prtdash
	ldy #$06
	jsr sendcode ;send "ack" code
	lda #%01000 ;allow only "s/b" code
	jsr accept ;wait for code
	lda stat
	bne tx1
	jsr thisbuf
	ldy #sizepos ;block size
	lda (pntb),y
	sta bufcount
	jsr altbuf
	jsr clear232
	jsr enablexfer
	ldx #$05
	jsr chkout
	ldy #$00
tx6	lda (pntb),y  ;transmit alternate buffer
	jsr chrout
	iny
	cpy bufcount
	bne tx6
	jsr clrchn
	lda #$00
	rts
;
tx4	lda #"*"
	jsr prtdash
	ldy #$06
	jsr sendcode ;send "ack" signal
	lda #%01000
	jsr accept ;wait for "s/b" signal
	lda stat
	bne tx4   ;if not, resend "ack" signal
	lda #10
	sta bufcount
tx5	ldy #12
	jsr sendcode ;send "syn" signal
	lda #%10000
	jsr accept ;wait for "syn" signal back
	lda stat
	beq tx8
	dec bufcount
	bne tx5
tx8	lda #$03
	sta bufcount
tx9	ldy #$09
	jsr sendcode ;send "s/b" signal
	lda #$00000
	jsr accept ;just wait
	dec bufcount
	bne tx9
	lda #$01
	rts
;
;receive a block from the modem
;
; stat returns with:
;
;  bit 0 - buffered all characters successfully
;  bit 1 - no characters received at all
;  bit 2 - insufficient characters received
;  bit 3 - "ack" signal received
;
recmodem	ldy #$00      ;start index
rcm5	lda #$00      ;clear timers
	sta timer1
	sta timer1+1
rcm1	jsr exit
	jsr getnum ;get a chr from the modem
	lda stat
	bne rcm2  ;no character received
	lda lastch
	sta buffer,y ;save chr in buffer
	cpy #$03  ;chr one of the first 3
	bcs rcm3  ;no, skip code check
	sta codebuf,y ;save chr in code buffer
	cpy #$02  ;on the 3rd chr
	bne rcm3  ;no, don't look at chrs yet
	lda codebuf ;check for a "ack" signal
	cmp #"A"
	bne rcm3
	lda codebuf+1
	cmp #"C"
	bne rcm3
	lda codebuf+2
	cmp #"K"
	beq rcm4  ;"ack" found
rcm3	iny           ;inc index
	cpy bufcount ;buffered all chrs
	bne rcm5  ;no, buffer next
	lda #%0001 ;yes, return bit 0 set
	sta stat
	rts
;
rcm4	lda #$ff      ;"syn" found, set timer to -1
	sta timer1
	sta timer1+1
	jmp rcm1  ;see if there is another chr
;
rcm2	inc timer1    ;inc timer
	bne rcm6
	inc timer1+1
rcm6	lda timer1
	ora timer1+1 ;timer now at zero
	beq rcm7  ;"syn" found with no following chrs
	lda timer1
	cmp #$06
	lda timer1+1
	cmp #16 ;time out yet
	bne rcm1  ;no, get next chr
	lda #%0010 ;yes, set bit 1
	sta stat
	cpy #$00
	beq rcm9
	lda #%0100 ;but if chrs received, set bit 2
	sta stat
rcm9	jmp dodelay
;
rcm7	lda #%1000    ;"ack" found, set bit 2
	sta stat
	rts
;
;create dummy block for transmission
;
dummyblk	lda bufpnt
	eor #$01
	sta bufpnt
	jsr thisbuf ;read block into "this" buffer
	ldy #numpos ;block number
	lda blocknum
	clc
	adc #$01
	sta (pntb),y ;set block number low part
	iny
	lda blocknum+1
	adc #$00
	sta (pntb),y ;set block number high part
	jsr disablexfer
	ldx #$02
	jsr chkin
	ldy #datapos ;actual block
db1	jsr chrin
	sta (pntb),y
	iny
	jsr readst
	bne db4
	cpy maxsize
	bne db1
	tya
	pha
	jmp db5
;
db4	tya
	pha
	ldy #numpos ;block number
	iny       ;high part
	lda #255
	sta (pntb),y
	jmp db5
;
dummybl1	pha           ;save size of just read block
db5	jsr clrchn
	jsr reset
	jsr dod2
	jsr reset
	ldy #sizepos ;block size
	lda (pntb),y
	sta bufcount ;set bufcount for checksum
	jsr altbuf
	pla
	ldy #sizepos ;block size
	sta (pntb),y
	jsr checksum
	rts
;
;set pointers for current buffer
;
thisbuf	lda #<buffer
	sta pntb
	lda bufpnt
	clc
	adc #>buffer
	sta pntb+1
	rts
;
;set pointer b for alternate buffer
;
altbuf	lda #<buffer
	sta pntb
	lda bufpnt
	eor #$01
	clc
	adc #>buffer
	sta pntb+1
	rts
;
;calculate checksum
;
checksum	lda #$00
	sta check1
	sta check1+1
	sta check1+2
	sta check1+3
	ldy #sizepos
cks1	lda check1
	clc
	adc (pntb),y
	sta check1
	bcc cks2
	inc check1+1
cks2	lda check1+2
	eor (pntb),y
	sta check1+2
	lda check1+3
	rol a     ;set or clear carry flag
	rol check1+2
	rol check1+3
	iny
	cpy bufcount
	bne cks1
	ldy #$00
	lda check1
	sta (pntb),y
	iny
	lda check1+1
	sta (pntb),y
	iny
	lda check1+2
	sta (pntb),y
	iny
	lda check1+3
	sta (pntb),y
	rts
;
;transmit a program
;
transmit	lda #$00
	sta endflag
	sta skpdelay
	sta dontdash
	lda #$01
	sta bufpnt
	lda #$ff
	sta blocknum
	sta blocknum+1
	jsr altbuf
	ldy #sizepos ;block size
	lda #datapos
	sta (pntb),y
	jsr thisbuf
	ldy #numpos ;block number
	lda #$00
	sta (pntb),y
	iny
	sta (pntb),y
trm1	jsr tranhand
	beq trm1
rec3	lda #$00
	sta lastch
	rts
;
;receive a file
;
receive	lda #$01
	sta blocknum
	lda #$00
	sta blocknum+1
	sta endflag
	sta bufpnt
	sta buffer+numpos ;block number
	sta buffer+numpos+1
	sta skpdelay
	lda #datapos
	sta buffer+sizepos ;block size
	lda #$00
rec1	jsr rechand
	lda endflag
	bne rec3
	jsr match ;do checksums match
	bne rec2  ;no
	jsr clrchn
	lda bufcount
	cmp #datapos
	beq rec7
	jsr disablexfer
	ldx #$02
	jsr chkout
	ldy #datapos
rec6	lda buffer,y
	jsr chrout
	iny
	cpy bufcount
	bne rec6
	jsr clrchn
rec7	lda buffer+numpos+1 ;block number high order part
	cmp #$ff
	bne rec4
	lda #$01
	sta endflag
	lda #"*"
	.byte $2c
rec4	lda #"-"
	jsr goobad
	jsr reset
	lda #$00
	jmp rec1
;
rec2	jsr clrchn
	lda #":"
	jsr goobad
	lda recsize
	sta buffer+sizepos
	lda #$03
	jmp rec1
;
;see if checksums match
;
match	lda buffer
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
	bne mtc1
	lda buffer+1
	cmp check+1
	bne mtc1
	lda buffer+2
	cmp check+2
	bne mtc1
	lda buffer+3
	cmp check+3
	bne mtc1
	lda #$00
	rts
;
mtc1	lda #$01
	rts
;
;receive file type block
;
rectype	lda #$00
	sta blocknum
	sta blocknum+1
	sta endflag
	sta bufpnt
	sta skpdelay
	lda #datapos
	clc
	adc #$01
	sta buffer+sizepos
	lda #$00
rct3	jsr rechand
	lda endflag
	bne rct1
	jsr match
	bne rct2
	lda buffer+datapos
	sta filetype
	lda #$01
	sta endflag
	lda #$00
	jmp rct3
;
rct2	lda recsize
	sta buffer+sizepos
	lda #$03
	jmp rct3
;
rct1	lda #$00
	sta lastch
	rts
;
;transmit file type
;
trantype	lda #$00
	sta endflag
	sta skpdelay
	lda #$01
	sta bufpnt
	sta dontdash
	lda #255
	sta blocknum
	sta blocknum+1
	jsr altbuf
	ldy #sizepos ;block size
	lda #datapos
	clc
	adc #$01
	sta (pntb),y
	jsr thisbuf
	ldy #numpos ;block number
	lda #255
	sta (pntb),y
	iny
	sta (pntb),y
	ldy #datapos
	lda filetype
	sta (pntb),y
	lda #$01
	sta specmode
trf1	jsr tranhand
	beq trf1
	lda #$00
	sta lastch
	rts
;
;do delay for timing
;
dodelay	inc skpdelay
	lda skpdelay
	cmp #$03
	bcc dod1
	lda #$00
	sta skpdelay
dod1
	;lda delay;delay is always forced on no matter what now
	;beq dod2
	;bne dod3
	nop
dod2	ldx #$00
lp1	ldy #$00
lp2	iny
	bne lp2
	inx
	;cpx #120
	bne lp1
dod3	rts
;
;print dash, colon, or star
;
prtdash	pha
	lda blocknum
	ora blocknum+1
	beq prtd1
	lda dontdash
	bne prtd1
	pla
	jsr goobad
	pha
prtd1	pla
	rts
;
;reset rs232 port
;
reset
	jsr enablexfer
;
;terminal emulation routine
;
terminal	rts
;
;----------------------------------------------------------------------
cd1b	ldx #$00
pnt112	lda buffer,x
	cmp #$0d
	bne pnt113
	inx
	cpx #$03
	bcc pnt112
	jmp pnt120
pnt113	jmp cd1
;----------------------------------------------------------------------
;
;check for commodore key
;
exit	lda $028d     ;is commodore
	cmp #$02         ;key down
	bne exit1
exit2	pla
	tsx
	cpx stack
	bne exit2
exit1	lda #$01
	sta lastch
	rts
;----------------------------------------------------------------------
pnt120	tsx
	cpx stack
	beq pnt121
	pla
	sec
	bcs pnt120
pnt121	lda #$80
	sta lastch
	jsr clrchn
	rts
;----------------------------------------------------------------------
	brk
	brk
