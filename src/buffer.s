;
txt_buffer:
	.byte PETSCII_WHITE,"bUFFER ",0
buftx2	.byte " BYTES FREE.  "
	.byte 13,2
	.byte "OPEN  "
	.byte 2
	.byte "CLOSE  "
	.byte 2
	.byte "ERASE  "
	.byte 2
	.byte "TRANSFER"
	.byte 13,2
	.byte "LOAD  "
	.byte 2
	.byte "SAVE   "
	.byte 2
	.byte "PRINT  "
	.byte 2
	.byte "VIEW: "
	.byte 0
txt_open:
	.byte "oPEN",0
txt_closed:
	.byte "cLOSED",0
erstxt	.byte  "eRASE bUFFER! - "
	.byte 2
	.byte "YES OR "
	.byte 2
	.byte "NO?       "
	.byte 157,157,157,15,157,157,157,0
snbtxt	.byte 13,13
	.byte "sENDING BUFFER..."
	.byte 13,13,00
dontxt	.byte 13,13,PETSCII_WHITE
	.byte "dONE."
	.byte 13,0

txt_reu:
	.byte PETSCII_WHITE,"reu ",0

;----------------------------------------------------------------------
print_buffer_info:
	lda reu_enabled
	beq :+
	lda #<txt_reu
	ldy #>txt_reu
	jsr outstr
:	lda #<txt_buffer
	ldy #>txt_buffer
	jsr outstr
	lda buffer_open
	beq bufms1
	lda #<txt_open
	ldy #>txt_open
	clc
	bcc bufms2
bufms1
	lda #<txt_closed
	ldy #>txt_closed
bufms2
	jmp outstr

;----------------------------------------------------------------------
bufprm
	lda #$0d
	jsr chrout
	jsr print_buffer_info
	lda #' '
	jsr chrout
	lda #'-'
	jsr chrout
	lda #' '
	jsr chrout
	lda bufend
	sec
	sbc buffer_ptr
	tax
	lda bufend+1
	sbc buffer_ptr+1
	jsr outnum
	lda #<buftx2
	ldy #>buftx2
	jmp outstr

;----------------------------------------------------------------------
handle_f4_buffer:
	ldx SHFLAG
	cpx #SHFLAG_CBM
	bne buffrc
	jmp cf3
buffrc	;buffer cmds
	jsr cosave
bufask
	lda #$0d
	jsr chrout
	jsr bufprm
bufwat
	jsr savech
buflop
	jsr getin
	beq buflop
	and #127
	pha
	jsr restch
	pla
	cmp #$0d
	bne bufcmd
bufext
	lda #' '
	jsr chrout
	lda #$0d
	jsr chrout
	jsr chrout
	jsr coback
	jsr enablexfer
	jmp main
bufcmd
	cmp #'O'
	bne bufcm2
	ldx #$01
	stx buffer_open
	bne bufex1
bufcm2
	cmp #'C'
	bne bufcm3
	ldx #0
	stx buffer_open
bufex1
	ora #$80
bufexa
	jsr outcap
	lda #$0d
	jsr chrout
	lda #145  ;crsr up
	ldx #04
bufex2
	jsr chrout
	dex
	bpl bufex2
	jmp bufask
bufcm3
	cmp #'E'
	bne bufcm4
	ora #$80
	jsr outcap
	lda #$0d
	jsr chrout
	lda #145
	ldx #02
bufer1
	jsr chrout
	dex
	bpl bufer1
	lda #<erstxt
	ldy #>erstxt
	jsr outstr
	jsr savech
bufer2
	jsr getin
	beq bufer2
	and #127
	cmp #'N'
	beq bufer3
	cmp #'Y'
	bne bufer2
	jsr bufclr
bufer3
	jsr restch
	lda #145
	jsr chrout
	jsr chrout
	jmp bufask
bufcm4
	cmp #'P'
	bne bufvew
	ora #$80
	jsr outcap
	jmp bufpro
bufvew
	cmp #'V'
	bne bufcm5
	lda #$93
	jsr chrout
	lda #$80
	sta bufflg
	and #0
	sta buffl2
	jsr prtbuf
	jmp main
prtbuf	;buf.to screen
	lda buffst
	pha
	lda buffst+1
	pha
	lda #$2f
	sta $00
	lda #$36
	sta $01
	jsr dskout
	lda #$37
	sta $01
	pla
	sta buffst+1
	pla
	sta buffst
	rts
memget
	ldx buffst
	cpx buffer_ptr
	bcc memok
	ldx buffst+1
	cpx buffer_ptr+1
	bcc memok
memgab	ldx #$40
	stx status
	rts
memok
	ldy reu_enabled
	beq memok2
	jsr reuread
	jmp memok3
memok2
	ldy #0
	lda (buffst),y
memok3
	inc buffst
	bne memext
	inc buffst+1
memext
	ldx #0
	stx status
	rts
skpbuf
	lda buffst+1
	cmp buffer_ptr+1
	bcs memgab
	inc buffst+1
skpbf2
	lda buffst+1
	cmp buffer_ptr+1
	bcc memext
	lda buffst
	cmp buffer_ptr
	bcs memgab
	bcc memext
;
bufcm5
	cmp #'S'
jne	bufcm6
	jsr solfil
	jmp savbuf
solfil
	ora #$80
	jsr outcap
	lda #$0d
	jsr chrout
	jsr chrout
	jsr ui_get_filename
	bne solfok
	jmp ui_abort
solfok	rts
savbuf
	jsr disablexfer;to be save 5-13 fix?? worked without it, but this should be here
	lda #0
	sta mulcnt
	lda #$02
	sta filetype
	jsr dowsfn
	lda #$36
	sta $01
	lda buffst;start of buffer
	sta $c1;I/O Start Address ($c1 $c2)
	lda buffst+1
	sta $c2
	lda buffer_ptr;end of buffer
	clc
	adc #$01
	sta $ae;Tape End Addresses/End of Program ($ae / $af)
	lda buffer_ptr+1
	adc #0
	sta $af
	lda #$61
	sta $b9
	jsr $f3d5;open file on serial bus
	jsr $f68f;print saving and filename
	lda $ba
	jsr $ed0c;send listen to serial bus
	lda $b9
	jsr $edb9;LSTNSA. Send LISTEN secondary address to serial bus
	ldy #0
	jsr $fb8e;Move the Tape SAVE/LOAD Address into the Pointer at 172 ($ac)
	lda reu_enabled
	beq afuckit
	jsr af624
	lda #$00
	sta buffst
	sta buffst+1
	jmp amoveon
afuckit	jsr $f624
amoveon
	php
	lda #$37
	sta $01
	plp
	bcc bsaved
	lda #$0d
	jsr chrout
	jsr bell
	lda #$00
	sta buffst
	sta buffst+1
	jmp ui_abort
;reu needs a special save routine cause craig decided to be all fancy with this one :)
af624	jsr $fcd1;check the tape read/write pointer
af627	bcs af63f;
af629	;lda ($ac),y
	jsr reuread
af62b	jsr $eddd;send a byte to an i/o device over the serial bus
af62e	jsr $ffe1;stop. query stop key indicator, at memory address $0091; if pressed, call clrchn and clear keyboard buffer.
af631	bne af63a
af633	jsr $f642
af636	lda #$00
af638	sec
af639	rts
af63a
	inc buffst
	lda buffst
	beq anext
	jsr $fcdb
	bne af624
anext	inc buffst+1
	jsr $fcdb;advance tape pointer
af63d	bne af624
af63f	jsr $edfe;UNLSTN.
afnext	jmp $f642
;done
bsaved
	jsr enablexfer
	jmp bufext
bufcm6
	cmp #'L'
	bne bufcm7
	jsr solfil
lodbuf
	jsr disablexfer;5-13 put in, didnt seem to need it, need to test with it. might crash with it cause the program does that sometimes....
	lda #$02
	ldx diskdv
	tay
	jsr setlfs
	lda max
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	jsr open
	ldx #$02
	jsr chkin
lodbfl
	jsr getin
	ldx status
	bne lodbex
	ldx buffer_ptr
	cpx bufend
	bne lodbok
	ldx buffer_ptr+1
	cpx bufend+1
	beq lodbex
lodbok
	ldy reu_enabled
	beq lodbokram
	jsr reuwrite
	jmp lodbokreu
lodbokram
	ldy #0
	sta (buffer_ptr),y
lodbokreu
	inc buffer_ptr
	bne lodbfl
	inc buffer_ptr+1
	bne lodbfl
lodbex
	jsr clrchn
	lda #$02
	jsr close
	jsr enablexfer
	jmp bufext
bufcm7
	cmp #'T'
	beq sndbuf
	cmp #'<'
	beq bufchg
	cmp #'>'
	bne bufbak
bufchg
	jsr chgbpr
	jmp bufexa
bufbak
	jmp bufwat
sndbuf
	ora #$80
	jsr outcap
	lda #<snbtxt
	ldy #>snbtxt
	jsr outstr
	lda #$ff
	sta bufflg
	sta buffl2
	jsr prtbuf
	jsr cosave
	jsr clear232
	lda #<dontxt
	ldy #>dontxt
	jsr outstr
	jsr coback
	jsr enablexfer
	jmp main
chgbpr
	pha
	cmp #'>'
	beq chgbp3
	lda buffer_ptr+1
	cmp #>endprg
	bne chgbp1
	lda buffer_ptr
	cmp #<endprg
	beq chgben
chgbp1
	lda buffer_ptr
	bne chgbp2
	dec buffer_ptr+1
chgbp2	dec buffer_ptr
	jmp chgben
chgbp3
	lda buffer_ptr+1
	cmp bufend
	bne chgbp4
	lda buffer_ptr
	cmp bufend+1
	beq chgben
chgbp4
	inc buffer_ptr
	bne chgben
	inc buffer_ptr+1
chgben
	ldx #1
	stx 651
	pla
	rts
;
bufpdt	.byte 13,13,"dEVICE",0
bufpda	.byte 13,cs,'ec.',ca,'.: ',0
bufpdp	.byte $93,13,cp,'rinting...',13,0
bufpro
	lda #<bufpdt
	ldy #>bufpdt
	ldx #1
	jsr inpset
	lda #'4'
	jsr chrout
	jsr inputl
	bne bufpr2
bufpra	lda #$0d
	jsr chrout
	jmp ui_abort
bufpr2	lda inpbuf
	cmp #'3'
	bcc bufpra
	cmp #'6'
	bcs bufpra
	and #$0f
	pha
	lda #<bufpda
	ldy #>bufpda
	ldx #1
	jsr inpset
	lda #'7'
	jsr chrout
	jsr inputl
	beq bufpra
	lda inpbuf
	cmp #'0'
	bcc bufpra
	cmp #':'
	bcs bufpra
	and #$0f
	tay
	pla
	tax
	lda #4
	jsr setlfs
	lda #0
	jsr setnam
	lda #<bufpdp
	ldy #>bufpdp
	jsr outstr
	jsr open
	ldx status
	bne bufpr3
	lda buffst
	pha
	lda buffst+1
	pha
	lda #$2f
	sta $00
	lda #$36
	sta $01
	jsr mempro
	lda #$37
	sta $01
	pla
	sta buffst+1
	pla
	sta buffst
bufpr3
	lda #4
	jsr close
	lda #<dontxt
	ldy #>dontxt
	jsr outstr
	jsr coback
	jsr enablexfer
	jmp main
mempro
mempr2
	jsr memget
	bne mempr3
	pha
	and #$7f
	cmp #$0d
	beq memprp
	cmp #$20
	bcc mempab
memprp
	ldx #4
	jsr chkout
	pla
	jsr chrout
	ldx status
	bne mempr3
	jmp mempr2
mempab	pla
	jmp mempr2
mempr3
	jmp clrchn
