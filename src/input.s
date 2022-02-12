; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; String input from user
;

;----------------------------------------------------------------------
input:
	jsr inpset
	jmp inputl

;----------------------------------------------------------------------
inpset:
	stx max
	cpy #0
	beq :+
	jsr outstr
:	jsr clrchn
	sec
	jsr plot
	stx tmp9e
	sty tmp9f
	jsr finpos	; set up begin &
	lda locat+1	; end of input
	sta begpos+1	; ptrs
	sta endpos+1
	lda locat
	sta begpos
	clc
	adc max
	sta endpos
	lda endpos+1
	adc #0
	sta endpos+1
	rts

;----------------------------------------------------------------------
inputl:
	lda #0
	sta BLNSW
	jsr savech
inpwat:
	jsr getin
	beq inpwat
	sta tmp03
	and #$7f
	cmp #CSR_DOWN
	beq inpcud
	cmp #'"'
	beq inpwat
	cmp #CR
	jeq inpret
	lda tmp03
	cmp #DEL
	beq inpdel
	cmp #CSR_LEFT
	beq inpdel
	and #$7f
	cmp #HOME
	beq inpcls
	bne inpprc
inpcud
	jsr restch
	lda tmp03
	cmp #CSR_UP
	beq inphom
	jsr inpcu1
	jmp inpmov
inpcu1	ldy max
inpcu2
	dey
	bmi inpcu3
	lda (begpos),y
	cmp #' '
	beq inpcu2
inpcu3
	iny
	tya
	clc
	adc tmp9f
	tay
	rts
inpcls
	jsr restch
	lda tmp03
	cmp #CLR
	bne inphom
	ldy max
	lda #' '
inpcl2	sta (begpos),y
	dey
	bpl inpcl2
inphom
	ldy tmp9f
inpmov
	ldx tmp9e
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
	lda tmp03
	cmp #INST
	bne inprst
	dec endpos+1
	ldy #$ff
	lda (endpos),y
	inc endpos+1
	cmp #' '
	beq inprst
	jmp inpwat
inprst
	ldx #3
	stx KOUNT
	jsr restch
	lda tmp03
	jsr chrout
	jsr quote_insert_off
	jmp inputl

inpret:
	jsr restch
	jsr inpcu1
	cmp COLUMN
	bcc :+
	ldx tmp9e
	clc
	jsr plot
:	jsr finpos
	lda locat
	sec
	sbc begpos
	pha
	tay
	lda #' '
:	sta (begpos),y
	cpy max
	beq :+
	iny
	bne :-
:	pla
	sta max
	ldx tmp9e
	ldy tmp9f
	clc
	jsr plot
	lda #1
	sta BLNSW
	lda #3
	ldy #0
	tax
	jsr setlfs
	lda #0
	jsr setnam
	jsr open
	ldx #3
	jsr chkin
	ldy #0
:	cpy max
	beq :+
	jsr chrin
	sta inpbuf,y
	iny
	bne :-
:	lda #0
	sta inpbuf,y
	jsr clrchn
	lda #3
	jsr close
	ldx max
	rts
