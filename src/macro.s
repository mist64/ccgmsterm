;
prwcmc
	lda macxrg
	and #$c0
	asl a
	rol a
	rol a
	asl a
	clc
	adc #$31;1
	sta edfktx
	rts
edtmtx	.byte $93,5,13,13,e,'DIT WHICH MACRO?',13
	.byte 158,'(ctrl f1 / f3 OR return '
	.byte 'TO ABORT.) ',5,3,2,18,0
edtrtx	.byte 19,13,5,e,'DIT ',f
edfktx	.byte '1 mACRO...<',c,t,cr,l,'-',cx,'> TO END:',13,13,13,13,0
wchmac	.byte 0
macfull	.byte 0
edtmac
	lda #<edtmtx
	ldy #>edtmtx
	jsr outstr
	jsr savech
edtmlp	lda 197
	cmp #1    ;return
	bne edtmc2
edtmab	rts
edtmc2	cmp #4
	bcc edtmlp
	cmp #6
	bcs edtmlp
	pha
	jsr restch
	pla
	tax
edtmc3
	lda 197
	cmp #7
	bcc edtmc3
	jsr prmacx
	sta wchmac
edtmen
	lda #0
	sta 198
	lda #$93
	jsr chrout
	lda #0
	sta $d020
	sta $d021
edtstr
	jsr prwcmc
	lda #<edtrtx
	ldy #>edtrtx
	jsr outstr
	lda #1
	sta macmdm
	sta cursfl
	lda wchmac
	sta macxrg
	clc
	adc #62
	sta macfull
	jsr restch
	lda #$20
	jsr chrout
	lda #157
	jsr chrout
	jsr prtmc0
edtinp	jsr curprt
edtkey
	jsr getin
	beq edtkey
	cmp #16   ;ctrl-p
	beq edtmen
	cmp #19    ;no home or clr
	beq edtkey
	cmp #$93
	bne edtky1
	ldx macxrg
edtclr
	lda #0
	sta macmem,x
	cpx wchmac
	beq edtky0
	dex
	jmp edtclr
edtky0	ldx wchmac
	stx macxrg
	jmp edtmen
edtky1
	cmp #24   ;ctrl-x
	beq edtbye
	cmp #20   ;del
	bne edtky2
	lda macxrg
	cmp wchmac
	beq edtkey
	tax
	jsr edtdel
jcs	edtmen
	lda macxrg
	and #$3f
	cmp #$3f
	bne edtkey
	jmp edtmen
edtky2
	ldx 214
	cpx #23
	bcs edtkey
	cpx #3
	bcc edtkey
edtky3
	ldx macxrg
	cpx macfull;64 bytes of memory per macro
	bcs edtkey
	sta macmem,x
	pha
	txa
	cmp wchmac
	beq edtky4
	and #$3f
	bne edtky4
	pla
	jsr bell
	jmp edtmen
edtky4
	inc macxrg
	jsr curoff
	pla
	jsr ctrlck
	bcc edtky5
	jmp edtinp
edtky5
	jsr chrout
	jsr qimoff
	jmp edtinp
edtbye	ldx macxrg
	lda #0
	sta macmem,x
	rts
macrvs	.byte 146
maccty	.byte 10
maccol	.byte 5
maccas	.byte 14
macbkg	.byte 0
edtdel
	lda #146
	sta macrvs
	lda #10
	sta maccty
	lda #5
	sta maccol
	lda #14
	sta maccas
	lda #0
	sta macbkg
	lda macmem-1,x
	cmp #$a4;underline key
	beq edtde2
	and #$7f
	cmp #$20
	bcc edtde0
	jmp edtdle
edtde0
	cmp #17
	beq edtde1
	cmp #29
	bne edtde3
edtde1	lda macmem-1,x
edtdeo	eor #$80
	jmp edtdln
edtde2
	lda #148
	jsr edprrv
	lda #29
	jmp edtdln
edtde3	lda macmem-1,x
	cmp #148
	bne edtde4
	lda #29
	jsr edprrv
	lda #148
	bne edtdeo
edtde4	jsr edtcok
	bmi edtde7
	ldx macxrg
	lda macmem-2,x
	sta macbkg
edtde5	dex
	cpx wchmac
	beq edtde6
	lda macmem-1,x
	jsr edtcok
	bmi edtde5
	ldy macmem-2,x
	cpy macbkg
	beq edtdcl
	cpy #2
	beq edtde5
	ldy macbkg
	cpy #2
	beq edtde5
edtdcl
	sta maccol
edtde6
	lda macbkg
	cmp #2
	bne edtclh
	sta xlastch
	cpx wchmac
	beq edtclb
	lda maccol
	jsr edtcok
	bmi edtclb
	tya
	tax
edtclb
	stx $d020
	stx $d021
	jmp edtdla
edtclh
	lda #0
	sta xlastch
	lda maccol
	jmp edtdln
edtde7
	cmp #10
	beq edtde8
	cmp #11
	bne edtd12
edtde8	ldx macxrg
edtde9	dex
	cpx wchmac
	beq edtd11
	lda macmem-1,x
	cmp #10
	beq edtd10
	cmp #11
	bne edtde9
edtd10	sta maccty
edtd11	lda maccty
	jmp edtdln
edtd12	and #$7f
	cmp #18
	bne edtd15
	ldx macxrg
edtd13	dex
	cpx wchmac
	beq edtd14
	lda macmem-1,x
	and #$7f
	cmp #18
	bne edtd13
	lda macmem-1,x
	sta macrvs
edtd14	lda macrvs
	and #$80
	eor #$80
	sta 199
	lda macrvs
	jmp edtdln
edtd15
	cmp #12
	beq edtd16
	cmp #14
	beq edtd16
	cmp #21
	bne edtd19
edtd16	ldx macxrg
edtdlc	dex
	cpx wchmac
	beq edtd18
	lda macmem-1,x
	cmp #12
	beq edtd17
	cmp #14
	beq edtd17
	cmp #21
	bne edtdlc
edtd17	sta maccas
edtd18	lda maccas
	jmp edtdln
edtd19
	cmp #$0d
	bne edtdla
	lda #0
	sta 199
	lda #146
	jsr edprrv
	dec macxrg
	ldx macxrg
	lda #0
	sta macmem,x
	sec
	rts
edtdle
	lda #20
	jsr edprrv
	lda #148
edtdln
	jsr edprrv
edtdla
	dec macxrg
	ldx macxrg
	lda #0
	sta macmem,x
	clc
	rts
edprrv
	sta $02
	lda 199
	pha
	lda #0
	sta 199
	jsr curoff
	lda $02
	jsr ctrlck
	bcs edprr2
	jsr chrout
	jsr qimoff
edprr2	pla
	sta 199
	jmp curprt
edtcok
	ldy #15
edtco2	cmp clcode,y
	beq edtco3
	dey
	bpl edtco2
edtco3	rts
