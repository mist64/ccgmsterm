; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; RS232 Userport Driver, 300-2400 baud
;  based on Novaterm 9.6
;

; calls from outside code:
;  rsuser_setup
;  rsuser_enable
;  rsuser_disable
;  rsuser_getxfer

; KERNAL
ENABL	= $02a1

inbits	= $a8
inbyte	= $aa
outbits	= $b4
outbit	= $b5
outbyte	= $b6

;----------------------------------------------------------------------
rsuser_setup:
	sei

	jsr rsuser_setbaud

	lda #<nmi64
	ldy #>nmi64
	sta $0318 ; NMINV
	sty $0319

	lda #<rsout
	ldx #>rsout
	sta $0326 ; IBSOUT
	stx $0327

	lda #<rsget
	ldx #>rsget
	sta $032a ; IGETIN
	stx $032b

	cli

	jmp clear232

;----------------------------------------------------------------------
bdloc
bntsc	.word 3408,851,425	; NTSC: transmit times
	.word 4915,1090,459	; NTSC: startup bit times
	.word 3410,845,421	; NTSC: full bit times
bpal	.word 3283,820,409	; PAL:  transmit times
	.word 4735,1050,442	; PAL:  startup bit times
	.word 3285,814,406	; PAL:  full bit times
OFFSET		= bpal-bntsc

;----------------------------------------------------------------------
isbyte:
	.byte 0
lastring:		; [XXX unused]
	.byte 0

;----------------------------------------------------------------------
; new GETIN
rsget:
	lda DFLTN
	cmp #2		; see if default input is modem
	beq jbgetrs
	jmp ogetin	; nope, go back to original

jbgetrs	jsr rsuser_getxfer
	bcs :+		; if no character, then return 0 in a
	rts
:	clc
	lda #0
	rts

;----------------------------------------------------------------------
; get byte from serial interface
rsuser_getxfer:
	ldx rhead
	cpx rtail
	beq :+		; skip (empty buffer, return with carry set)
	lda ribuf,x
	pha
	inc rhead
	clc
	pla
:	rts

;----------------------------------------------------------------------
; new NMI handler
nmi64:
	pha
	txa
	pha
	tya
	pha
	cld
	ldx $dd07	; sample timer b hi byte
	lda #$7f	; disable cia nmi's
	sta $dd0d
	lda $dd0d	; read/clear flags
	;bpl notcia	; (restore key)
	cpx $dd07	; timer B timeout?
	ldy $dd01	; sample pin C for receive NMI
	bcs :+		; no timeout
	ora #$02	; set flag
	ora $dd0d	; read flags again (changed since timeout)
:	and ENABL	; mask out non-enabled interrupts
	tax		; bitmask of ints to be serviced
	lsr		; check timer A
	bcc :+
	lda $dd00	; put output bit on pin M
	and #$fb
	ora outbit
	sta $dd00
:	txa		; check flag NMI
	and #$10	; indicates new byte coming in
	beq nmion
strtlo=*+1
	lda #0		; initialize timer B with start bit time
	sta $dd06
strthi=*+1
	lda #0
	sta $dd07
	lda #$11
	sta $dd0f	; start timer B, load latched value to counter
	lda #$12
	eor ENABL
	sta ENABL
	sta $dd0d	; enable flag, timer B interrupts
fulllo=*+1
	lda #0		; latch full bit value for next countdown
	sta $dd06
fullhi=*+1
	lda #0
	sta $dd07
	lda #8
	sta inbits
	jmp chktxd

notcia	;ldy #0
	;jmp rstkey	; or jmp norest

nmion	lda ENABL	; receive a bit
	sta $dd0d
	txa
	and #$02
	beq chktxd
	tya
	lsr
	ror inbyte
	dec inbits
	bne txd
	lda inbyte
	ldx rtail	; index to buffer
	sta ribuf,x	; and store it
	inc rtail	; move index to next slot
	lda #0
	sta $dd0f
	lda #$12
switch	ldy #$7f
	sty $dd0d
	sty $dd0d
	eor ENABL
	sta ENABL
	sta $dd0d
txd	txa
	lsr
chktxd	bcc nmiflow
	dec outbits
	bmi endbyte
	lda #4
	ror outbyte
	bcs :+
	lda #0
:	sta outbit
nmiflow	lda inbits
	and #8
	beq :+
	clc
:	pla
	tay
	pla
	tax
	pla
	rti

endbyte	lda #0
	sta isbyte
	ldx #0		;  turn transmit int off
	stx $dd0e
	lda #1
	bne switch
	jmp rsuser_disable

;----------------------------------------------------------------------
; new BSOUT
rsout	pha
	lda DFLTO
	cmp #2
	bne notmod
	pla
	sta rsotm
	stx rsotx
	sty rsoty
	lda rsotm
	sta outbyte
	lda #0
	sta outbit
	lda #9
	sta outbits
	lda #$ff
	sta isbyte
xmitlo=*+1
	lda #0
	sta $dd04
xmithi=*+1
	lda #0
	sta $dd05
	lda #$11
	sta $dd0e
	lda #$81
change	sta $dd0d
	php
	sei
	ldy #$7f
	sty $dd0d
	sty $dd0d
	ora ENABL
	sta ENABL
	sta $dd0d
	plp
rsout3	bit isbyte
	bmi rsout3
ret1	clc
	ldx rsotx
	ldy rsoty
	lda rsotm
	rts
notmod	pla
	jmp  oldout

;----------------------------------------------------------------------
; disable rs232 input
rsuser_disable:
	pha
:	;lda ENABL;this fucks shit up... get rid of it...
	;and #$03
	;bne :-
	lda isbyte
	bne :-
	lda #$10
	sta $dd0d
	lda #2
	and ENABL
	bne :-
	sta ENABL
	pla
	rts

;----------------------------------------------------------------------
; enable rs232 input
rsuser_enable:
	stx rsotx
	sty rsoty
	sta rsotm
	lda ENABL
	and #$12
	bne ret1
	sta $dd0f
	lda #$90
	jmp change

;----------------------------------------------------------------------
rsuser_setbaud:
	lda baud_rate
	asl
	ldy is_pal_system
	beq :+
	clc
	adc #OFFSET
:	tay
	lda bdloc,y
	sta xmitlo
	lda bdloc+1,y
	sta xmithi
	lda bdloc+6,y
	sta strtlo
	lda bdloc+7,y
	sta strthi
	lda bdloc+12,y
	sta fulllo
	lda bdloc+13,y
	sta fullhi
	rts
