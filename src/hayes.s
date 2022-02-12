; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Hayes CARRIER/BUSY/NO ANSWER detection
;

bustemp	.byte 0

; [XXX this is all very verbose]
haybus
	ldy #0
	sty bustemp
haybus2
	jsr gethayes
haybus3
	jsr puthayes
	cpy #$ff
	jeq hayout	; get out of routine. send data to terminal, and set connect!
	jsr gethayes
	cmp #'B'+$20
	bne haynocarr	; move to check for no carrier
	jsr puthayes
	jsr gethayes
	cmp #'U'+$20
	bne haybus3
	jsr puthayes
	jsr gethayes
	cmp #'S'+$20
	bne haybus3
	jsr puthayes
	jsr gethayes
	cmp #'Y'+$20
	bne haybus3
	ldy #0
	sty bustemp
	jmp haybak ; busy!
;
haynocarr
	cmp #'N'+$20
	bne haybusand;move to next char
	jsr puthayes
	jsr gethayes
	cmp #'O'+$20
	bne haybus3
	jsr puthayes
	jsr gethayes
	cmp #' '
	bne haybus3
	jsr puthayes
	jsr gethayes
	cmp #'C'+$20
	jne haynoanswer
	jsr puthayes
	jsr gethayes
	cmp #'A'+$20
	bne haybus3
	jsr puthayes
	jsr gethayes
	cmp #'R'+$20
	bne haybus3
	jsr puthayes
	jsr gethayes
	cmp #'R'+$20
	bne haybus3
	ldy #0
	sty bustemp
	jmp haynan ; no carrier!
;
haybusand
	cmp #'B'
	bne haynocarrand;move to check for no carrier
	jsr puthayes
	jsr gethayes
	cmp #'U'
	beq :+
haybus3b:
	jmp haybus3
:
	jsr puthayes
	jsr gethayes
	cmp #'S'
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #'Y'
	bne haybus3b
	ldy #0
	sty bustemp
	jmp haybak ; busy!
;
haynocarrand
	cmp #'N'
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #'O'
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #' '
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #'C'
	bne haynoanswerand
	jsr puthayes
	jsr gethayes
	cmp #'A'
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #'R'
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #'R'
	bne haybus3b
	ldy #0
	sty bustemp
	jmp haynan ; no carrier!

haynoanswerand
	cmp #'A'
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #'N'
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #'S'
	bne haybus3b
	jsr puthayes
	jsr gethayes
	cmp #'W'
	beq :+
haybus3c
	jmp haybus3
:
	ldy #0
	sty bustemp
	jmp haynan ; no carrier!

haynoanswer
	cmp #'A'+$20
	bne haybus3c
	jsr puthayes
	jsr gethayes
	cmp #'N'+$20
	bne haybus3c
	jsr puthayes
	jsr gethayes
	cmp #'S'+$20
	bne haybus3c
	jsr puthayes
	jsr gethayes
	cmp #'W'+$20
	bne haybus3c
	ldy #0
	sty bustemp
	jmp haynan	; no carrier!

;
hayout
	sty bustemp
	jmp haycon

;----------------------------------------------------------------------
gethayes:
	inc waittemp	; timeout for no character loop so
	ldx waittemp	; so it doesn't lock up
	cpx #144	; maybe change for various baud rates
	beq :+
	ldx #LFN_MODEM
	jsr chkin
	jsr getin
	beq gethayes
:	ldx #0
	stx waittemp
	rts

;----------------------------------------------------------------------
puthayes:
	ldy bustemp
	iny
	sty bustemp
	sta tempbuf,y
	rts

waittemp:
	.byte 0
