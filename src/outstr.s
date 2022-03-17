; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; String output
;

;----------------------------------------------------------------------
outstr:
	sty zpoutstr+1
	sta zpoutstr
	ldy #0
@loop:	lda (zpoutstr),y
	beq @rts
	cmp #HILITE
	beq @hilite
	cmp #3
	bne @skip

	; set cursor pos
	iny
	lda (zpoutstr),y	; [XXX should use PLOT]
	sta LINE
	lda #CR
	jsr chrout
	lda #CSR_UP
	jsr chrout
	iny
	lda (zpoutstr),y
	sta COLUMN
	bne @outst4

@skip:	cmp #'A'+$80
	bcc @outst3
	cmp #'Z'+1+$80
	bcs @outst3
	jsr get_charset
	php
	lda (zpoutstr),y
	plp
	bne @outst3
	and #$7f
@outst3:
	jsr chrout
@outst4:
	iny
	bne @loop
	inc zpoutstr+1
	bne @loop
@rts:	rts

@hilite:
	lda textcl
	pha
	lda #1
	sta textcl
	lda #RVSON
	jsr chrout
	lda #$a1	; '▌' LEFT HALF BLOCK
	jsr chrout
	jsr get_charset
	php
	iny
	lda (zpoutstr),y
	plp
	beq :+
	ora #$80
:	jsr chrout
	lda #$B6	; $B6: RIGHT THREE EIGHTHS BLOCK
	jsr chrout
	pla
	sta textcl
	lda #RVSOFF
	bne @outst3
;----------------------------------------------------------------------
outcap:
	cmp #'A'+$80
	bcc @2
	cmp #'Z'+1+$80
	bcs @2
	pha
	jsr get_charset
	beq @1
	pla
	bne @2
@1:	pla
	and #$7f
@2:	jmp chrout
