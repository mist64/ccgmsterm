;
;disk output routine
dskout
	jsr clrchn
	jsr curprt
	lda bufflg  ;bufflg 00=disk
	bpl dskmo   ;$40=disk w. delay
	jsr memget  ;$80=memory get
	bit bufflg  ;$ff=mem w. delay
	bvs timdel
	ldx #$ff
mrloop
	dex
	bne mrloop
	beq chstat
dskmo
	jsr disablexfer
	ldx #02
	jsr chkin
	jsr getin
	pha
	pla
timdel
	bit bufflg
	bvc chstat
	jsr tmsetl
chstat
	pha
	lda status
	and #$40
jne	dskext
	jsr clrchn
	jsr curoff
	pla
	pha
	jsr ctrlck
	jsr chrout
	jsr qimoff
	ldx buffl2 ;non zero=to modem
	bne dskmo1
	pla
	jmp chkkey
dskmo1
	jsr clear232
	jsr enablexfer
	jsr clear232
	ldx #05
	jsr chkout
	pla
	ldx grasfl
	beq dskmo2
	jsr catosa
dskmo2
	jsr chrout
dxmmget;this timeout failsafe makes sure the byte is received back from modem
	;before accessing disk for another byte otherwise we can have
	   ;all sorts of nmi related issues.... this solves everything.
	   ;uses the 'fake' rtc / jiffy counter function / same as xmmget...
	lda #70;timeout failsafe
	sta xmodel
	lda #0
	sta rtca1
	sta rtca2
	sta rtca0
dxmogt1
	jsr modget
	bcs dxmmgt2
	jmp chkkey
dxmmgt2
	jsr xmmrtc
	lda rtca1
	cmp xmodel
	bcc dxmogt1
chkkey
	jsr keyprs
jeq	dskout
	cmp #3;run stop
	beq dskex2
	jsr enablexfer
	cmp #'S'
	bne dskwat
	lda bufflg
	bpl dskwat
	jsr skpbuf
	ldx status
	bne dskex2
	jsr enablexfer
	jmp dskout
dskwat
	jsr keyprs
	beq dskwat
	jsr enablexfer
	jmp dskout
dskext
	jsr enablexfer
	pla
dskex2
	jsr clrchn
	jmp curoff
keyprs
	jsr clrchn
	jsr getin
	cmp #0
	rts
outstr
	sty $23
	sta $22
	ldy #0
outst1	lda ($22),y
	beq outste
	cmp #2
	beq hilite
	cmp #03
	bne outst2
	iny
	lda ($22),y
	sta LINE
	lda #$0d
	jsr chrout
	lda #145
	jsr chrout
	iny
	lda ($22),y
	sta 211
	bne outst4
outst2
	cmp #$c1
	bcc outst3
	cmp #$db
	bcs outst3
	lda 53272
	and #$02
	php
	lda ($22),y
	plp
	bne outst3
	and #$7f
outst3
	jsr chrout
outst4	iny
	bne outst1
	inc $23
	bne outst1
outste	rts
hilite
	lda textcl
	pha
	lda #1
	sta textcl
	lda #18   ;rvs-on
	jsr chrout
	lda #161
	jsr chrout
	lda 53272
	and #2
	php
	iny
	lda ($22),y
	plp
	beq hilit2
	ora #$80
hilit2	jsr chrout
	lda #182
	jsr chrout
	pla
	sta textcl
	lda #146
	bne outst3
;
outcap
	cmp #$c1    ;cap 'a'
	bcc outcp3
	cmp #$db    ;cap 'z'
	bcs outcp3
	pha
	lda 53272
	and #2
	beq outcp2
	pla
	bne outcp3
outcp2	pla
	and #$7f
outcp3	jmp chrout
