	.segment "S0812"  ;pxxxxx
;
;PUNTER
;
punter	; source code $0812
;referenced by old $c000 addresses
p49152	lda #$00
	.byte $2c
p49155	lda #$03
	.byte $2c
p49158	lda #$06
	.byte $2c
p49161	lda #$09
	.byte $2c
p49164	lda #$0c
	.byte $2c
p49167	lda #$0f
	nop
p49170	jmp pnt23
p49173	jmp pnt109
pnt23	sta $62
	tsx
	stx pbuf+28
	lda #<pnttab
	clc
	adc $62
	sta pntjmp+1
	lda #>pnttab
	adc #$00
	sta pntjmp+2
pntjmp	jmp pnttab
pnttab
	jmp pnt28
	jmp pnt87
	jmp pnt84
	jmp pnt95
	jmp pnt99
	jmp pnt110
pnt27	.byte 'GOOBADACKS/BSYN'
;pnt27 .byte "goobadacks/bsyn"
pnt28	sta pbuf+5
	lda #$00
	sta pbuf
	sta pbuf+1
	sta pbuf+2
pnt29	lda #$00
	sta pbuf+6
	sta pbuf+7
pnt30	jsr pnt114
	jsr pnt38
	lda $96
	bne pnt35
	lda pbuf+1
	sta pbuf
	lda pbuf+2
	sta pbuf+1
	lda pnt10
	sta pbuf+2
	lda #$00
	sta pbuf+4
	lda #$01
	sta pbuf+3
pnt31	lda pbuf+5
	bit pbuf+3
	beq pnt33
	ldy pbuf+4
	ldx #$00
pnt32	lda pbuf,x
	cmp pnt27,y
	bne pnt33
	iny
	inx
	cpx #$03
	bne pnt32
	jmp pnt34
pnt33	asl pbuf+3
	lda pbuf+4
	clc
	adc #$03
	sta pbuf+4
	cmp #$0f
	bne pnt31
	jmp pnt111
pnt34	lda #$ff
	sta pbuf+6
	sta pbuf+7
	jmp pnt30
pnt35	inc pbuf+6
	bne pnt36
	inc pbuf+7
pnt36	lda pbuf+7
	ora pbuf+6
	beq pnt37
	lda pbuf+6
	cmp #$07
	lda pbuf+7
	cmp #$14
jcc	pnt30
	lda #$01
	sta $96
	jmp pnt101
pnt37	lda #$00
	sta $96
	rts
	nop
pnt38
	tya
	pha
pnt39
	jsr modget
	bcs pnt40
	sta pnt10
	lda #$00
	sta $96
	pla
	tay
	jmp pnt41
pnt40	lda #$02
	sta $96
	lda #$00
	sta pnt10
	pla
	tay
pnt41	pha
	lda #$03
	sta $ba
	pla
	rts
pnt42
	jsr clear232
	jsr enablexfer
	ldx #$05
	jsr chkout
	ldx #$00
pnt43	lda pnt27,y
	jsr chrout
	iny
	inx
	cpx #$03
	bne pnt43
	jmp clrchn
pnt44	sta pbuf+8
	jsr puntdelay;modded this;modded this. handshaking delay
	lda #$00;delay 0 on 1 off. originally was off
	sta pbuf+11
pnt45	lda #$02
	sta $62
	ldy pbuf+8
	jsr pnt42
pnt46	lda #$04
	jsr pnt28
	lda $96
	beq pnt47
	dec $62
	bne pnt46
	jmp pnt45
pnt47
	jsr puntdelay;modded this;modded this. handshaking delay
	ldy #$09
	jsr pnt42
	lda pbuf+13
	beq pnt48
	lda pbuf+8
	beq pnt50
pnt48	lda pbuf2+4
	sta pbuf+9
	sta pbuf+23
	jsr pnt65
	lda $96
	cmp #$01
	beq pnt49
	cmp #$02
	beq pnt47
	cmp #$04
	beq pnt49
	cmp #$08
	beq pnt47
pnt49	rts
pnt50	lda #$10
	jsr pnt28
	lda $96
	bne pnt47
	lda #$0a
	sta pbuf+9
pnt51	ldy #$0c
	jsr pnt42
	lda #$08
	jsr pnt28
	lda $96
	beq pnt52
	dec pbuf+9
	bne pnt51
pnt52	rts
pnt53	lda #$00;add delay back in
	sta pbuf+11
pnt54
	jsr puntdelay;modded this. handshaking delay
	lda pbuf+30
	beq pnt55
	ldy #$00
	jsr pnt42
	jsr puntdelay;modded this. handshaking delay
pnt55	lda #$0b
	jsr pnt28
	lda $96
	bne pnt54
	lda #$00
	sta pbuf+30
	lda pbuf+4
	cmp #$00
	bne pnt59
	lda pbuf+13
	bne pnt61
	inc pbuf+25
	bne pnt56
	inc pbuf+26
pnt56	jsr pnt79
	ldy #$05
	iny
	lda ($64),y
	cmp #$ff
	bne pnt57
	lda #$01
	sta pbuf+13
	lda pbuf+22
	eor #$01
	sta pbuf+22
	jsr pnt79
	jsr pnt77
	jmp pnt58
pnt57	jsr pnt74
pnt58	lda #$2d
	.byte $2c
pnt59	lda #$3a
	jsr pnt107
	ldy #$06
	jsr pnt42
	lda #$08
	jsr pnt28
	lda $96
	bne pnt58
	jsr pnt79
	ldy #$04
	lda ($64),y
	sta pbuf+9
	jsr pnt80
	jsr clear232
	jsr enablexfer
	ldx #$05
	jsr chkout
	ldy #$00
pnt60	lda ($64),y
	jsr chrout
	iny
	cpy pbuf+9
	bne pnt60
	jsr clrchn
	lda #$00
	rts
pnt61	lda #$2a
	jsr pnt107
	ldy #$06
	jsr pnt42
	lda #$08
	jsr pnt28
	lda $96
	bne pnt61
	lda #$0a
	sta pbuf+9
pnt62	ldy #$0c
	jsr pnt42
	lda #$10
	jsr pnt28
	lda $96
	beq pnt63
	dec pbuf+9
	bne pnt62
pnt63	lda #$03
	sta pbuf+9
pnt64	ldy #$09
	jsr pnt42
	lda #$00
	jsr pnt28
	dec pbuf+9
	bne pnt64
	lda #$01
	rts
pnt65	ldy #$00
pnt66	lda #$00
	sta pbuf+6
	sta pbuf+7
pnt67	jsr pnt114
	jsr pnt38
	lda $96
	bne pnt70
	lda pnt10
	sta pbuf2,y
	cpy #$03
	bcs pnt68
	sta pbuf,y
	cpy #$02
	bne pnt68
	lda pbuf
	cmp #$41
	bne pnt68
	lda pbuf+1
	cmp #$43
	bne pnt68
	lda pbuf+2
	cmp #$4b
	beq pnt69
pnt68	iny
	cpy pbuf+9
	bne pnt66
	lda #$01
	sta $96
	rts
pnt69	lda #$ff
	sta pbuf+6
	sta pbuf+7
	jmp pnt67
pnt70	inc pbuf+6
	bne pnt71
	inc pbuf+7
pnt71	lda pbuf+6
	ora pbuf+7
	beq pnt73
	lda pbuf+6
	cmp #$06
	lda pbuf+7
	cmp #$10
	bne pnt67
	lda #$02
	sta $96
	cpy #$00
	beq pnt72
	lda #$04
	sta $96
pnt72	jmp pnt101
pnt73	lda #$08
	sta $96
	rts
pnt74	lda pbuf+22
	eor #$01
	sta pbuf+22
	jsr pnt79
	ldy #$05
	lda pbuf+25
	clc
	adc #$01
	sta ($64),y
	iny
	lda pbuf+26
	adc #$00
	sta ($64),y
	jsr disablexfer
	ldx #$02
	jsr chkin
	ldy #$07
pnt75	jsr chrin
	sta ($64),y
	iny
	jsr readst
	bne pnt76
	cpy pbuf+24
	bne pnt75
	tya
	pha
	jmp pnt78
pnt76	tya
	pha
	ldy #$05
	iny
	lda #$ff
	sta ($64),y
	jmp pnt78
pnt77	pha
pnt78	jsr clrchn
	jsr pnt109
	jsr pnt103
	jsr pnt109
	ldy #$04
	lda ($64),y
	sta pbuf+9
	jsr pnt80
	pla
	ldy #$04
	sta ($64),y
	jsr pnt81
	rts
pnt79	lda #<pbuf2
	sta $64
	lda pbuf+22
	clc
	adc #>pbuf2
	sta $65
	rts
pnt80	lda #<pbuf2
	sta $64
	lda pbuf+22
	eor #$01
	clc
	adc #>pbuf2
	sta $65
	rts
pnt81	lda #$00
	sta pbuf+18
	sta pbuf+19
	sta pbuf+20
	sta pbuf+21
	ldy #$04
pnt82	lda pbuf+18
	clc
	adc ($64),y
	sta pbuf+18
	bcc pnt83
	inc pbuf+19
pnt83	lda pbuf+20
	eor ($64),y
	sta pbuf+20
	lda pbuf+21
	rol a
	rol pbuf+20
	rol pbuf+21
	iny
	cpy pbuf+9
	bne pnt82
	ldy #$00
	lda pbuf+18
	sta ($64),y
	iny
	lda pbuf+19
	sta ($64),y
	iny
	lda pbuf+20
	sta ($64),y
	iny
	lda pbuf+21
	sta ($64),y
	rts
pnt84	lda #$00
	sta pbuf+13
	sta pbuf+12
	sta pbuf+29
	lda #$01
	sta pbuf+22
	lda #$ff
	sta pbuf+25
	sta pbuf+26
	jsr pnt80
	ldy #$04
	lda #$07
	sta ($64),y
	jsr pnt79
	ldy #$05
	lda #$00
	sta ($64),y
	iny
	sta ($64),y
pnt85	jsr pnt53
	beq pnt85
pnt86	lda #$00
	sta pnt10
	rts
pnt87	lda #$01
	sta pbuf+25
	lda #$00
	sta pbuf+26
	sta pbuf+13
	sta pbuf+22
	sta pbuf2+5
	sta pbuf2+6
	sta pbuf+12
	lda #$07
	sta pbuf2+4
	lda #$00
pnt88	jsr pnt44
	lda pbuf+13
	bne pnt86
	jsr pnt93
	bne pnt92
	jsr clrchn
	lda pbuf+9
	cmp #$07
	beq pnt90
	jsr disablexfer
	ldx #$02
	jsr chkout
	ldy #$07
pnt89	lda pbuf2,y
	jsr chrout
	iny
	cpy pbuf+9
	bne pnt89
	jsr clrchn
pnt90	lda pbuf2+6
	cmp #$ff
	bne pnt91
	lda #$01
	sta pbuf+13
	lda #$2a
	.byte $2c
pnt91	lda #$2d
	jsr goobad
	jsr pnt109
	lda #$00
	jmp pnt88
pnt92	jsr clrchn
	lda #$3a
	jsr goobad
	lda pbuf+23
	sta pbuf2+4
	lda #$03
	jmp pnt88
pnt93	lda pbuf2
	sta pbuf+14
	lda pbuf2+1
	sta pbuf+15
	lda pbuf2+2
	sta pbuf+16
	lda pbuf2+3
	sta pbuf+17
	jsr pnt79
	lda pbuf+23
	sta pbuf+9
	jsr pnt81
	lda pbuf2
	cmp pbuf+14
	bne pnt94
	lda pbuf2+1
	cmp pbuf+15
	bne pnt94
	lda pbuf2+2
	cmp pbuf+16
	bne pnt94
	lda pbuf2+3
	cmp pbuf+17
	bne pnt94
	lda #$00
	rts
pnt94	lda #$01
	rts
pnt95	lda #$00
	sta pbuf+25
	sta pbuf+26
	sta pbuf+13
	sta pbuf+22
	sta pbuf+12
	lda #$07
	clc
	adc #$01
	sta pbuf2+4
	lda #$00
pnt96	jsr pnt44
	lda pbuf+13
	bne pnt98
	jsr pnt93
	bne pnt97
	lda pbuf2+7
	sta pbuf+27
	lda #$01
	sta pbuf+13
	lda #$00
	jmp pnt96
pnt97	lda pbuf+23
	sta pbuf2+4
	lda #$03
	jmp pnt96
pnt98	lda #$00
	sta pnt10
	rts
pnt99	lda #$00
	sta pbuf+13
	sta pbuf+12
	lda #$01
	sta pbuf+22
	sta pbuf+29
	lda #$ff
	sta pbuf+25
	sta pbuf+26
	jsr pnt80
	ldy #$04
	lda #$07
	clc
	adc #$01
	sta ($64),y
	jsr pnt79
	ldy #$05
	lda #$ff
	sta ($64),y
	iny
	sta ($64),y
	ldy #$07
	lda pbuf+27
	sta ($64),y
	lda #$01
	sta pbuf+30
pnt100	jsr pnt53;transhand
	beq pnt100
	lda #$00
	sta pnt10
	rts
pnt101	inc pbuf+12
	lda pbuf+12
	cmp #$03
	bcc pnt102
	lda #$00
	sta pbuf+12
;lda pbuf+11;delay is always forced on no matter what now
;beq pnt103
;bne pnt106
pnt102	nop
pnt103	ldx #$00
pnt104	ldy #$00
pnt105	iny
	bne pnt105
	inx
;cpx #$78
	bne pnt104
pnt106	rts
pnt107	pha
	lda pbuf+25
	ora pbuf+26
	beq pnt108
	lda pbuf+29
	bne pnt108
	pla
	jsr goobad
	pha
pnt108	pla
	rts
pnt109
	jsr enablexfer
pnt110	rts
pnt111	ldx #$00
pnt112	lda pbuf2,x
	cmp #$0d
	bne pnt113
	inx
	cpx #$03
	bcc pnt112
	jmp pnt120
pnt113	jmp pnt29
pnt114
	lda $028d;$028d - check c= key;getnum routine
	cmp #$02
	bne pnt116
pnt115	pla
	tsx
	cpx pbuf+28
	bne pnt115
pnt116
	lda #$01
	sta pnt10
pnt117	rts
pnt120	tsx
	cpx pbuf+28
	beq pnt121
	pla
	sec
	bcs pnt120
pnt121	lda #$80
	sta pnt10
	jsr clrchn
	rts
	brk
	brk
ptrtxt	.byte 13,13,5,'new pUNTER ',00
upltxt	.byte 'uP',00
dowtxt	.byte 'dOWN',00
lodtxt	.byte 'LOAD.',13,00
flntxt	.byte 'eNTER fILENAME: ',00
xfrmed	.byte 13,158,32,32,0
xfrtxt	.byte 'LOADING: ',159,0
xf2txt	.byte 13,5,'  (pRESS c= TO ABORT.)',13,13,00
abrtxt	.byte 'aBORTED.',13,00
mrgtxt	.byte 153,32,'gOOD bLOCKS: ',5,'000',5,'   -   '
	.byte 153,'bAD bLOCKS: ',5,'000',13,0
gfxtxt	.byte 153,'gRAPHICS',00
gfxtxt2	.byte 18,31,'c',154,'/',159,'g',146,158,0
asctxt	.byte 159,'aNSCII',00
rdytxt	.byte ' tERMINAL rEADY.',155,13,13,00
rdytxt2	.byte ' tERM aCTIVATED.',155,13,13,00
dsctxt	.byte 13,13,5,'dISCONNECTING...',155,13,13,0
drtype	.byte 'D','S','P','U','R'
drtyp2	.byte 'E','E','R','S','E'
drtyp3	.byte 'L','Q','G','S','L'
drform	.byte 158,2,157,157,5,6,32,159,14,153,32,63,32,0
proto	.byte $08   ;start with
proto1	.byte $00   ;2400 baud setng
bdoutl	.byte $51
bdouth	.byte $0d
protoe	.byte $02 ;length of proto
dreset	.byte "I0"
diskdv	.byte $08
drivepresent
	.byte $01
alrlod	.byte 0
lastch	.byte 0
newbuf	.byte <endprg,>endprg
ntsc	.byte $00   ;pal=1 - ntsc =0
supercpubyte
	.byte $00
supertext
	.byte "sUPERcpu eNABLED!",13,13,0
nicktemp
	.byte $00
drivetemp
	.byte $00
;MAKECRCTABLE
crctable
		ldx 	#$00
		txa
zeroloop
	sta 	crclo,x
		sta 	crchi,x
		inx
		bne	zeroloop
		ldx	#$00
fetch		txa
		eor	crchi,x
		sta	crchi,x
		ldy	#$08
fetch1		asl	crclo,x
		rol	crchi,x
		bcc	fetch2
		lda	crchi,x
		eor	#$10
		sta	crchi,x
		lda	crclo,x
		eor	#$21
		sta	crclo,x
fetch2		dey
		bne	fetch1
		inx
		bne	fetch
		rts
;SuperCPU ROUTINES

turnonscpu
	lda supercpubyte
	beq scpuout
	lda #$01
	sta $d07b

scpuout	rts

turnoffscpu
	lda supercpubyte
	beq scpuout
	lda #$01
	sta $d07a
	rts

;CLEAR RS232 BUFFER POINTERS
clear232
	pha
	lda #$00
	sta rtail
	sta rhead
	sta rfree
	pla
	rts

puntdelay; you got a better way to do this? have at it!
	pha
	txa
	pha
	tya
	pha
pd3	ldx #$00
	ldy #$00
pd4
	inx
	bne pd4
	iny
	bne pd4
	pla
	tay
	pla
	tax
	pla
	rts

efbyte	.byte $00 ; 0 = no easyflash 1=easyflash mode
