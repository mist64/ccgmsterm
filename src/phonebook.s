; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Phone Book
;

entcol	.byte WHITE
hilcol	.byte YELLOW

txt_phonebook_menu:
	.byte HOME,CR
	.byte WHITE,RVSON,$a1	; $A1: LEFT HALF BLOCK ('▌')
	.byte "crsr kEYS"
	.byte $b6,RVSOFF,LTBLUE	; $B6: RIGHT THREE EIGHTHS BLOCK
	.byte " - mOVE"
	.byte WHITE,RVSON,$a1
	.byte "rETURN"
	.byte $b6,RVSOFF,LTBLUE
	.byte " - sELECT"
	.byte CR
	.byte CYAN,HILITE
	.byte "DIAL uNLISTED #  "
	.byte HILITE
	.byte "EDIT cURRENT #"
	.byte CR
	.byte HILITE
	.byte "CALL cURRENT #   "
	.byte HILITE
	.byte "A-dIAL sELECTED"
	.byte CR,HILITE
	.byte "REVERSE cALL     "
	.byte HILITE
	.byte "X-rETURN tO mENU"
	.byte CR
	.byte GRAY,SETCSR,5,0,RVSON
	.byte "           >>>pHONE bOOK<<<           "
	.byte CSR_RIGHT,DEL,' ',CSR_LEFT,INST,' ',CR,0
stattx	.byte GRAY,SETCSR,21,0,RVSON
	.byte "                                      "
	.byte CSR_RIGHT,DEL
	.byte ' ',CSR_LEFT,INST,' ',CR,CSR_UP,RVSON,0
staptx	.byte GRAY,SETCSR,21,0,RVSON,' ',0
	.byte 0
toetxt	.byte SETCSR,6,0,0

curbtx:
	.byte SETCSR,22,1
tcol28a	.byte CYAN
	.byte "nAME:"
	.byte CR
	.byte "   ip:"
	.byte CR,' '
	.byte "pORT: "
	.res 5,CSR_RIGHT
	.byte " id: "
	.res 11,CSR_RIGHT
	.byte " tRY: "
	.res 4,CSR_RIGHT
	.byte DEL,CSR_UP,CR,0
curbt3	.byte SETCSR,22,1
tcol28b	.byte CYAN
	.byte "nAME:"
	.byte CR
	.byte " dIAL:"
	.byte CR,' '
	.byte "      "
	.res 5,CSR_RIGHT
	.byte "     "
	.res 11,CSR_RIGHT
	.byte " tRY: "
	.res 4,CSR_RIGHT
	.byte DEL,CSR_UP,CR,0
curbt2:
tcol28c	.byte CYAN
	.byte " pw:             ",0

curbt4:
tcol28d	.byte CYAN
	.byte " id: ",0
nontxt	.byte WHITE
	.byte "(nONE)             "
	.byte CR,0
clrlnt	.byte SETCSR,22,7
	.byte "                  "
	.byte SETCSR,22,7,WHITE,0
empbbs	.byte DKGRAY
	.res RVSON, UNDERLINE
curbbs	.byte RVSOFF
colbbs	.byte LTGREEN
nambbs	.byte "                "
	.byte RVSOFF,WHITE,0
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
prtst2	ldx COLUMN
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
	lda #0
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
	ldy #0
	rts
onpent
	lda hilcol
	bne prten0
prtent
	lda entcol
prten0	sta colbbs
prten1	lda #RVSOFF
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
	cpy #20		; length of bbs name
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
	ldy #0
prten5	lda curbbs,y
	beq prten6
	jsr chrout
	iny
	bne prten5
prten6	lda #CR
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
	lda #0
	sta curpik
	jsr clrchn
	lda #<txt_phonebook_menu
	ldy #>txt_phonebook_menu
	jsr outstr
	lda #<toetxt
	ldy #>toetxt
	jsr outstr
phini2
	lda #CSR_RIGHT
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
	sta COLUMN
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
phnroc	.byte SETCSR,0,0,0
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
	stx LINE
	lda #CR
	jsr chrout
	lda #7    ;start at col 7
	sta COLUMN
	rts
;
shocol	.byte 1,1
shocur
	jsr posnam
	lda #5
	sta colbbs
	lda #RVSOFF
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
	sta COLUMN
	ldy #20
shocr1	lda (nlocat),y
	beq shocr2
	jsr chrout
	iny
	cpy #52;length of ip address
	bcc shocr1
shocr2	lda #$20
	ldx COLUMN
	cpx #39;clear line for next one
	bcs shocr3
	jsr chrout
	bne shocr2
shocr3
;lda unlisted
;bne shotty
shobau;start display of bottom line
	lda #23
	sta LINE
	lda #CR
	jsr chrout
	lda #7
	sta COLUMN
	lda shocol
	sta textcl
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
	ldx COLUMN
	cpx #12;clear line for next one
	bcs shocr66
	jsr chrout
	bne shocr5
shocr66	lda #17
	sta COLUMN
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
	ldx COLUMN
	cpx #29		; clear line for next one
	bcs shocr8
	jsr chrout
	bne shocr7
shocr8
shotty
	lda #34
	sta COLUMN
	lda #7
	sta textcl
	lda #<trycnt
	ldy #>trycnt
	jsr outstr
	lda unlisted
	bne shotty3
shotty2
	lda #<curbtx
	ldy #>curbtx
	jsr outstr
	lda #HOME
	jmp chrout
shotty3
	lda #<curbt3
	ldy #>curbt3
	jsr outstr
;	lda #0
;	sta unlisted
	lda #HOME
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
	eor #1
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
	adc COLUMN
	sta COLUMN
newen4
	lda #1
	sta textcl
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
	lda #CR
	jsr chrout
	lda #7
	sta COLUMN
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
	adc COLUMN
	sta COLUMN
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
	lda #CR
	jsr chrout
	lda #7;start spot
	sta COLUMN
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
	adc COLUMN
	sta COLUMN
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
	sta COLUMN
	lda #<curbt4
	ldy #>curbt4
	jsr outstr
	lda #5
	jsr chrout
;display current id
	lda #17
	sta COLUMN
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
	sta COLUMN
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
	adc COLUMN
	sta COLUMN
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
	sta COLUMN
	lda #<curbt2
	ldy #>curbt2
	jsr outstr
	lda #5
	jsr chrout
;display current pw
shocr66a
	lda #17
	sta COLUMN
	ldy #71;start of password
shocr6a	lda (nlocat),y
	beq shocr7a
	jsr chrout
	iny
	cpy #82;end of password
	bcc shocr6a
shocr7a
	lda #17;start spot
	sta COLUMN
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
	adc COLUMN
	sta COLUMN
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
newsl3	cmp #CR
	bne newsel
	clc
	rts
;
phbook
	lda #CLR
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
	cmp #0
	beq phbget
	cmp #CSR_LEFT
	bne phb2
	lda curpik
	sbc #15
	bcs phnupd
	adc #30
	jmp phnupd
phb2	cmp #CSR_RIGHT
	bne phb3
	lda curpik
	clc
	adc #15
	cmp #30
	bcc phnupd
	sbc #30
	jmp phnupd
phb3	cmp #CSR_UP
	bne phb4
	lda curpik
	sbc #1
	bcs phnupd
	adc #30
	jmp phnupd
phb4	cmp #CSR_DOWN
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
	cmp #CLR
	bne phb7
	jsr clrent
	jsr phinit
	jmp phloop
phb7
	and #$7f
	cmp #'X'
	bne phb8
	jmp handle_f7_config
phb8
	cmp #' '
	beq phnsel
	cmp #CR
	bne phb9
phnsel	ldy #2
	lda (nlocat),y
	bne phntog
phabrt	jmp phbget
phntog
	ldy #0
	lda (nlocat),y
	eor #1
	sta (nlocat),y
	jmp phloop
phb9	cmp #'R'
	bne phb10
	jsr xorall
	jsr phinit
	jmp phloop
phb10
	cmp #'E'
	bne phb11
	jsr newent
	jmp phloop
phb11
	cmp #'C'
	bne phb12
	jmp dialts
phb12
	cmp #'A'
	bne phb13
	jmp dalsel
phb13
	cmp #'D'
	bne phb14
	jmp dalunl
phb14
	jmp phbget
;
dialts
	lda #DIALTYPE_CURRENT
	sta dial_type
	lda #<txt_call
	ldy #>txt_call
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
	lda #CR
	sta numbuf-20,x
	lda numbuf
	cmp #CR
	bne dialc3
	lda #CONSTAT_BUSY_NOCARRIER
	sta connection_status
	jmp dalfin
dialc3;to be deleted - routine to use baud rate and c/g from phonebook entry
	lda #0
	sta unlisted
	jmp dial
;
dalfin
	lda #0
	sta unlisted
	lda connection_status
	cmp #CONSTAT_CONNECT
	bne dalf2    ;connected
	lda #<txt_connect
	ldy #>txt_connect
dalnv
	jsr prtstt
	lda #$100-32
	sta JIFFIES
:	lda JIFFIES
	bne :-
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
	jmp term_entry
dalf2
	cmp #2      ;aborted
	bne dalf3
	jmp dalfab
dalf3
	cmp #0
	bne dalf4
	lda dial_type  ;no connect
	cmp #DIALTYPE_SELECTED
	bcs dalslc
	lda numbuf
	cmp #CR
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
	lda #'0'
	sta trycnt
	sta trycnt+1
	lda #<txt_dial_selected
	ldy #>txt_dial_selected
	jsr prtstt
dalsl0
	lda #DIALTYPE_SELECTED
	sta dial_type
	lda curpik
	sta tmppik
	lda entcol
	sta colbbs
	jsr hilcur
	lda trycnt+1
	cmp #'0'
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
	.byte CSR_UP,CR," "
tcol28e	.byte CYAN
	.byte "pORT: "
	.byte 05,0
prtunl
	.byte CSR_UP,CR," "
tcol28f	.byte CYAN
	.byte "dIAL: "
	.byte 05,0
unlisted
	.byte 0
unltemp	.byte 0
dalunl
	lda #DIALTYPE_UNLISTED
	sta dial_type
	lda entcol
	sta colbbs
	jsr hilcur
	lda #<txt_dial_unlisted
	ldy #>txt_dial_unlisted
	jsr prtstt
	lda ascii_mode
	beq dalun1
	lda #$80
dalun1
	jsr shocr3
	lda #<clrlnt
	ldy #>clrlnt
	jsr outstr
	lda #<txt_unlisted
	ldy #>txt_unlisted
	jsr outstr
	ldy #80
	lda #$20
dalun2	sta 1951,y;$079f
	dey
	bpl dalun2
	lda #7
	sta COLUMN
	ldy #0
	ldx #32
	jsr input
	bne dalun3
	jmp dlabrt
dalun3
	ldx #0
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
	sta COLUMN
	ldy #0
	ldx #5
	jsr input
	bne dalun8
	jmp dlabrt
dalun8
	ldx #0
	ldy unltemp
dalun4	lda inpbuf,x
	sta numbuf,y
	inx
	iny
	lda inpbuf,x
	bne dalun4
	lda #CR
	sta numbuf,y
	iny
	lda #0
	sta numbuf,y
	ldy #0
	lda #<prtunl
	ldy #>prtunl
	jsr outstr
	lda #<numbuf
	ldy #>numbuf
	jsr outstr
	lda #$91
	jsr chrout
	lda #1
	sta unlisted
	jmp dial
;
txt_call:
	.byte "cALL cURRENT nUMBER...",0
txt_dial_selected:
	.byte "dIAL sELECTED nUMBERS...",0
txt_dial_unlisted:
	.byte "dIAL uNLISTED nUMBER.",0
txt_unlisted:
	.byte "uNLISTED.",CR,0

	.byte "wAITING fOR cARRIER...",0	; [XXX unused]

txt_dialing:
	.byte "dIALING...  ",cp,"RESS ",cs,t,o,cp," TO ABORT.",0

numptr:
	.byte 0

; 2-digit ASCII retry counter
trycnt:
	.byte 0,0
	.byte 0

dial_type:
	.byte 0
DIALTYPE_CURRENT	= 0
DIALTYPE_UNLISTED	= 1
DIALTYPE_SELECTED	= 2

; status after call
connection_status:
	.byte 0
CONSTAT_BUSY_NOCARRIER	= 0
CONSTAT_CONNECT		= 1
CONSTAT_USERABORT	= 2
CONSTAT_UNKNOWN		= 3

;main body of dialer
dial
adnum
	lda #CR
	jsr chrout
await0
	lda unlisted	; unlisted gets a pass on the empty entry check
	bne await01
	ldy #2;empty entry? don't dial!
	lda (nlocat),y
	bne await01
	jmp dlabrt
await01
	lda #$100-106	; 1.75 sec delay
	sta JIFFIES
await1
	jsr getin	; check r/s
	cmp #$03
	bne awaitl
	jmp dlabrt
awaitl
	lda JIFFIES
	bne await1
adbegn
	lda #$100-2*60	; 2 sec delay
	sta JIFFIES	; for dial tone
:	lda JIFFIES
	bne :-
	inc trycnt+1
	lda trycnt+1
	cmp #'9'+1
	bcc dialnoinc
	inc trycnt
	lda trycnt
	cmp #'9'+1
	jeq dlabrt
	lda #'0'
	sta trycnt+1
dialnoinc
	jsr shocr3
dialin
	ldy #31
	lda #1
dlwhtl	sta $d800+23*40+7,y
	dey
	bpl dlwhtl
dlinit
	lda #<txt_dialing
	ldy #>txt_dialing
	jsr prtstt
; hayes dial
smrtdl
	jsr clear232
	jsr enablemodem
	ldx #LFN_MODEM
	jsr chkout
	lda #<txt_atv1
	ldy #>txt_atv1
	jsr outmod
	lda firmware_zimmers
	bne haydat
	lda #<txt_atd
	ldy #>txt_atd
	jmp haydatcont
haydat
	lda #<txt_atd_zimmers
	ldy #>txt_atd_zimmers
haydatcont
	jsr outstr
	ldx #0
hayda4	stx numptr
	ldx numptr
	lda #14
	sta $d800+23*40+7,x
	ldx numptr
	lda numbuf,x
	jsr chrout
	ldx numptr
	inx
	cmp #CR
	bne hayda4
	jsr clrchn
hayda6
	jmp haybus
haynan
	lda #<txt_no_carrier
	ldy #>txt_no_carrier
	jsr prtstt
	jmp haybk2
haybak
	lda #<txt_busy
	ldy #>txt_busy
	jsr prtstt
haybk2
	lda #$100-56
	sta JIFFIES
:	lda JIFFIES
	bne :-
	jsr haydel
	jmp redial
haycon
	jsr haydel
	lda #CONSTAT_CONNECT
	sta connection_status
	jmp dalfin
haydel
	lda #$100-24
	sta JIFFIES
	ldx #LFN_MODEM
	jsr chkin
haydll	jsr getin
	cmp #CR
	beq haydlo
	lda JIFFIES
	bne haydll
haydlo
	jsr clrchn
	rts
dlabrt
	lda #$100-48
	sta JIFFIES	; short delay
:	lda JIFFIES
	bne :-		; back to phbook
dgobak
	lda #CONSTAT_USERABORT
	sta connection_status
	jmp dalfin

redial
	lda #$100-128	; 2 second delay
	sta JIFFIES
:	lda JIFFIES	; before restart
	bne :-
rgobak
	lda #CONSTAT_BUSY_NOCARRIER
	sta connection_status     ;set redial flag
	jmp dalfin     ;back to phbook
outmod
	jsr outstr
outmo1	lda #$100-32
	sta JIFFIES
:	lda JIFFIES
	bne :-
	rts

	.byte 0		; [XXX unused]

txt_atd:
	.byte "ATDT",0
txt_atd_zimmers:
	; prepends address with a quote; zimmers firmware needs this
	.byte "ATD",34,0

	.byte "ATH",CR,0; [XXX unused]
	.byte "+++",0	; [XXX unused]

txt_atv1:
	.byte "ATV1",CR,0

txt_busy:
	.byte "bUSY",0

txt_no_carrier:
	.byte "nO cARRIER",0

txt_connect:
	.byte "cONNECT!",0

	.byte 0		; [XXX unused]

