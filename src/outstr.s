outstr
	sty $23
	sta $22
	ldy #0
outst1	lda ($22),y
	beq outste
	cmp #2
	beq hilite
	cmp #03
	bne outst2
	iny
	lda ($22),y
	sta LINE
	lda #$0d
	jsr chrout
	lda #145
	jsr chrout
	iny
	lda ($22),y
	sta 211
	bne outst4
outst2
	cmp #$c1
	bcc outst3
	cmp #$db
	bcs outst3
	lda 53272
	and #$02
	php
	lda ($22),y
	plp
	bne outst3
	and #$7f
outst3
	jsr chrout
outst4	iny
	bne outst1
	inc $23
	bne outst1
outste	rts
hilite
	lda textcl
	pha
	lda #1
	sta textcl
	lda #18   ;rvs-on
	jsr chrout
	lda #161
	jsr chrout
	lda 53272
	and #2
	php
	iny
	lda ($22),y
	plp
	beq hilit2
	ora #$80
hilit2	jsr chrout
	lda #182
	jsr chrout
	pla
	sta textcl
	lda #146
	bne outst3
;
outcap
	cmp #$c1    ;cap 'a'
	bcc outcp3
	cmp #$db    ;cap 'z'
	bcs outcp3
	pha
	lda 53272
	and #2
	beq outcp2
	pla
	bne outcp3
outcp2	pla
	and #$7f
outcp3	jmp chrout
