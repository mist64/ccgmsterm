decoen
viewmg
	lda #<ampag1
	ldy #>ampag1
	jsr outstr
	lda #0
	sta 198
viewm1
	lda 198
	beq viewm1
	lda #<ampag2
	ldy #>ampag2
	jsr outstr
	lda #0
	sta 198
viewm2
	lda 198
	beq viewm2
	rts
