;
stbrvs	.byte 0
stbcol	.byte 0
stbxps	.byte 0
stbyps	.byte 0
stbmax	.byte 0
stbmay	.byte 0
cf7	;screen to buffer
	lda #0
	sta 198
	lda #$f1
	sta JIFFIES
scnbf0	lda JIFFIES
	bne scnbf0
	jsr getin
	cmp #140
	bne scnbfs
	jsr bufclr
scnbfs
	lda buffer_open
	pha
	lda #1
	sta buffer_open
	lda #0
	sta stbrvs
	lda #255
	sta stbcol
	ldy #24
	sty stbyps
scnbf1	ldx #39
	stx stbxps
scnbf2	jsr finscp
	cmp #$20
	bne scnbf3
	dec stbxps
	bpl scnbf2
	dec stbyps
	bpl scnbf1
	jmp scnbr4
scnbf3
	lda #$0d
	jsr buffer_put
	lda #$93
	jsr buffer_put
	lda $d018
	and #2
	lsr a
	lsr a
	ror a
	eor #$8e
	jsr buffer_put
	lda $d021
	and #15
	beq scnbnc
	tax
	lda COLTAB,x
	pha
	lda #2
	jsr buffer_put
	pla
	jsr buffer_put
scnbnc
	lda #10
	jsr buffer_put
	lda stbyps
	sta stbmay
	lda #0
	sta stbyps
scnbnl
	lda #39
	sta stbxps
scnbf4
	jsr finscp
	cmp #$20
	bne scnbf5
	dec stbxps
	bpl scnbf4
	inc stbxps
	jmp scnbrt
scnbf5
	lda stbxps
	sta stbmax
	lda #0
	sta stbxps
scnbf6
	jsr finscp
	sta tmp02
	jsr finscc
	sta tmp03
	lda tmp02
	and #$80
	cmp stbrvs
	beq scnbf7
	lda stbrvs
	eor #$80
	sta stbrvs
	ora #18
	eor #$80
	jsr buffer_put
scnbf7
	lda tmp02
	cmp #$20
	beq scnbf8
	lda tmp03
	cmp stbcol
	beq scnbf8
	tax
	lda COLTAB,x
	jsr buffer_put
scnbf8
	lda tmp02
	and #$7f
	cmp #$7f
	beq scnbf9
	cmp #$20
	bcs scnb10
scnbf9
	clc
	adc #$40
	bne scnb11
scnb10
	cmp #64
	bcc scnb11
	ora #$80
scnb11
	jsr buffer_put
	inc stbxps
	lda stbxps
	cmp stbmax
	bcc scnbf6
	beq scnbf6
scnbrt
	lda stbxps
	cmp #40
	bcs scnbr2
	lda #$0d
	jsr buffer_put
	lda #0
	sta stbrvs
scnbr2
	inc stbyps
	lda stbyps
	cmp stbmay
	beq scnbr3
	bcs scnbre
scnbr3	jmp scnbnl
scnbre
	ldx 646
	lda COLTAB,x
	jsr buffer_put
scnbr4
	pla
	sta buffer_open
	jmp main
;
finscp
	ldy stbyps
	lda $ecf0,y
	sta locat
	lda $d9,y
	and #$7f
	sta locat+1
	ldy stbxps
	lda (locat),y
	rts
finscc
	jsr finscp
	lda locat+1
	clc
	adc #$d4
	sta locat+1
	lda (locat),y
	and #15
	rts
