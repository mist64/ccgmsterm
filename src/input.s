input
	jsr inpset
	jmp inputl
inpset
	stx max
	cpy #$00
	beq inpcon
	jsr outstr
inpcon
	jsr clrchn
	sec
	jsr plot
	stx $9e
	sty $9f
	jsr finpos    ;set up begin &
	lda locat+1   ;end of input
	sta begpos+1  ;ptrs
	sta endpos+1
	lda locat
	sta begpos
	clc
	adc max
	sta endpos
	lda endpos+1
	adc #$00
	sta endpos+1
	rts
inputl
	lda #0
	sta 204
	jsr savech
inpwat
	jsr getin
	beq inpwat
	sta $03
	and #127
	cmp #17
	beq inpcud
	cmp #34
	beq inpwat
	cmp #13
	bne inpwt1
	jmp inpret
inpwt1
	lda $03
	cmp #20
	beq inpdel
	cmp #157
	beq inpdel
	and #$7f
	cmp #19
	beq inpcls
	bne inpprc
inpcud
	jsr restch
	lda $03
	cmp #145
	beq inphom
	jsr inpcu1
	jmp inpmov
inpcu1	ldy max
inpcu2
	dey
	bmi inpcu3
	lda (begpos),y
	cmp #$20
	beq inpcu2
inpcu3
	iny
	tya
	clc
	adc $9f
	tay
	rts
inpcls
	jsr restch
	lda $03
	cmp #$93
	bne inphom
	ldy max
	lda #$20
inpcl2	sta (begpos),y
	dey
	bpl inpcl2
inphom
	ldy $9f
inpmov
	ldx $9e
	clc
	jsr plot
	jmp inputl
inpdel
	jsr finpos
	lda locat
	cmp begpos
	bne inprst
	lda locat+1
	cmp begpos+1
	beq inpwat
	bne inprst
inpprc
	jsr finpos
	lda locat
	cmp endpos
	bne inpins
	lda locat+1
	cmp endpos+1
	bne inpins
	jmp inpwat
inpins
	lda $03
	cmp #148
	bne inprst
	dec endpos+1
	ldy #$ff
	lda (endpos),y
	inc endpos+1
	cmp #$20
	beq inprst
	jmp inpwat
inprst
	ldx #$03
	stx 651
	jsr restch
	lda $03
	jsr chrout
	jsr qimoff
	jmp inputl
inpret
	jsr restch
	jsr inpcu1
	cmp 211
	bcc inpre2
	ldx $9e
	clc
	jsr plot
inpre2
	jsr finpos
	lda locat
	sec
	sbc begpos
	pha
	tay
	lda #$20
inpspc
	sta (begpos),y
	cpy max
	beq inpinp
	iny
	bne inpspc
inpinp
	pla
	sta max
	ldx $9e
	ldy $9f
	clc
	jsr plot
	lda #1
	sta 204
	lda #$03
	ldy #$00
	tax
	jsr setlfs
	lda #$00
	jsr setnam
	jsr open
	ldx #$03
	jsr chkin
	ldy #$00
inpsto
	cpy max
	beq inpend
	jsr chrin
	sta inpbuf,y
	iny
	bne inpsto
inpend
	lda #$00
	sta inpbuf,y
	jsr clrchn
	lda #$03
	jsr close
	ldx max
	rts
