; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Phone Book
;

entcol	.byte WHITE
hilcol	.byte YELLOW

SET_PETSCII
txt_phonebook_menu:
	.byte HOME,CR
	.byte WHITE,RVSON,$a1	; $A1: LEFT HALF BLOCK ('▌')
	.byte "CRSR Keys"
	.byte $b6,RVSOFF,LTBLUE	; $B6: RIGHT THREE EIGHTHS BLOCK
	.byte " - Move"
	.byte WHITE,RVSON,$a1
	.byte "Return"
	.byte $b6,RVSOFF,LTBLUE
	.byte " - Select"
	.byte CR
	.byte CYAN,HILITE
	.byte "dial Unlisted #  "
	.byte HILITE
	.byte "edit Current #"
	.byte CR
	.byte HILITE
	.byte "call Current #   "
	.byte HILITE
	.byte "a-Dial Selected"
	.byte CR,HILITE
	.byte "reverse Call     "
	.byte HILITE
	.byte "x-Return To Menu"
	.byte CR
	.byte GRAY,SETCSR,5,0,RVSON
	.byte "           >>>Phone Book<<<           "
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
	.byte "Name:"
	.byte CR
	.byte "   IP:"
	.byte CR,' '
	.byte "Port: "
	.res 5,CSR_RIGHT
	.byte " ID: "
	.res 11,CSR_RIGHT
	.byte " Try: "
	.res 4,CSR_RIGHT
	.byte DEL,CSR_UP,CR,0
curbt3	.byte SETCSR,22,1
tcol28b	.byte CYAN
	.byte "Name:"
	.byte CR
	.byte " Dial:"
	.byte CR,' '
	.byte "      "
	.res 5,CSR_RIGHT
	.byte "     "
	.res 11,CSR_RIGHT
	.byte " Try: "
	.res 4,CSR_RIGHT
	.byte DEL,CSR_UP,CR,0
curbt2:
tcol28c	.byte CYAN
	.byte " PW:             ",0

curbt4:
tcol28d	.byte CYAN
	.byte " ID: ",0
nontxt	.byte WHITE
	.byte "(None)             "
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
SET_ASCII

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
	jmp phonebook_init; [XXX remove]

;----------------------------------------------------------------------
phonebook_init:
	lda #'0'
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
:	lda #CSR_RIGHT
	jsr chrout
	jsr phnptr
	jsr prtent
	inc curpik
	lda curpik
	cmp #15
	bcc :-
	lda #<toetxt
	ldy #>toetxt
	jsr outstr
:	lda #21
	sta COLUMN
	jsr phnptr
	jsr prtent
	inc curpik
	lda curpik
	cmp #30
	bcc :-
	lda #<stattx
	ldy #>stattx
	jsr outstr
	lda #0
	sta curpik
	lda #<curbtx
	ldy #>curbtx
	jsr outstr	; [XXX jmp]
	rts

;----------------------------------------------------------------------
phnroc:
	.byte SETCSR,0,0,0
arrowt:
	.byte 32,93,93,32,60,125,109,62,32,32,0

;----------------------------------------------------------------------
hilcur:
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

shocr3:
;	lda unlisted
;	bne shotty
shobau	; start display of bottom line
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
dalun2p	sta $0400+24*40+12,y
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

;----------------------------------------------------------------------
; [XXX this function and its data is unused!]
tmpopt:
	.byte 0
tmpmax:
	.byte 0
	.byte 0
newsel:
	jsr getin
	cmp #'+'
	bne @2
	inc tmpopt
	lda tmpopt
	cmp tmpmax
	bcc @1
	lda #0
	sta tmpmax
@1:	sec
	rts
@2:	cmp #'-'
	bne @3
	dec tmpopt
	bpl @1
	ldx tmpmax
	dex
	stx tmpopt
	sec
	rts
@3:	cmp #CR
	bne newsel
	clc
	rts

;----------------------------------------------------------------------
phonebook:
	lda #CLR
	jsr chrout
	jsr phonebook_init

phonebook_loop:
	lda #'0'
	sta trycnt
	sta trycnt+1
	lda hilcol
	sta colbbs
	jsr hilcur
	jsr shocur

phbget:
	jsr getin
	cmp #0
	beq phbget

	cmp #CSR_LEFT
	bne @2

; LEFT
	lda curpik
	sbc #15
	bcs set_current_entry
	adc #30
	jmp set_current_entry
@2:

	cmp #CSR_RIGHT
	bne @3

; RIGHT
	lda curpik
	clc
	adc #15
	cmp #30
	bcc set_current_entry
	sbc #30
	jmp set_current_entry
@3:

; UP
	cmp #CSR_UP
	bne @4

	lda curpik
	sbc #1
	bcs set_current_entry
	adc #30
	jmp set_current_entry
@4:

	cmp #CSR_DOWN
	bne phb5

; DOWN
	lda curpik
	clc
	adc #1
	cmp #30
	bcc set_current_entry
	sbc #30
set_current_entry:
	pha
	lda entcol
	sta colbbs
	jsr hilcur
	pla
	sta curpik
	jmp phonebook_loop

phb5:
	cmp #HOME
	bne @6

; HOME
	lda #0
	beq set_current_entry; always
@6:

	cmp #CLR
	bne @7

; CLR
	jsr clrent
	jsr phonebook_init
	jmp phonebook_loop
@7:

	and #$7f
	cmp #'X'	; return to menu
	jeq handle_f7_config

	cmp #' '
	beq :+
	cmp #CR
	bne @9

; select
:	ldy #2
	lda (nlocat),y
	jeq phbget
	ldy #0
	lda (nlocat),y
	eor #1
	sta (nlocat),y
	jmp phonebook_loop
@9:

	cmp #'R'
	bne @10

; reverse call
	jsr xorall
	jsr phonebook_init
	jmp phonebook_loop
@10:

	cmp #'E'
	bne @11

; edit current #
	jsr newent
	jmp phonebook_loop
@11:

	cmp #'C'	; call current #
	jeq call_current
	cmp #'A'	; dial selected
	jeq dial_selected
	cmp #'D'	; dial unlisted #
	jeq dial_unlisted
	jmp phbget

call_current:
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

;----------------------------------------------------------------------
dalfin:
	lda #0
	sta unlisted
	lda connection_status
	cmp #CONSTAT_CONNECT
	bne @dalf2	; connected
	lda #<txt_connect
	ldy #>txt_connect
	jsr prtstt
	lda #$100-32
	sta JIFFIES
:	lda JIFFIES
	bne :-
	lda #$0f
	sta $d418
;	lda trycnt	; this was just to be cute but not neccessary anymore
;	cmp #4
;	bcc @dalfc1
;	jsr gong
;	jmp @dalfc2
;@dalfc1:
	jsr bell
;@dalfc2:
	jmp term_entry
@dalf2:

	cmp #CONSTAT_USERABORT
	jeq dalfab

	cmp #CONSTAT_BUSY_NOCARRIER
	bne dalf4

	lda dial_type	; no connect
	cmp #DIALTYPE_SELECTED
	bcs :+
	lda numbuf
	cmp #CR
	jeq hayes_userabort
	jmp dial	; redial for curr/unl
:	lda #<stattx
	ldy #>stattx
	jsr outstr
	jmp dalsl0

dial_selected:
	lda #'0'
	sta trycnt
	sta trycnt+1
	lda #<txt_dial_selected
	ldy #>txt_dial_selected
	jsr prtstt
dalsl0:
	lda #DIALTYPE_SELECTED
	sta dial_type
	lda curpik
	sta tmppik
	lda entcol
	sta colbbs
	jsr hilcur
	lda trycnt+1
	cmp #'0'
	beq @3
@1:	inc curpik
	lda curpik
	cmp #30
	bcc :+
	lda #0
	sta curpik
:	cmp tmppik
	bne @3
	jmp hayes_userabort
@3:	jsr phnptr
	ldy #0
	lda (nlocat),y
	beq @1
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
	jmp phonebook_loop

;----------------------------------------------------------------------
SET_PETSCII
curunl
	.byte CSR_UP,CR," "
tcol28e	.byte CYAN
	.byte "Port: "
	.byte WHITE,0
prtunl
	.byte CSR_UP,CR," "
tcol28f	.byte CYAN
	.byte "Dial: "
	.byte WHITE,0
SET_ASCII

;----------------------------------------------------------------------
unlisted:
	.byte 0
unltemp:
	.byte 0

;----------------------------------------------------------------------
dial_unlisted:
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
dalun2	sta $0400+23*40+7,y
	dey
	bpl dalun2
	lda #7
	sta COLUMN
	ldy #0
	ldx #32
	jsr input
	bne dalun3
	jmp hayes_userabort
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
dalun9	sta $0400+23*40+7,y
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
	jmp hayes_userabort
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

SET_PETSCII
txt_call:
	.byte "Call Current Number...",0
txt_dial_selected:
	.byte "Dial Selected Numbers...",0
txt_dial_unlisted:
	.byte "Dial Unlisted Number.",0
txt_unlisted:
	.byte "Unlisted.",CR,0

	.byte "Waiting For Carrier...",0	; [XXX unused]

txt_dialing:
	.byte "Dialing...  Press STOP to abort.",0
SET_ASCII

;----------------------------------------------------------------------
numptr:
	.byte 0

; 2-digit ASCII retry counter
trycnt:
	.byte 0,0
	.byte 0	; terminator

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

;----------------------------------------------------------------------
; main body of dialer
dial:
	lda #CR
	jsr chrout
	lda unlisted	; unlisted gets a pass on the empty entry check
	bne :+
	ldy #2		; empty entry? don't dial!
	lda (nlocat),y
	jeq hayes_userabort
:
	lda #$100-106	; 1.75 sec delay
	sta JIFFIES
@wloop:	jsr getin
	cmp #3		; STOP
	jeq hayes_userabort
	lda JIFFIES
	bne @wloop

	lda #$100-2*60	; 2 sec delay
	sta JIFFIES	; for dial tone
:	lda JIFFIES
	bne :-
	inc trycnt+1
	lda trycnt+1
	cmp #'9'+1
	bcc :+
	inc trycnt
	lda trycnt
	cmp #'9'+1
	jeq hayes_userabort
	lda #'0'
	sta trycnt+1
:	jsr shocr3
	ldy #31
	lda #1
:	sta $d800+23*40+7,y
	dey
	bpl :-

	lda #<txt_dialing
	ldy #>txt_dialing
	jsr prtstt

;----------------------------------------------------------------------
; hayes dial
	jsr clear232
	jsr enablemodem
	lda #<txt_atv1	; send word result codes (as opposed to numeric)
	ldy #>txt_atv1
	jsr strmod_delay
	lda firmware_zimmers
	bne @1
	lda #<txt_atd
	ldy #>txt_atd
	jmp @2
@1:	lda #<txt_atd_zimmers
	ldy #>txt_atd_zimmers
@2:	jsr strmod
	ldx #0
@loop:	stx numptr
	ldx numptr
	lda #14
	sta $d800+23*40+7,x
	ldx numptr
	lda numbuf,x
	jsr modput
	ldx numptr
	inx
	cmp #CR		; CR-terminated
	bne @loop
	jmp parse_hayes_answer

;----------------------------------------------------------------------
hayes_no_carrier:
	lda #<txt_no_carrier
	ldy #>txt_no_carrier
	jsr prtstt
	jmp haybk2

;----------------------------------------------------------------------
hayes_busy:
	lda #<txt_busy
	ldy #>txt_busy
	jsr prtstt
haybk2
	lda #$100-56
	sta JIFFIES
:	lda JIFFIES
	bne :-
	jsr flush_modem
	jmp hayes_redial

;----------------------------------------------------------------------
hayes_connected:
	jsr flush_modem
	lda #CONSTAT_CONNECT
	sta connection_status
	jmp dalfin

;----------------------------------------------------------------------
; eat all modem bytes until CR (with timeout)
flush_modem:
	lda #$100-24
	sta JIFFIES
:	jsr modget
	cmp #CR
	beq :+
	lda JIFFIES
	bne :-
:	rts

;----------------------------------------------------------------------
hayes_userabort:
	lda #$100-48
	sta JIFFIES	; short delay
:	lda JIFFIES
	bne :-		; back to phonebook
	lda #CONSTAT_USERABORT
	sta connection_status
	jmp dalfin

;----------------------------------------------------------------------
hayes_redial:
	lda #$100-128	; 2 second delay
	sta JIFFIES
:	lda JIFFIES	; before restart
	bne :-
	lda #CONSTAT_BUSY_NOCARRIER
	sta connection_status; set redial flag
	jmp dalfin	; back to phonebook

;----------------------------------------------------------------------
; send string to modem
strmod:
	sty zpoutstr+1
	sta zpoutstr
	ldy #0
@loop:	lda (zpoutstr),y
	beq @rts
	jsr modput
	iny
	bne @loop
@rts:	rts

;----------------------------------------------------------------------
strmod_delay:
	jsr strmod
	lda #$100-32
	sta JIFFIES
:	lda JIFFIES
	bne :-
	rts

;----------------------------------------------------------------------
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

SET_PETSCII
txt_busy:
	.byte "Busy",0

txt_no_carrier:
	.byte "No Carrier",0

txt_connect:
	.byte "Connect!",0
SET_ASCII

	.byte 0		; [XXX unused]

;----------------------------------------------------------------------
bustemp:
	.byte 0

; [XXX this is all very verbose]
;----------------------------------------------------------------------
parse_hayes_answer:
	ldy #0
	sty bustemp

	jsr hmodget
haybus3
	jsr buffer_input
	cpy #$ff
	jeq hayout	; get out of routine. send data to terminal, and set connect!
	jsr hmodget
	cmp #'b'
	bne haynocarr	; move to check for no carrier
	jsr buffer_input
	jsr hmodget
	cmp #'u'
	bne haybus3
	jsr buffer_input
	jsr hmodget
	cmp #'s'
	bne haybus3
	jsr buffer_input
	jsr hmodget
	cmp #'y'
	bne haybus3
	ldy #0
	sty bustemp
	jmp hayes_busy
;
haynocarr
	cmp #'n'
	bne haybusand	; move to next char
	jsr buffer_input
	jsr hmodget
	cmp #'o'
	bne haybus3
	jsr buffer_input
	jsr hmodget
	cmp #' '
	bne haybus3
	jsr buffer_input
	jsr hmodget
	cmp #'c'
	jne haynoanswer
	jsr buffer_input
	jsr hmodget
	cmp #'a'
	bne haybus3
	jsr buffer_input
	jsr hmodget
	cmp #'r'
	bne haybus3
	jsr buffer_input
	jsr hmodget
	cmp #'r'
	bne haybus3
	ldy #0
	sty bustemp
	jmp hayes_no_carrier
;
haybusand
	cmp #'B'
	bne haynocarrand; move to check for no carrier
	jsr buffer_input
	jsr hmodget
	cmp #'U'
	beq :+
haybus3b:
	jmp haybus3
:
	jsr buffer_input
	jsr hmodget
	cmp #'S'
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #'Y'
	bne haybus3b
	ldy #0
	sty bustemp
	jmp hayes_busy
;
haynocarrand
	cmp #'N'
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #'O'
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #' '
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #'C'
	bne haynoanswerand
	jsr buffer_input
	jsr hmodget
	cmp #'A'
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #'R'
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #'R'
	bne haybus3b
	ldy #0
	sty bustemp
	jmp hayes_no_carrier

haynoanswerand
	cmp #'A'
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #'N'
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #'S'
	bne haybus3b
	jsr buffer_input
	jsr hmodget
	cmp #'W'
	beq :+
haybus3c
	jmp haybus3
:
	ldy #0
	sty bustemp
	jmp hayes_no_carrier

haynoanswer
	cmp #'a'
	bne haybus3c
	jsr buffer_input
	jsr hmodget
	cmp #'n'
	bne haybus3c
	jsr buffer_input
	jsr hmodget
	cmp #'s'
	bne haybus3c
	jsr buffer_input
	jsr hmodget
	cmp #'w'
	bne haybus3c
	ldy #0
	sty bustemp
	jmp hayes_no_carrier

;
hayout
	sty bustemp
	jmp hayes_connected

;----------------------------------------------------------------------
; get modem byte with timeout
hmodget:
	inc waittemp	; timeout for no character loop
	ldx waittemp	; so it doesn't lock up
	cpx #144	; maybe change for various baud rates
	beq :+
	jsr modget
	beq hmodget
	bcs hmodget
:	ldx #0
	stx waittemp
	rts

;----------------------------------------------------------------------
; buffer character so it can be printed once we're in terminal mode again
buffer_input:
	ldy bustemp
	iny
	sty bustemp
	sta tempbuf,y
	rts

;----------------------------------------------------------------------
waittemp:
	.byte 0
