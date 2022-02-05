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
	cpx #3     ;from 197 f-key value
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
prtmac
	lda 197
	cmp #7
	bcc prtmac
	jsr prmacx
prtmc0
	ldx macxrg
	lda macmem,x
	beq prtmc4
	pha
	ldx macmdm
	bne prtmc2
	ldx #5
	jsr chkout
	pla
	pha
	ldx grasfl
	beq prtmc1
	jsr catosa
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
	ldx #5
	jsr chkin
	jsr getin
	cmp #$00
	bne prtmci
	ldx duplex
	beq prtmca
	ldx grasfl
	beq prtmc2
	pla
	jsr catosa
	bne prtmck
	beq prtmc3
prtmca	pla
	bne prtmc3
prtmci	tax
	pla
	txa
prtmck	ldx grasfl
	beq prtmcj
	jsr satoca
prtmcj
	pha
prtmc2
	jsr curoff
	pla
	ldx macmdm
	bne prtmcs
	jsr putbuf
prtmcs
	jsr ctrlck
	bcs prtmc3
	jsr chrout
	jsr qimoff
	jsr curprt
prtmc3	inc macxrg
	cmp #255
	bne prtmc0
prtmc4	jmp curoff
