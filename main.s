noload
begin
	jsr enablemodem
	jsr bell
	jsr themeroutine
term
	jsr mssg       ;title screen/CCGMS!
	jsr instr		;display commands f1 etc to terminal ready
main
	lda supercpubyte;supercpu
	beq main5
	cmp #$02;already acknowleged . no need to send text to screen
	beq main5a
	lda #<supertext
	ldy #>supertext
	jsr outstr
	lda #$02
	sta supercpubyte
main5a;supercpu = turn on 20mhz mode - for after all file transfer situations. already on? turn on again. no biggie. save code.
	jsr turnonscpu
main5
	lda bustemp
	beq mainmoveon
	ldy #1
mainprint
	lda tempbuf,y
	jsr chrout
	iny
	cpy bustemp
	bne mainprint
	ldy #0
	sty bustemp
mainmoveon
	ldx #$ff
	txs
	lda #$48		;keyboard matrix routine
	sta 655
	lda #$eb
	sta 656
	jsr clrchn;$ffcc
	jsr curprt		;cursor placement
main2
	lda bufptr
	sta newbuf
	lda bufptr+1
	sta newbuf+1
	jsr clrchn
	jsr getin		;kernal get input
	cmp #$00
	bne specck
mainab
	jmp main3
;check special-keys here
specck
	cmp #6
	bne specc1
	ldx 653
	cpx #6
	bne specc1
	ldx #16
	stx datdir
	ldx #0
	stx modreg;datdir and modreg need to be here for user port modem to function
	jmp main2
specc1
;cmp #$a4;underline key
;bne chkscr
;ldx 653     ;shift _ toggles
;beq checkf  ;n/d cursor
;cpx #1
;beq spetog
;lda allcap
;eor #$01
;sta allcap
;jmp main2
spetog
;jmp crsrtg
chkscr
	ldx 653
	cpx #$05    ;shift-ctrl and 1-4
	bcc chekrs  ;toggle screen
	ldx #$03
chksc1
	cmp clcode,x ;table of color codes
	beq chksc2
	dex
	bpl chksc1
	jmp main3   ;(not in range)
chksc2
	jmp scrtog  ;x holds pos 0-3
chekrs
	cmp #131    ;shift-r/s
	bne checkf  ;to hang-up
	jmp hangup
checkf	;f-keys
	cmp #133
	bcc notfky
	cmp #141
	bcs notfky
	ldx #0
	stx $d020
	stx $d021
	pha
	jsr curoff
	pla
	sec
	sbc #133
	sta $03
	asl $03
	clc
	adc $03
	sta fbranc+1
	clc
fbranc
	bcc fbranc+2
	jmp f1
	jmp f3
	jmp f5
	jmp f7
	jmp f2
	jmp f4
	jmp f6
	jmp f8
notfky
;ldx allcap
;beq upplow
;ldx 53272
;cpx #23
;bne upplow
;cmp #$41
;bcc upplow
;cmp #$5b  ;'z'+1
;bcs upplow
;ora #$80
upplow	;ascii/gfx check
	sta $03
	ldx grasfl
	beq mainop
	jsr catosa  ;convert to ascii
	bne mainop
mnback
	jmp main2
mainop	;main output?
	pha
	ldx #lognum
	jsr chkout
	pla
	jsr chrout
	ldx grasfl
	beq maing
	jsr satoca
	sta $03
	bne maing
	jmp main2
maing
	ldx duplex
	beq main3
	jsr clrchn  ;if half duplex
	lda $03     ;bring back char
	ldx grasfl
	beq mainb
	cmp #$a4;underline key
	bne mainb
	lda #164    ;echo underline for
	sta $03     ;_ in ascii/half dup
mainb
	jmp bufchk  ;skip modem input
main3
	jsr clrchn
	ldx 653
	cpx #4     ;ctrl pressed
	bne specc2
	ldx 197    ;fn key
	cpx #3
	bcc specc2
	cpx #7
	bcs specc2
	lda #0
	sta macmdm
	jsr prtmac
	jmp main5;instead of main;supercpu doesnt need to be turned on and called every frame.
specc2
	cpx #3     ;shift,c=
	bne specc3
	ldx 657
	bpl specc3
	ldx #23
	stx 53272
specc3
	ldx #lognum
	jsr chkin  ;get the byte from the modem
	jsr getin
	cmp #$00
	beq mnback
	ldx status
	bne mnback
	pha
	jsr clrchn
	pla
nopass
	ldx grasfl
	beq main4
	jsr satoca   ;ascii to c=
	beq main3
main4
	cmp #20      ;delete from modem
	bne bufchk   ;becomes false del
	lda #$14   ; delete key working :)
bufchk
	jsr putbuf
	jmp contn
putbuf
	ldx buffoc
	beq buffot
	ldx bufptr
	cpx bufend
	bne bufok
	ldx bufptr+1
	cpx bufend+1
	beq buffot
bufok
	ldy bufreu
	beq bufok2
	jsr reuwrite
	jmp bufok3
bufok2
	ldy #$00
	sta (bufptr),y
bufok3
	inc bufptr
	bne buffot
	inc bufptr+1
buffot	rts
contn
	jsr ctrlck
	bcc contn2
	jmp main
ctrlck
	cmp #$0a   ;ctrl-j
	beq swcrsr
	cmp #$0b   ;ctrl-k
	bne nonchk
swcrsr
	ldx grasfl
	bne nonchk
	pha
	jsr curoff
	pla
	and #$01   ;form to ch flag
	eor #$01
	sta cursfl
swcext
	sec
	rts
nonchk
	cmp #14    ;ctrl-n
	bne ctrlen
	ldx #0
	stx $d020
	stx $d021
ctrlen
	cmp #$07   ;ctrl-g;bell sound from bbs side
	bne ctrleo
	jsr bell
ctrleo
	cmp #22    ;ctrl-v;end of file transfer or boomy sound
	bne ctrlev
	jsr gong
ctrlev
; cmp #$15   ;ctrl-u;uppercase from bbs side
; bne ctrle2
; ldx #21
; stx 53272
; bne ctrlex
;ctrle2
; cmp #$0c   ;ctrl-l;lowercase from bbs side
; bne ctrle3
; ldx #23
; stx 53272
; bne ctrlex
;ctrle3
; cmp #$5f   ;false del
; bne ctrle4 ;(buff and 1/2 duplx)
; lda #20
; bne ctrlex
;ctrle4
	ldx lastch
	cpx #2     ;ctrl-b
	bne ctrlex
	ldx #15
ctrlb1	cmp clcode,x
	beq ctrlb2
	dex
	bpl ctrlb1
	bmi ctrlex
ctrlb2	stx $d020
	stx $d021
	lda #16    ;ctrl-p..non printable
ctrlex
	sta lastch
	clc
	rts
contn2
	pha
	jsr curoff  ;get rid of cursor
	pla
	jsr chrout
	jsr qimoff
	jmp main
;end of term
;subroutines follow:
bell
	ldx #$09
	stx 54291
	ldx #00
	stx 54292
	ldx #$40
	stx 54287
	ldx #00
	stx 54290
	ldx #$11
	stx 54290
	rts
gongm1	.byte 24,6,13,20,4,11,18,15,8,1,5,19,12,14,7,0,4,11,18,24
gongm2	.byte 47,0,0,0,0,0,0,4,8,16,13,13,11,28,48,68,21,21,21,15
gong
	pha
	ldx #0
gong1
	lda gongm1,x
	tay
	lda gongm2,x
	sta 54272,y
	inx
	cpx #20
	bcc gong1
	pla
	rts
scrtog	;toggle screen #1-4
	txa        ;(swap screen memory with
	pha        ; behind kernal rom)
	jsr curoff
	lda 653
	sta $04
	pla
	asl a
	asl a
	asl a
	clc
	adc #$e0
	sta locat+1
	lda #$04
	sta $03
	lda #$00
	sta locat
	sta $02
	sei
	lda $d011
	pha
	lda #$0b
	sta $d011
	lda #<ramnmi
	sta $fffa
	lda #>ramnmi
	sta $fffb
	lda #$2f
	sta $00
	lda #$35
	sta $01
scrtg1
	jsr scrnl1
	cmp #$08
	bcc scrtg1
	lda #$d8
	sta $03
scrtg2
	jsr scrnl1
	cmp #$dc
	bcc scrtg2
	pla
	sta $d011
	lda #$37
	sta $01
	cli
	jmp main
ramnmi
	sta tempch
	lda #$37
	sta $01
	plp
	php
	sta tempcl
	lda #>ramnm2
	pha
	lda #<ramnm2
	pha
	lda tempcl
	pha
	lda tempch
	jmp $fe43
ramnm2
	pha
	lda #$35
	sta $01
	pla
	rti
scrnl1
	ldx $04
	cpx #05
	beq scrnls
	ldy #0
scrnlc	lda ($02),y
	sta (locat),y
	dey
	bne scrnlc
	beq scrnl3
scrnls	ldy #$00
scrnl2	;swap screen page
	lda ($02),y
	tax
	lda (locat),y
	sta ($02),y
	txa
	sta (locat),y
	iny
	bne scrnl2
scrnl3	lda #<ramnmi
	sta $fffa
	lda #>ramnmi
	sta $fffb
	inc locat+1
	inc $03
	lda $03
	rts
outspc
	lda #29    ;crsr right
outsp1
	jsr chrout
	dex
	bne outsp1
	rts
bufclr
	lda buffst
	sta bufptr
	lda buffst+1
	sta bufptr+1
	rts
finpos	;calculate screenpos
	ldy line
	lda $ecf0,y
	sta locat
	lda $d9,y
	and #$7f
	sta locat+1
	lda column
	cmp #40
	bcc finp2
	sbc #40
	clc
finp2
	adc locat
	sta locat
	lda locat+1
	adc #$00
	sta locat+1
	ldy #$00
	lda (locat),y
	rts
fincol	;calculate color ptr
	jsr finpos
	lda #$d4
	clc
	adc locat+1
	sta locat+1
	lda (locat),y
	rts
qimoff	;turn quote/insert off
	lda #$00
	sta qmode
	sta imode
	rts
mssg
	lda #<msgtxt
	ldy #>msgtxt
	jsr outstr
	lda #32
	jsr chrout
	ldx #02    ;2nd line start char
;lda #163
mslop1
	jsr chrout
	dex
	bne mslop1
	lda #<author
	ldy #>author
	jsr outstr
	ldx #40
mslop2
	lda #183
	jsr chrout
	dex
	bne mslop2
	rts
instr
	lda #<instxt
	ldy #>instxt
	jsr outstr
	lda #<instx2
	ldy #>instx2
	jsr outstr
trmtyp
	ldx grasfl
	bne asctrm
	lda theme
	bne trmtyp2
	lda #<gfxtxt
	ldy #>gfxtxt
	bne termtp
trmtyp2
	lda #<gfxtxt2
	ldy #>gfxtxt2
	bne termtp
asctrm
	lda #<asctxt
	ldy #>asctxt
termtp
	jsr outstr
	lda theme
	bne ready2
	lda #<rdytxt
	ldy #>rdytxt
	jmp outstr
ready2
	lda #<rdytxt2
	ldy #>rdytxt2
	jmp outstr
msgtxt
	.byte 13,$93,8,5,14,18,32,28,32
	.byte "c"
	.byte 32,129,32
	.byte "c"
	.byte 32,158,32
	.byte "g"
	.byte 32,30,32
	.byte "m"
	.byte 32,31,32
	.byte "s"
	.byte 32,156
	.byte " ! "
	.byte 5,32
	.byte "    tERMINAL 2021   "
	.byte 00
author	.byte "BY cRAIG sMITH       mODS BY aLWYZ   "
	.byte 146,151,00
;
instxt
	.byte 5,'  ',18,'f1',146,32,150,'uPLOAD          '
	.byte 5,18,'f2',146,32,150,'sEND/rEAD FILE',13
	.byte 5,'  ',18,'f3',146,32,158,'dOWNLOAD        '
	.byte 5,18,'f4',146,32,158,'bUFFER COMMANDS',13
	.byte 5,'  ',18,'f5',146,32,153,'dISK COMMAND    '
	.byte 5,18,'f6',146,32,153,'dIRECTORY',13
	.byte 5,'  ',18,'f7',146,32,30,'dIALER/pARAMS   '
	.byte 5,18,'f8',146,32,30,'sWITCH TERMS',13,0
instx2
	.byte 31,'c',28,'=',5,18,'f1',146,32,159,'mULTI-sEND    '
	.byte 31,'c',28,'=',5,18,'f3',146,32,159,'mULTI-rECEIVE',13
	.byte 31,'c',28,'=',5,18,'f5',146,32,154,'sEND DIR.     '
	.byte 31,'c',28,'=',5,18,'f7',146,32,154,'sCREEN TO bUFF.',13,13,0
;
mlswrn	.byte 13,5,'bUFFER TOO BIG - sAVE OR cLEAR fIRST!',13,0
;


	.include "dir.s"
	.include "ansi.s"
	.include "input.s"
	.include "misc.s"
	.include "disk2.s"
	.include "macro2.s"
	.include "buffer2.s"
	.include "xmodem.s"
	.include "xfer.s"
	.include "disk.s"
	.include "multixfer.s"
	.include "buffer.s"
	.include "phonebook.s"
	.include "hayes.s"
	.include "config2.s"



decoen
viewmg
	lda #<ampag1
	ldy #>ampag1
	jsr outstr
	lda #0
	sta 198
viewm1
	lda 198
	beq viewm1
	lda #<ampag2
	ldy #>ampag2
	jsr outstr
	lda #0
	sta 198
viewm2
	lda 198
	beq viewm2
	rts
