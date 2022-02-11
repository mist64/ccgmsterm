;
;disk output routine
dskout
	jsr clrchn
	jsr cursor_show
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
	jsr cursor_off
	pla
	pha
	jsr check_control_codes
	jsr chrout
	jsr quote_insert_off
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
	ldx ascii_mode
	beq :+
	jsr petscii_to_ascii
:	jsr chrout
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
	jmp cursor_off
keyprs
	jsr clrchn
	jsr getin
	cmp #0
	rts
