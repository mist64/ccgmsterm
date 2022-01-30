;
losvco
	jsr disablexfer
	jsr ercopn
	lda #<svctxt
	ldy #>svctxt
	ldx #16
	jsr inpset
	lda #<conffn
	ldy #>conffn
	jsr outstr
	jsr inputl
	beq losvex
	txa
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #2
	ldx diskdv
	ldy #0
	jsr setlfs
	ldx $b7
losvex
	rts
svconf
	lda efbyte;are we in easyflash mode?
	beq svcon44;no? then just go to disk mode
	lda diskoref;is config in easyflash or disk mode?
	beq savecfef
svcon44
	jsr losvco
	bne svcon2
svcon2
	ldx #15
	jsr chkout
	ldx #0
svcon3	lda scracf,x
	beq svcon4
	jsr chrout
	inx
	bne svcon3
svcon4
	ldx #0
svcon5	lda inpbuf,x
	jsr chrout
	inx
	cpx max
	bcc svcon5
	lda #$0d
	jsr chrout
	jsr clrchn
	lda #<config
	sta nlocat
	lda #>config
	sta nlocat+1
	lda #nlocat
	ldx #<endsav
	ldy #>endsav
	jsr $ffd8
	jsr losver
losvab	rts
savecfef
	jmp writeconfigef
loconf
	lda efbyte;do we have an easyflash?
	beq loadcf2;nope, we are using the non-easyflash version
	lda diskoref
	beq loadcfef
loadcf2
	jsr losvco
	beq losvab
loadcf
	ldx #<config
	ldy #>config
	lda #0     ;load
	jsr $ffd5
	jsr losver
loadcfpart2
	jsr themeroutine
	jsr rsopen
	rts
loadcfef
	jsr readconfigef
	jmp loadcfpart2
losver
	jsr disablemodem
	ldx #15
	jsr chkin
losve2	jsr getin
	cmp #$0d
	bne losve2
	jmp clrchn
