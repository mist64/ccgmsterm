; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; RS232 Swiftlink Driver
;  based on Jeff Brown adaptation of Novaterm version
;

; calls from outside code:
;  sw_setup
;  sw_enable
;  sw_disable
;  sw_getxfer
;  sw_dropdtr

stopsw	= 1
startsw	= 0

swift	= $de00		; can be d to df00 or d700 depending

sw_data	= swift		; swiftlink registers
sw_stat	= swift+1
sw_cmd	= swift+2
sw_ctrl	= swift+3
sw_baud	= swift+7

;----------------------------------------------------------------------
; new NMI handler
nmisw:
	pha
	txa
	pha
	tya
	pha
sm1	lda sw_stat
	and #%00001000	; mask out all but receive interrupt reg
	bne sm2		; get outta here if interrupts are disabled (disk access etc)
	sec		; set carry upon return
	bcs recch1
sm2	lda sw_cmd
	ora #%00000010	; disable receive interrupts
sm3	sta sw_cmd
sm4	lda sw_data
	ldx rtail
	sta ribuf,x
	inc rtail
	inc rfree
	lda rfree
	cmp #200	; check byte count against tolerance
	bcc :+		; is it over the top?
	ldx #stopsw
	stx paused	; x=1 for stop, by the way
	jsr flow
:
sm5	lda sw_cmd
	and #%11111101	; re-enable receive interrupt
sm6	sta sw_cmd
	clc
recch1	pla
	tay
	pla
	tax
	pla
	rti

;----------------------------------------------------------------------
flow:
sm7	lda sw_cmd
	and #%11110011
	cpx #stopsw
	beq fl1
	ora #%00001000
fl1
sm8	sta sw_cmd
	rts

;----------------------------------------------------------------------
swwait:
sm9	lda sw_cmd
	ora #%00001000	; enable transmitter
sm10	sta sw_cmd
sm11	lda sw_stat
	and #%00110000
	beq swwait
	rts

;----------------------------------------------------------------------
sw_disable:
sm12	lda sw_cmd
	ora #%00000010	; disable receive interrupt
sm13	sta sw_cmd
	rts

;----------------------------------------------------------------------
sw_enable:
sm14	lda sw_cmd
	and #%11111101	; enable receive interrupt
sm15	sta sw_cmd
	rts

;----------------------------------------------------------------------
sw_setup:
	sei
;             .------------------------- parity control,
;             :.------------------------ bits 5-7
;             ::.----------------------- 000 = no parity
;             :::
;             :::.------------------- echo mode, 0 = normal (no echo)
;             ::::
;             ::::.----------- transmit interrupt control, bits 2-3
;             :::::.---------- 10 = xmit interrupt off, RTS low
;             ::::::
;             ::::::.------ receive interrupt control, 0 = enabled
;             :::::::
;             :::::::.--- DTR control, 1=DTR low
	lda #%00001001
sm16	sta sw_cmd
;             .------------------------- 0 = one stop bit
;             :
;             :.-------------------- word length, bits 6-7
;             ::.------------------- 00 = eight-bit word
;             :::
;             :::.------------- clock source, 1 = internal generator
;             ::::
;             ::::.----- baud
;             :::::.---- rate
;             ::::::.--- bits   ;1010 == 4800 baud, changes later
;             :::::::.-- 0-3
	lda #%00010000
sm17	sta sw_ctrl

	lda baud_rate
	tax
sm18	lda sw_ctrl
	and #$f0
	ora swbaud,x
sm19	sta sw_ctrl

	lda #<newout
	ldx #>newout
	sta $0326 ; IBSOUT
	stx $0327

	lda #<newin
	ldx #>newin
	sta $032a ; IGETIN
	stx $032b

	lda #<nmisw
	ldx #>nmisw
	sta $0318 ; NMINV
	stx $0319

	jsr clear232
	cli
	rts

;----------------------------------------------------------------------
; new BSOUT
newout:
	pha		; dupliciaton of original kernal routines
	lda DFLTO	; test dfault output device for
	cmp #2		; screen, and...
	beq :+
	pla		; if so, go back to original rom routines
	jmp oldout
:    	pla

	sta rsotm
	stx rsotx
	sty rsoty
sm20	lda sw_cmd
	sta temp
	jsr swwait
	lda rsotm
sm21	sta sw_data
	jsr swwait
	lda temp	; restore rts state
sm22	sta sw_cmd
	lda rsotm
	ldx rsotx
	ldy rsoty
	clc
	rts

;----------------------------------------------------------------------
sw_dropdtr:
sm23	lda sw_cmd
	and #%11111110
sm24	sta sw_cmd
	ldx #226
	stx JIFFIES
wait30	bit JIFFIES
	bmi wait30
	ora #%00000001
sm25	sta sw_cmd
	rts

;----------------------------------------------------------------------
; new GETIN
newin	lda DFLTN
	cmp #2		; see if default input is modem
	beq :+
	jmp ogetin	; nope, go back to original

:	jsr sw_getxfer
	bcs :+		; if no character, then return 0 in a
	rts
:	clc
	lda #0
	rts

;----------------------------------------------------------------------
; get byte from serial interface
sw_getxfer:
	ldx rhead
	cpx rtail
	beq @1		; skip (empty buffer, return with carry set)
	lda ribuf,x
	pha
	inc rhead
	dec rfree
	ldx paused	; are we stopped?
	beq :+		; no, don't bother
	lda rfree	; check buffer free
	cmp #50		; against restart limit
	bcs :+		; is it larger than 50?
	ldx #startsw	; if no, then don't start yet
	stx paused
	jsr flow
:	clc
	pla
@1:	rts

;----------------------------------------------------------------------
temp	.byte 0
paused	.byte 0

;----------------------------------------------------------------------
swbaud	.byte $15,$17,$18,$1a,$1c,$1e,$1f,$10,$10,$10

