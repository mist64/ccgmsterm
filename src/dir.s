dirmdm	.byte 0
;directory routine
dirfn	.byte '$'
dir
	jsr disablexfer
	lda #$0d
	ldx diskdv
	ldy #$00
	jsr setlfs
	jsr drvchk
	bpl dirst
	jmp drexit
dirst
	jsr clrchn
	jsr cosave
	lda #$0d
	jsr chrout
	jsr open
	lda #0
	sta dirmdm
	lda SHFLAG
	cmp #SHFLAG_CBM	; c= f6
	bne dirlp0
	lda #1
	sta dirmdm
dirlp0
	ldx #$0d
	jsr chkin
	ldy #03
drlp1
	jsr getch
	dey
	bpl drlp1
	jsr getch
	sta $0b
	jsr getch
	ldx $0b
	jsr outnum
	lda #$20
	jsr chrout
drlp2
	jsr getch
	ldx dirmdm
	beq drlpm
	cmp #0
	beq drlpm2
	cmp #$20
	bcc drlp2
drlpm
	jsr chrout
	bne drlp2
drlpm2
	jsr drret
	ldy #01
	bne drlp1
getch
	jsr getin
	ldx status
	bne drlp3
	cmp #00
	rts
drlp3
	pla
	pla
drexit
	jsr clrchn
	jsr coback
	lda #$0d
	jsr chrout
	jsr close
	jmp enablexfer
drret
	lda #$0d
	jsr chrout
	jsr clrchn
	jsr getin
	beq drcont
	cmp #$03
	beq drlp3
	lda #$00
	sta $c6
drwait
	jsr getin
	beq drwait
drcont
	ldx dirmdm
	beq dircoe
	lda #145
	jsr chrout
	lda #3     ;screen
	sta 153    ;def input dev
	ldx #5
	jsr chkout
	ldy #0
drcon2
	lda #$5
	sta dget2+1
	jsr dirget;grab bytes in buffer so we dont lock up nmis
	bcs drcon4 ; no bytes
	jmp drcon2
drcon4
	jsr disablexfer
	jsr getin
	jsr enablexfer
	jsr chrout
	tya
	pha
	lda #$15
	sta dget2+1
	jsr dirget;grab bytes in buffer so we dont lock up nmis
drcon6
	pla
	tay
	iny
	cpy #27
	bcc drcon2
	lda #$0d
	jsr chrout
	jsr clrchn
	lda #$0d
	jsr chrout
	ldx #5
	jsr chkin
drcon3	jsr getin
	lda $029b
	cmp $029c
	bne drcon3
dircoe
	jsr clrchn
	ldx #$0d
	jmp chkin
drvchk
	lda #00
	sta status
	lda diskdv
	jsr $ed0c
	lda #$f0
	jsr $edbb
	ldx status
	bmi drc2
	jsr $f654
	lda #$00
drc2	rts
dirget	;this timeout failsafe makes sure the byte is received back from modem
	;before accessing disk for another byte otherwise we can have
	;all sorts of nmi related issues.... this solves everything.
	;uses the 'fake' rtc / jiffy counter function / same as xmmget...
dget2	lda #10;timeout failsafe
	sta xmodel
	lda #0
	sta rtca1
	sta rtca2
	sta rtca0
ddxmogt1
	jsr modget
	bcs ddxmmgt2
	jmp dirgetout
ddxmmgt2
	jsr xmmrtc
	lda rtca1
	cmp xmodel
	bcc ddxmogt1
dirgetout
	rts
