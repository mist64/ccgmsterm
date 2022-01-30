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










cosave
	ldx textcl
	stx $04
cochng
	ldx #tcolor
	stx textcl
	rts
coback
	ldx $04
	stx textcl
	rts
f6	;directory
	lda #$01
	ldx #<dirfn
	ldy #>dirfn
dodir
	jsr setnam
	jsr dir
	jsr enablexfer
	jmp main
f8	;term toggle
	ldx 653
	cpx #2
	bne termtg
	jmp cf7
termtg
	lda grasfl
	eor #$01
	sta grasfl
	jsr bell
	jmp term
crsrtg	;ascii crsr toggle
	jsr curoff
	lda cursfl
	eor #$01
	sta cursfl
	jmp main

hangup	;hang up phone
	ldx 653
	cpx #2
	bne hangup6;not C= Stop
	jsr curoff
	lda #<dsctxt
	ldy #>dsctxt
	jsr outstr
	lda motype
	beq droprs
	cmp #$01
	beq dropup
	jmp dropswift
hangup6	jmp main

droprs	lda #%00000100
	sta $dd03
	lda #0
	sta $dd01
	ldx #226
		stx $a2
:	bit $a2
		bmi :-
	lda #4
	sta $dd01
	jmp main

dropup	lda #$04
	sta $dd03    ;cia2: data direction register b
	lda #$02
	sta $dd01    ;cia2: data port register b
	ldx #$e2
		stx $a2
a7ef3	bit $a2
	bmi a7ef3
	lda #$02
	sta $dd03    ;cia2: data direction register b
	jmp main
dropswift
	jsr dropdtr
	jmp main








dsktxt	.byte 5,13
	.byte "#"
dsktx2	.byte "**>      "
	.byte 157,157,157,157,157,157,00
dskdtx	.byte '8 9 101112131415161718192021222324252627282930'
f5	;disk command
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

;xfer id and pw to macros F5 and F7
xferidpw
	ldy #59
xferid
	lda (nlocat),y
	sta macmem+69,y
	iny
	lda (nlocat),y
	beq xferpw
	jmp xferid
xferpw
	sta macmem+69,y
	ldy #71
xferpw2
	lda (nlocat),y
	sta macmem+121,y
	iny
	lda (nlocat),y
	beq xferp3
	jmp xferpw2
xferp3
	sta macmem+121,y
	rts











;MACROS
macmdm	.byte 0
macxrg	.byte 0
prmacx	;find index for macro
	cpx #3     ;from 197 f-key value
	bne prmax2
	ldx #7
prmax2	txa
	sec
	sbc #4     ;now a=0..3 for f1,3,5,7
	ldx #5
prmax3	asl a
	dex
	bpl prmax3  ;a=0,64,128,192
	sta macxrg
	rts
prtmac
	lda 197
	cmp #7
	bcc prtmac
	jsr prmacx
prtmc0
	ldx macxrg
	lda macmem,x
	beq prtmc4
	pha
	ldx macmdm
	bne prtmc2
	ldx #5
	jsr chkout
	pla
	pha
	ldx grasfl
	beq prtmc1
	jsr catosa
prtmc1
	jsr chrout
	jsr clrchn
	lda #$fd
	sta $a2
prtmcd	lda $a2
	bne prtmcd
	lda #$fd
	sta $a2
prtmcd2	lda $a2
	bne prtmcd2
	ldx #5
	jsr chkin
	jsr getin
	cmp #$00
	bne prtmci
	ldx duplex
	beq prtmca
	ldx grasfl
	beq prtmc2
	pla
	jsr catosa
	bne prtmck
	beq prtmc3
prtmca	pla
	bne prtmc3
prtmci	tax
	pla
	txa
prtmck	ldx grasfl
	beq prtmcj
	jsr satoca
prtmcj
	pha
prtmc2
	jsr curoff
	pla
	ldx macmdm
	bne prtmcs
	jsr putbuf
prtmcs
	jsr ctrlck
	bcs prtmc3
	jsr chrout
	jsr qimoff
	jsr curprt
prtmc3	inc macxrg
	cmp #255
	bne prtmc0
prtmc4	jmp curoff











	.include "buffer2.s"
	.include "xmodem.s"
	.include "xfer.s"
	.include "disk.s"
	.include "multixfer.s"
	.include "buffer.s"
	.include "phonebook.s"
	.include "hayes.s"

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
