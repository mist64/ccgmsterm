;
;phone book stuff begins here
entcol	.byte 5
hilcol	.byte 158
phhtxt
	.byte 19,13
	.byte 5,18,161
	.byte "crsr kEYS"
	.byte 182,146,154
	.byte " - mOVE"
	.byte 5,18,161
	.byte "rETURN"
	.byte 182,146,154
	.byte " - sELECT"
	.byte 13
	.byte 159,2
	.byte "DIAL uNLISTED #  "
	.byte 2
	.byte "EDIT cURRENT #"
	.byte 13
	.byte 2
	.byte "CALL cURRENT #   "
	.byte 2
	.byte "A-dIAL sELECTED"
	.byte 13,2
	.byte "REVERSE cALL     "
	.byte 2
	.byte "X-rETURN tO mENU"
	.byte 13
	.byte 152,3,5,0,18
	.byte "           >>>pHONE bOOK<<<           "
	.byte 29,20,32,157,148,32,13,0
stattx	.byte 152,3,21,0,18
	.byte "                                      "
	.byte 29,20
	.byte 32,157,148,32,13,145,18,0
staptx	.byte 152,3,21,0,18,32,0
	.byte 0
toetxt	.byte 3,6,0,0
curbtx	.byte 3,22,1,159
	.byte "nAME:"
	.byte 13
	.byte "   ip:"
	.byte 13,32
	.byte "pORT: "
	.byte 29,29,29,29,29
	.byte " id: "
	.byte 29,29,29,29,29,29,29,29,29,29,29
	.byte " tRY: "
	.byte 29,29,29,29,20,145,13,0
curbt3	.byte 3,22,1,159
	.byte "nAME:"
	.byte 13
	.byte " dIAL:"
	.byte 13,32
	.byte "      "
	.byte 29,29,29,29,29
	.byte "     "
	.byte 29,29,29,29,29,29,29,29,29,29,29
	.byte " tRY: "
	.byte 29,29,29,29,20,145,13,0
curbt2	.byte 159," pw:             ",0
curbt4	.byte 159," id: ",0
nontxt	.byte 5
	.byte "(nONE)             "
	.byte 13,0
clrlnt	.byte 3,22,7
	.byte "                  "
	.byte 3,22,7,5,0
empbbs	.byte 151,164,164,164,164,164,164,164,164,164,164,164,164
	.byte 164,164,164,164,164,164
curbbs	.byte 146
colbbs	.byte 153
nambbs	.byte "                "
	.byte 146,5,0
curpik	.byte 0
tmppik	.byte 0
bautmp	.byte 6
gratmp	.byte 0
prtstt
	pha
	tya
	pha
	lda #<staptx
	ldy #>staptx
	jsr outstr
	pla
	tay
	pla
	jsr outstr
	lda #$20
prtst2	ldx 211
	cpx #39
	bcs prtst3
	jsr chrout
	bne prtst2
prtst3	rts
phnptr
	lda curpik
	sta nlocat
	lda #83      ;len of one entry
	sta nlocat+1
	jsr multpy
	jmp phnpt4
multpy	clc
	lda #$00
	ldx #$08
phnpt2	ror a
	ror nlocat
	bcc phnpt3
	clc
	adc nlocat+1
phnpt3	dex
	bpl phnpt2
	sta nlocat+1
	rts
phnpt4
	lda nlocat
	clc
	adc #<phbmem
	sta nlocat
	lda nlocat+1
	adc #>phbmem
	sta nlocat+1
	ldy #$00
	rts
onpent
	lda hilcol
	bne prten0
prtent
	lda entcol
prten0	sta colbbs
prten1	lda #146
	sta curbbs
	ldy #0
	lda (nlocat),y
	beq prtcur
	lda #18
	sta curbbs
prtcur	ldy #2
prten2	lda (nlocat),y;print bbs name in list
	sta nambbs-2,y
	iny
	cpy #20;length of bbs name
	bcc prten2
	lda nambbs
	bne prten4
	ldy #1
prten3	lda empbbs,y;print lines in place of empty bbs names
	sta colbbs,y
	iny
	cpy #19
	bcc prten3
	lda colbbs
	cmp hilcol
	beq prten4
	lda empbbs
	sta colbbs
prten4
	ldy #$00
prten5	lda curbbs,y
	beq prten6
	jsr chrout
	iny
	bne prten5
prten6	lda #$0d
	jmp chrout
;
clrent
	lda #0
	sta curpik
clren1
	jsr phnptr
	lda #0
	sta (nlocat),y
	inc curpik
	lda curpik
	cmp #30
	bcc clren1
	jmp phinit
;
phinit
	lda #$30
	sta trycnt
	sta trycnt+1
	lda #$00
	sta curpik
	jsr clrchn
	lda #<phhtxt
	ldy #>phhtxt
	jsr outstr
	lda #<toetxt
	ldy #>toetxt
	jsr outstr
phini2
	lda #29
	jsr chrout
	jsr phnptr
	jsr prtent
	inc curpik
	lda curpik
	cmp #15
	bcc phini2
	lda #<toetxt
	ldy #>toetxt
	jsr outstr
phini3	lda #21  ;col 21
	sta 211
	jsr phnptr
	jsr prtent
	inc curpik
	lda curpik
	cmp #30
	bcc phini3
	lda #<stattx
	ldy #>stattx
	jsr outstr
	lda #0
	sta curpik
	lda #<curbtx
	ldy #>curbtx
	jsr outstr
	rts
phnroc	.byte 3,0,0,0
arrowt	.byte 32,93,93,32,60,125,109,62,32,32,0
hilcur
	ldx curpik
	inx
	txa
	and #$0f
	clc
	adc #5
	sta phnroc+1  ;row
	lda #1
	sta phnroc+2  ;col
	lda curpik
	cmp #15
	bcc hilcu2
	inc phnroc+1
	lda #21
	sta phnroc+2
hilcu2
	lda colbbs
	cmp hilcol
	bne hilcu7
	ldx toetxt+1
hilcu3
	lda $ecf0,x
	sta nlocat
	lda $d9,x
	and #$7f
	sta nlocat+1
	ldy #0
	cpx phnroc+1
	bne hilcu4
	ldy #4
	bne hilcu5
hilcu4
	bcc hilcu5
	ldy #8
	bne hilcu6
hilcu5
	lda phnroc+2
	cmp #20
	bcc hilcu6
	iny
	iny
hilcu6
	lda arrowt,y
	pha
	lda arrowt+1,y
	ldy #20
	sta (nlocat),y
	pla
	dey
	sta (nlocat),y
	lda nlocat+1
	clc
	adc #212
	sta nlocat+1
	lda #5    ;green
	sta (nlocat),y
	iny
	sta (nlocat),y
	inx
	cpx #21
	bcc hilcu3
hilcu7
	lda #<phnroc
	ldy #>phnroc
	jsr outstr
	jsr phnptr
	jmp prten1
posnam
	ldx curbtx+1
	dex
	stx 214
	lda #$0d
	jsr chrout
	lda #7    ;start at col 7
	sta 211
	rts
;
shocol	.byte 1,1
shocur
	jsr posnam
	lda #5
	sta colbbs
	lda #146
	sta curbbs
	ldy #2
	lda (nlocat),y
	bne shocrp
	lda #<nontxt
	ldy #>nontxt
	jsr outstr
	jmp shocr0
shocrp	jsr prtcur;print current on top list
shocr0	lda #7
	sta 211
	ldy #20
shocr1	lda (nlocat),y
	beq shocr2
	jsr chrout
	iny
	cpy #52;length of ip address
	bcc shocr1
shocr2	lda #$20
	ldx 211
	cpx #39;clear line for next one
	bcs shocr3
	jsr chrout
	bne shocr2
shocr3
;lda unlisted
;bne shotty
shobau;start display of bottom line
	lda #23
	sta 214
	lda #$0d
	jsr chrout
	lda #7
	sta 211
	lda shocol
	sta 646
	lda unlisted
	bne shocr5
	ldy #53
shocr4	lda (nlocat),y
	beq shocr5
	jsr chrout
	iny
	cpy #58;end of port
	bcc shocr4
shocr5	lda #$20
	ldx 211
	cpx #12;clear line for next one
	bcs shocr66
	jsr chrout
	bne shocr5
shocr66	lda #17
	sta 211
	lda unlisted
	bne shocr7
	ldy #59;start of user id
shocr6	lda (nlocat),y
	beq shocr7
	jsr chrout
	iny
	cpy #70;end of user id
	bcc shocr6
shocr7	lda #$20
	ldx 211
	cpx #29;clear line for next one
	bcs shocr8
	jsr chrout
	bne shocr7
shocr8
shotty
	lda #34
	sta 211
	lda #7
	sta 646
	lda #<trycnt
	ldy #>trycnt
	jsr outstr
	lda unlisted
	bne shotty3
shotty2
	lda #<curbtx
	ldy #>curbtx
	jsr outstr
	lda #19
	jmp chrout
shotty3
	lda #<curbt3
	ldy #>curbt3
	jsr outstr
;lda #$00
;sta unlisted
	lda #19
	jmp chrout
;

xorall
	lda #0
	sta curpik
xoral2
	jsr xorent
	inc curpik
	lda curpik
	cmp #30
	bcc xoral2
	rts
xorent
	jsr phnptr
	ldy #2
	lda (nlocat),y
	bne xortog
xorabt	rts
xortog
	ldy #0
	lda (nlocat),y
	eor #$01
	sta (nlocat),y
	rts
;
newent
	jsr posnam
	ldx #18
	ldy #0
	jsr inpset
	ldy #2
	lda (nlocat),y
	bne newen2
	dey
	lda bautmp
	sta (nlocat),y
	lda gratmp
	lsr a
	ror a
	ora (nlocat),y
	sta (nlocat),y
	lda #<clrlnt
	ldy #>clrlnt
	jsr outstr
	jmp newen4
newen2
	ldy #17
newenl	lda nambbs,y
	cmp #$20
	bne newen3
	dey
	bpl newenl
newen3	iny
	tya
	clc
	adc 211
	sta 211
newen4
	lda #1
	sta 646
	jsr inputl
	lda #0
	sta inpbuf,x
	cpx #0
	bne neweok
newugh	jmp zerent
neweok
	lda inpbuf
	cmp #$20
	beq newugh
	ldy #19
	lda #$20
newen5	sta (nlocat),y
	dey
	cpy #1
	bne newen5
	iny
	lda inpbuf
	sta (nlocat),y
	ldx #0
	ldy #2
newen6	lda inpbuf,x
	beq newen7
	sta (nlocat),y
	iny
	inx
	cpx #18
	bcc newen6
newen7;start of ip address
	lda #$0d
	jsr chrout
	lda #7
	sta 211
	ldy #0
	ldx #32;max length of entry
	jsr inpset
	ldy #20;top of entry
newen8	lda (nlocat),y
	beq newen9
	iny
	cpy #52;end of entry
	bcc newen8
newen9	tya
	sec
	sbc #20;start of entry
	clc
	adc 211
	sta 211
	jsr inputl
	lda #0
	sta inpbuf,x
	cpx #0
	bne newpok
	ldy #2
	sta (nlocat),y
	jmp newent
newpok
	tax
	ldy #20;start of entry
newena	lda inpbuf,x
	sta (nlocat),y
	beq newenb
	iny
	inx
	cpy #52;end of entry plus 1
	bcc newena
newenb
	ldy #23
	lda #$20
dalun2p	sta 1996,y;$079f
	dey
	bpl dalun2p
newen7a
	lda #$0d
	jsr chrout
	lda #7;start spot
	sta 211
	ldy #0
	ldx #5;max length of entry
	jsr inpset
	ldy #53;top of entry
newen8a	lda (nlocat),y
	beq newen9a
	iny
	cpy #58;end marker of entry
	bcc newen8a
newen9a	tya
	sec
	sbc #53;top marker of entry
	clc
	adc 211
	sta 211
	jsr inputl
	lda #0
	sta inpbuf,x
	cpx #0
	bne newpoka
	ldy #53
	sta (nlocat),y
	lda #$91
	jsr chrout
	jmp newenb
newpoka
	tax
	ldy #53;top of entry
newenaa	lda inpbuf,x
	sta (nlocat),y
	beq newenba
	iny
	inx
	cpy #58;end marker of entry plus one
	bcc newenaa
newenba
;display ID:
newen7id
	lda #12
	sta 211
	lda #<curbt4
	ldy #>curbt4
	jsr outstr
	lda #5
	jsr chrout
;display current id
	lda #17
	sta 211
	ldy #59;start of password
shocr6id
	lda (nlocat),y
	beq newen7b
	jsr chrout
	iny
	cpy #70;end of id
	bcc shocr6id
;enter id
newen7b
	lda #17;start spot
	sta 211
	ldy #0
	ldx #11;max length of entry
	jsr inpset
	ldy #59;top of entry
newen8b	lda (nlocat),y
	beq newen9b
	iny
	cpy #70;end marker of entry
	bcc newen8b
newen9b	tya
	sec
	sbc #59;top marker of entry
	clc
	adc 211
	sta 211
	jsr inputl
	lda #0
	sta inpbuf,x
	cpx #0
	bne newpokb
	ldy #59
	sta (nlocat),y
	jmp newen7c
newpokb
	tax
	ldy #59;top of entry
newenab	lda inpbuf,x
	sta (nlocat),y
	beq newenbb
	iny
	inx
	cpy #70;end marker of entry plus one
	bcc newenab
newenbb
;enter password
newen7c
	lda #12
	sta 211
	lda #<curbt2
	ldy #>curbt2
	jsr outstr
	lda #5
	jsr chrout
;display current pw
shocr66a
	lda #17
	sta 211
	ldy #71;start of password
shocr6a	lda (nlocat),y
	beq shocr7a
	jsr chrout
	iny
	cpy #82;end of password
	bcc shocr6a
shocr7a
	lda #17;start spot
	sta 211
	ldy #0
	ldx #11;max length of entry
	jsr inpset
	ldy #71;top of entry
newen8c	lda (nlocat),y
	beq newen9c
	iny
	cpy #82;end marker of entry
	bcc newen8c
newen9c	tya
	sec
	sbc #71;top marker of entry
	clc
	adc 211
	sta 211
	jsr inputl
	lda #0
	sta inpbuf,x
	cpx #0
	bne newpokc
	ldy #71
	sta (nlocat),y
	jmp newenbc
newpokc
	tax
	ldy #71;top of entry
newenac	lda inpbuf,x
	sta (nlocat),y
	beq newenbc
	iny
	inx
	cpy #82;end marker of entry plus one
	bcc newenac
newenbc
	lda #<stattx
	ldy #>stattx
	jmp outstr
zerent
	ldy #83
	lda #0
zeren2	sta (nlocat),y
	dey
	bpl zeren2
	rts
;
tmpopt	.byte 00
tmpmax	.byte 00
tmptmp	.byte 00
newsel
	jsr getin
	cmp #$2b;+
	bne newsl2
	inc tmpopt
	lda tmpopt
	cmp tmpmax
	bcc newsl1
	lda #0
	sta tmpmax
newsl1	sec
	rts
newsl2	cmp #$2d
	bne newsl3
	dec tmpopt
	bpl newsl1
	ldx tmpmax
	dex
	stx tmpopt
	sec
	rts
newsl3	cmp #$0d
	bne newsel
	clc
	rts
;
phbook
	lda #$93
	jsr chrout
	jsr phinit
phloop
	lda #$30
	sta trycnt
	sta trycnt+1
	lda hilcol
	sta colbbs
	jsr hilcur
	jsr shocur
phbget
	jsr getin
	cmp #$00
	beq phbget
	cmp #157  ;left
	bne phb2
	lda curpik
	sbc #15
	bcs phnupd
	adc #30
	jmp phnupd
phb2	cmp #29 ;right
	bne phb3
	lda curpik
	clc
	adc #15
	cmp #30
	bcc phnupd
	sbc #30
	jmp phnupd
phb3	cmp #145 ;up
	bne phb4
	lda curpik
	sbc #1
	bcs phnupd
	adc #30
	jmp phnupd
phb4	cmp #17  ;down
	bne phb5
	lda curpik
	clc
	adc #1
	cmp #30
	bcc phnupd
	sbc #30
phnupd
	pha
	lda entcol
	sta colbbs
	jsr hilcur
	pla
	sta curpik
	jmp phloop
phb5
	cmp #19
	bne phb6
phbhom	lda #0
	beq phnupd
phb6
	cmp #$93
	bne phb7
	jsr clrent
	jsr phinit
	jmp phloop
phb7
	and #$7f
	cmp #$58;x
	bne phb8
	jmp f7
phb8
	cmp #$20
	beq phnsel
	cmp #$0d
	bne phb9
phnsel	ldy #2
	lda (nlocat),y
	bne phntog
phabrt	jmp phbget
phntog
	ldy #0
	lda (nlocat),y
	eor #$01
	sta (nlocat),y
	jmp phloop
phb9	cmp #$52;r
	bne phb10
	jsr xorall
	jsr phinit
	jmp phloop
phb10
	cmp #$45
	bne phb11
	jsr newent
	jmp phloop
phb11
	cmp #$43
	bne phb12
	jmp dialts
phb12
	cmp #$41
	bne phb13
	jmp dalsel
phb13
	cmp #$44
	bne phb14
	jmp dalunl
phb14
	jmp phbget
;
dialts
	lda #0
	sta daltyp
	lda #<calctx
	ldy #>calctx
	jsr prtstt
;
dialcr
	jsr xferidpw
	jsr phnptr
	ldy #20
dialc1	lda (nlocat),y
	beq dialc2
	sta numbuf-20,y
	iny
	cpy #52
	bcc dialc1
dialc2
	lda #$3a
	sta numbuf-20,y
dialc5
	tya
	tax
	inx
	ldy #53
dialc4	lda (nlocat),y
	beq dialc6
	sta numbuf-20,x
	iny
	inx
	cpy #58
	bcc dialc4
dialc6
	lda #$0d
	sta numbuf-20,x
	lda numbuf
	cmp #$0d
	bne dialc3
	lda #0
	sta whahap
	jmp dalfin
dialc3;to be deleted - routine to use baud rate and c/g from phonebook entry
	lda #$00
	sta unlisted
	jmp dial
;
dalfin
	lda #$00
	sta unlisted
	lda whahap
	cmp #1
	bne dalf2    ;connected
	lda #<conntx
	ldy #>conntx
dalnv
	jsr prtstt
	lda #$e0
	sta $a2
dalfcl	lda $a2
	bne dalfcl
	lda #$0f
	sta $d418
;lda trycnt; this was just to be cute but not neccessary anymore
;cmp #4
;bcc dalfc1
;jsr gong
;jmp dalfc2
dalfc1	jsr bell
dalfc2
dalterm
	jmp term
dalf2
	cmp #2      ;aborted
	bne dalf3
	jmp dalfab
dalf3
	cmp #0
	bne dalf4
	lda daltyp  ;no connect
	cmp #2
	bcs dalslc
	lda numbuf
	cmp #$0d
	bne dalag
	jmp dlabrt
dalag
	jmp adnum   ;redial for curr/unl
dalslc
	lda #<stattx
	ldy #>stattx
	jsr outstr
	jmp dalsl0
dalsel	;dial selected
	lda #$30
	sta trycnt
	sta trycnt+1
	lda #<dalstx
	ldy #>dalstx
	jsr prtstt
dalsl0
	lda #2
	sta daltyp
	lda curpik
	sta tmppik
	lda entcol
	sta colbbs
	jsr hilcur
	lda trycnt+1
	cmp #$30
	beq dalsl3
dalsl1
	inc curpik
	lda curpik
	cmp #30
	bcc dalsl2
	lda #0
	sta curpik
dalsl2
	cmp tmppik
	bne dalsl3
	jmp dlabrt
dalsl3
	jsr phnptr
	ldy #0
	lda (nlocat),y
	beq dalsl1
	lda hilcol
	sta colbbs
	jsr hilcur
	jsr shocur
	jmp dialcr
dalf4
dalfab
	lda #<stattx
	ldy #>stattx
	jsr outstr
	jmp phloop
;
curunl
	.byte 145,13,32,159
	.byte "pORT: "
	.byte 05,0
prtunl
	.byte 145,13,32,159
	.byte "dIAL: "
	.byte 05,0
unlisted
	.byte $00
unltemp	.byte $00
dalunl
	lda #1
	sta daltyp
	lda entcol
	sta colbbs
	jsr hilcur
	lda #<dulstx
	ldy #>dulstx
	jsr prtstt
	lda grasfl
	beq dalun1
	lda #$80
dalun1
	jsr shocr3
	lda #<clrlnt
	ldy #>clrlnt
	jsr outstr
	lda #<unlstx
	ldy #>unlstx
	jsr outstr
	ldy #80
	lda #$20
dalun2	sta 1951,y;$079f
	dey
	bpl dalun2
	lda #7
	sta 211
	ldy #0
	ldx #32
	jsr input
	bne dalun3
	jmp dlabrt
dalun3
	ldx #$00
dalun6
	lda inpbuf,x
	sta numbuf,x
	inx
	lda inpbuf,x
	bne dalun6
	lda #$3a
	sta numbuf,x
	inx
	stx unltemp
dalun7
	ldy #80
	lda #$20
dalun9	sta 1951,y;$079f
	dey
	bpl dalun9
	lda #<curunl
	ldy #>curunl
	jsr outstr
	lda #7
	sta 211
	ldy #0
	ldx #5
	jsr input
	bne dalun8
	jmp dlabrt
dalun8
	ldx #$00
	ldy unltemp
dalun4	lda inpbuf,x
	sta numbuf,y
	inx
	iny
	lda inpbuf,x
	bne dalun4
	lda #$0d
	sta numbuf,y
	iny
	lda #$00
	sta numbuf,y
	ldy #$00
	lda #<prtunl
	ldy #>prtunl
	jsr outstr
	lda #<numbuf
	ldy #>numbuf
	jsr outstr
	lda #$91
	jsr chrout
	lda #$01
	sta unlisted
	jmp dial
;
calctx	.byte 'cALL cURRENT nUMBER...',0
dalstx	.byte 'dIAL sELECTED nUMBERS...',0
dulstx	.byte 'dIAL uNLISTED nUMBER.',0
unlstx	.byte 'uNLISTED.',13,0
wcrtxt	.byte 'wAITING fOR cARRIER...',0
pabtxt	.byte 'dIALING...  ',cp,'RESS ',cs,t,o,cp,' TO ABORT.',0
numptr	.byte 0
trycnt	.byte 0,0,0 ;how many tries?
daltyp	.byte 0 ;0=curr, 1=unlisted
	;2=selected
whahap	.byte 0 ;status after call
;0=busy/no carrier, 1=connect
;2=aborted w/stop , 3=dunno(1660)
;
;main body of dialer
dial
adnum
	lda #$0d
	jsr chrout
await0
	lda unlisted;unlisted gets a pass on the empty entry check;new mods for beta 7
	bne await01
	ldy #2;empty entry? don't dial!
	lda (nlocat),y
	bne await01
	jmp dlabrt
await01
	lda #$96      ;1.75 sec delay
	sta $a2
await1
	jsr getin    ;check r/s
	cmp #$03
	bne awaitl
	jmp dlabrt
awaitl
	lda $a2
	bne await1
adbegn
	lda #$88       ;2 sec delay
	sta $a2        ;for dial tone
await2
	lda $a2
	bne await2
	inc trycnt+1
	lda trycnt+1
	cmp #$3a
	bcc dialnoinc
	inc trycnt
	lda trycnt
	cmp #$3a
jeq	dlabrt
	lda #$30
	sta trycnt+1
dialnoinc
	jsr shocr3
dialin
	ldy #31
	lda #1
dlwhtl	sta 56223,y
	dey
	bpl dlwhtl
dlinit
	lda #<pabtxt  ;print stop aborts
	ldy #>pabtxt  ;
	jsr prtstt
smrtdl	;hayes/paradyne dial
	jsr clear232
	jsr enablemodem
	ldx #$05
	jsr chkout
	lda #<pr3txt
	ldy #>pr3txt
	jsr outmod
	lda mopo1
	bne haydat
	lda #<atdtxt;atdt
	ldy #>atdtxt
	jmp haydatcont
haydat
	lda #<atdtxt2;atd
	ldy #>atdtxt2
haydatcont
	jsr outstr
	ldx #$00
hayda4	stx numptr
	ldx numptr
	lda #14
	sta 56223,x
	ldx numptr
	lda numbuf,x
	jsr chrout
	ldx numptr
	inx
	cmp #$0d
	bne hayda4
	jsr clrchn
hayda6
	jmp haybus
haynan
	lda #<nantxt
	ldy #>nantxt
	jsr prtstt
	jmp haybk2
haybak
	lda #<bustxt
	ldy #>bustxt
	jsr prtstt
haybk2
	lda #$c8
	sta $a2
haybk3	lda $a2
	bne haybk3
	jsr haydel
	jmp redial
haycon
	jsr haydel
	lda #1     ;set connect flag
	sta whahap
	jmp dalfin
haydel
	lda #$e8
	sta $a2
	ldx #$05
	jsr chkin
haydll	jsr getin
	cmp #$0d
	beq haydlo
	lda $a2
	bne haydll
haydlo
	jsr clrchn
	rts
dlabrt
	lda #$d0
	sta $a2        ;short delay
dlablp
	lda $a2
	bne dlablp     ;back to phbook
dgobak
	lda #2
	sta whahap
	jmp dalfin
redial
	lda #$80
	sta $a2
rddel1	;2 second delay
	lda $a2        ;before restart
	bne rddel1
rgobak
	lda #0
	sta whahap     ;set redial flag
	jmp dalfin     ;back to phbook
outmod
	jsr outstr
outmo1	lda #$e0
	sta $a2
outmo2	lda $a2
	bne outmo2
	rts
;
nicktime
	.byte $00
atdtxt	.byte 'ATDT',0
atdtxt2	.byte 'ATD',34,0;adds a " before dialing the bbs cause zimmers firmware needs this
athtxt	.byte 'ATH',13,0
atplus	.byte '+++',0
pr3txt	.byte 'ATV1',13,0
bustxt	.byte "bUSY",0
nantxt	.byte "nO cARRIER",0
conntx	.byte "cONNECT!",0
tdelay	.byte 00

