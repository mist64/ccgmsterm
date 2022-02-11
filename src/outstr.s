;----------------------------------------------------------------------
outstr:
	sty zpoutstr+1
	sta zpoutstr
	ldy #0
@loop:	lda (zpoutstr),y
	beq @rts
	cmp #2
	beq @hilite
	cmp #3
	bne @skip
	iny
	lda (zpoutstr),y
	sta LINE
	lda #$0d
	jsr chrout
	lda #$91	; CSR UP
	jsr chrout
	iny
	lda (zpoutstr),y
	sta COLUMN
	bne @outst4

@skip:	cmp #'A'+$80
	bcc @outst3
	cmp #'Z'+1+$80
	bcs @outst3
	lda $d018
	and #2
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
	lda #$12	; RVS ON
	jsr chrout
	lda #$a1	; '▌' LEFT HALF BLOCK
	jsr chrout
	lda $d018
	and #2
	php
	iny
	lda (zpoutstr),y
	plp
	beq :+
	ora #$80
:	jsr chrout
	lda #182
	jsr chrout
	pla
	sta textcl
	lda #146
	bne @outst3
;----------------------------------------------------------------------
outcap:
	cmp #'A'+$80
	bcc @2
	cmp #'Z'+1+$80
	bcs @2
	pha
	lda $d018
	and #2
	beq @1
	pla
	bne @2
@1:	pla
	and #$7f
@2:	jmp chrout
