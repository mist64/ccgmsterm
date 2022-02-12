; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Macro Execution
;

;xfer id and pw to macros F5 and F7
xferidpw
	ldy #59
xferid
	lda (nlocat),y
	sta macmem+69,y
	iny
	lda (nlocat),y
	beq xferpw
	jmp xferid
xferpw
	sta macmem+69,y
	ldy #71
xferpw2
	lda (nlocat),y
	sta macmem+121,y
	iny
	lda (nlocat),y
	beq xferp3
	jmp xferpw2
xferp3
	sta macmem+121,y
	rts

;MACROS
macmdm	.byte 0
macxrg	.byte 0

prmacx	;find index for macro
	cpx #3     ;from LSTX f-key value
	bne prmax2
	ldx #7
prmax2	txa
	sec
	sbc #4     ;now a=0..3 for f1,3,5,7
	ldx #5
prmax3	asl a
	dex
	bpl prmax3  ;a=0,64,128,192
	sta macxrg
	rts

;----------------------------------------------------------------------
print_macro:
	lda LSTX
	cmp #7
	bcc print_macro
	jsr prmacx
prtmc0
	ldx macxrg
	lda macmem,x
	beq prtmc4
	pha
	ldx macmdm
	bne prtmc2
	ldx #LFN_MODEM
	jsr chkout
	pla
	pha
	ldx ascii_mode
	beq prtmc1
	jsr petscii_to_ascii
prtmc1
	jsr chrout
	jsr clrchn
	lda #$fd
	sta JIFFIES
prtmcd	lda JIFFIES
	bne prtmcd
	lda #$fd
	sta JIFFIES
prtmcd2	lda JIFFIES
	bne prtmcd2
	ldx #LFN_MODEM
	jsr chkin
	jsr getin
	cmp #0
	bne prtmci
	ldx half_duplex
	beq prtmca
	ldx ascii_mode
	beq prtmc2
	pla
	jsr petscii_to_ascii
	bne prtmck
	beq prtmc3
prtmca	pla
	bne prtmc3
prtmci	tax
	pla
	txa
prtmck	ldx ascii_mode
	beq :+
	jsr ascii_to_petscii
:	pha
prtmc2
	jsr cursor_off
	pla
	ldx macmdm
	bne prtmcs
	jsr buffer_put
prtmcs
	jsr handle_control_codes
	bcs prtmc3
	jsr chrout
	jsr quote_insert_off
	jsr cursor_show
prtmc3	inc macxrg
	cmp #255
	bne prtmc0
prtmc4	jmp cursor_off
