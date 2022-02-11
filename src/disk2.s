dsktxt	.byte 5,13
	.byte "#"
dsktx2	.byte "**>      "
	.byte 157,157,157,157,157,157,00
dskdtx	.byte '8 9 101112131415161718192021222324252627282930'

;----------------------------------------------------------------------
handle_f5_diskcommand:
	;disk command
	jsr disablexfer
	jsr ercopn
	jsr cosave
dskcmd
	lda diskdv
	sec
	sbc #$08
	asl a
	tay
	lda dskdtx,y
	sta dsktx2
	lda dskdtx+1,y
	sta dsktx2+1
	lda #<dsktxt
	ldy #>dsktxt
	ldx #36;1 - what does this do? limit length of command?
	jsr input
	beq drverr;nothing entered, drive error code?
	lda inpbuf
	cmp #$23;# drive
	beq chgdev
	jsr drvchk
	bmi drvext
	lda #$0d;return - exit
	jsr chrout
	lda inpbuf
	cmp #$24;$ directory
	bne drvsnd
	lda max
	ldx #<inpbuf
	ldy #>inpbuf
	jmp dodir
drvsnd
	ldx diskdv
	stx 612    ;dev# table, log#15
	ldx #$0f
	jsr chkout
	ldx #$00
drvlop
	lda inpbuf,x
	jsr chrout
	inx
	cpx max
	bne drvlop
	lda #$0d
	jsr chrout
drvext
	jsr clrchn
	jsr coback
	lda #$0d
	jsr chrout
	jsr enablexfer
	jmp main
drverr
	jsr drvchk
	bmi drvext
	jsr clrchn
	ldx #$0f
	jsr chkin
drver2
	jsr getin
drver3
	jsr chrout
	cmp #$0d
	bne drver2
	beq drvext
chgdev;modded this for drives over #15
	ldy #$01
	ldx inpbuf,y
	txa
	sec
	sbc #$30
	beq chgdv2;if first char is 0 as in 08 or 09
	cmp #$03;devices 10-29 "1x or 2x"
	bpl chgdv8;might be 8 or 9.. anything over 3 doesnt count here so lets try and see if it matches 8 or 9.
	clc;definitely starts with 1 or 2 if it makes it this far
	adc #$09   ;$0a-$0b for device starting with 1x or 2x, convert to hex
	jmp chgdv2
chgdv8
	cmp #$07
	bpl chgdv9;assume its 8 or 9, which is the only options when it starts with 8 or 9
	jmp drvext;nope there was nothing in the 00-29 range
chgdv2	iny;get the second character
	sta drivetemp
	lda inpbuf,y
	sec
	sbc #$30;decimal petscii to hex, again...
	clc
	adc drivetemp
chgdv9
	cmp #$08;lowest drive # (8)
	bcc drvext
	cmp #$1e;highest drive # (30)
	bcs drvext
	tay;y now holds complete hex of drive #
	lda diskdv
	pha
	sty diskdv
	sty 612
	jsr drvchk
	bmi chgdv3
	pla
	lda #145
	jsr chrout
	jmp dskcmd
chgdv3
	pla
	sta diskdv
	sta 612
chgdv4
	lda #$20
	jsr chrout
	lda #$2d
	jsr chrout
	lda #$20
	jsr chrout
	ldy #$00
chgdv5
	lda $a1d0,y  ;device not present
	php
	and #$7f
	jsr chrout
	plp
	bmi chgdv6
	iny
	bne chgdv5
chgdv6
	jmp drvext
