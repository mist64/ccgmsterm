; Show disk directory

dirmdm:
	.byte 0

dirfn:
	.byte '$'

dir:
	jsr disablexfer
	lda #$0d
	ldx device_disk
	ldy #0
	jsr setlfs
	jsr drvchk
	jmi drexit
	jsr clrchn
	jsr cosave
	lda #$0d
	jsr chrout
	jsr open
	lda #0
	sta dirmdm
	lda SHFLAG
	cmp #SHFLAG_CBM	; c= f6
	bne :+
	lda #1
	sta dirmdm
:	ldx #$0d
	jsr chkin
	ldy #03
@loop:	jsr getch
	dey
	bpl @loop
	jsr getch
	sta $0b
	jsr getch
	ldx $0b
	jsr outnum
	lda #$20
	jsr chrout
@skip:	jsr getch
	ldx dirmdm
	beq @1
	cmp #0
	beq @2
	cmp #' '
	bcc @skip
@1:	jsr chrout
	bne @skip
@2:	jsr drret
	ldy #01
	bne @loop

getch:
	jsr getin
	ldx status
	bne drlp3
	cmp #0
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

drret:
	lda #$0d
	jsr chrout
	jsr clrchn
	jsr getin
	beq @cont
	cmp #$03
	beq drlp3
	lda #$00
	sta $c6
:	jsr getin
	beq :-
@cont:	ldx dirmdm
	beq dircoe
	lda #CSR_UP
	jsr chrout
	lda #3		; screen
	sta 153		; def input dev
	ldx #LFN_MODEM
	jsr chkout
	ldy #0
drcon2
	lda #5
	sta dget2
	jsr dirget	; grab bytes in buffer so we dont lock up nmis
	bcs :+		; no bytes
	jmp drcon2	; [XXX bcc drcon2 would work]
:	jsr disablexfer
	jsr getin
	jsr enablexfer
	jsr chrout
	tya
	pha
	lda #$15
	sta dget2
	jsr dirget	; grab bytes in buffer so we dont lock up nmis
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
	ldx #LFN_MODEM
	jsr chkin
:	jsr getin
	lda $029b
	cmp $029c
	bne :-
dircoe:
	jsr clrchn
	ldx #$0d
	jmp chkin

drvchk:
	lda #0
	sta status
	lda device_disk
	jsr $ed0c
	lda #$f0
	jsr $edbb
	ldx status
	bmi :+
	jsr $f654
	lda #0
:	rts

;this timeout failsafe makes sure the byte is received back from modem
;before accessing disk for another byte otherwise we can have
;all sorts of nmi related issues.... this solves everything.
;uses the 'fake' rtc / jiffy counter function / same as xmmget...
dirget:
dget2=*+1
	lda #10		; timeout failsafe
	sta xmodel
	lda #0
	sta rtca1
	sta rtca2
	sta rtca0
@1:	jsr modget
	bcs :+		; [XXX bcc @rts]
	jmp @rts
:	jsr xmmrtc
	lda rtca1
	cmp xmodel
	bcc @1
@rts:	rts
