;
f7	;terminal params/dial
	jsr disablemodem
	lda #0
	sta $d020
	sta $d021
	lda #<f7mtxt   ;print f7 menu
	ldy #>f7mtxt
	jsr outstr
	lda efbyte
	beq f7noef
f7ef
	lda #<f7mtx3ef
	ldy #>f7mtx3ef
	jsr outstr
	jmp f7continue
f7noef
	lda #<f7mtx3noef
	ldy #>f7mtx3noef
	jsr outstr
f7continue
	lda #<f7mtxcont
	ldy #>f7mtxcont
	jsr outstr
	lda #<f7mtx2
	ldy #>f7mtx2
	jsr outstr
f7opts
	lda #$00
	sta $c6
	jsr f7parm
f7chos
	lda JIFFIES
	and #$0f
	bne f7chgk
	lda JIFFIES
	and #$10
	beq f7oprt
	lda #<prret
	ldy #>prret
	jsr outstr
	jmp f7chgk
f7oprt
	lda #<prret2
	ldy #>prret2
	jsr outstr
f7chgk
	jsr getin
	cmp #$00
	beq f7chos
f7chs0
	and #$7f
	cmp #$41   ;A-auto-dial opt
	bne f7chs1
	lda baudrt
	sta bautmp
	lda grasfl
	sta gratmp
	jmp phbook
f7chs1
	cmp #$42 	;B-Baud Rate
	bne f7chs2
;baud rate change
	ldy motype
	beq move24tp
	cpy #$01
	beq move96tp
	cpy #$03;check for swift df - we'll do the no reu check if selected
	bne brinc
	jsr noreu
	jmp brinc
move24tp
	lda baudrt
	cmp #$02
	bmi brinc
	jmp brrst
move96tp
	lda baudrt
	cmp #$04
	bmi brinc
	jmp brrst
brinc	inc baudrt
	lda baudrt
	cmp #$07
	bne mobaud
brrst
	lda #$00
	sta baudrt
mobaud
	jsr rsopen;5-16 add failsafe....
	jmp f7opts
f7chs2
	cmp #$44 	;D-Duplex
	bne f7chs5
;duplex change
	lda duplex
	eor #$01
	sta duplex
	jmp f7opts
f7chs5
	cmp #$46;F-Firmware
	bne f7chstheme
	lda mopo1
	eor #$01
	sta mopo1
	jmp f7opts
f7chstheme
	cmp #$54;theme
	bne f7chsconfig
	inc theme
	lda theme
	cmp #$06
	bne f7theme2
	lda #$00
	sta theme
f7theme2
	jsr themeroutine
	jmp f7opts
f7chsconfig;easyflash only
	cmp #$43 	;C-Config EF/Disk
	bne f7chs3
	lda efbyte;do we have an easyflash? no? then go on then and forget about this option
	beq f7chs3
	lda diskoref
	eor #$01
	sta diskoref
	jmp f7opts
f7chs3
	cmp #$4d	;M-modem type
	bne f7chsp
;change modem type
	inc motype
	lda motype
	pha
	lda efbyte
	beq modems5
	pla
	cmp #$02;only 2 modems in easyflash mode
	bcc incmod
	jmp modems6
modems5
	pla
	cmp #$05;max # of modems
	bcc incmod
modems6
	lda #$00
	sta motype
	lda #$02
	sta baudrt
incmod
	jsr rsopen
	jmp f7opts
f7chsp;x-modem crc fix
	cmp #$50	;P-Protocol
	bne f7chs6
	inc protoc
	lda protoc
	cmp #$03
	bcc f7chspmoveon
	lda #$00
	sta protoc
f7chspmoveon
	jmp f7opts
f7chs6
	cmp #$53;S-save
	bne f7chs7
	jsr svconf
	jmp f7
f7chs7
	cmp #$4c
	bne f7chs8
	jsr loconf
	jmp f7
f7chs8
	cmp #$45
	bne f7chs9
	jsr edtmac
	jmp f7
f7chs9
	cmp #$56
	bne f7chsa
	jsr viewmg
	jmp f7
f7chsa
	cmp #$0d
	beq f7chsb
f7gbkk	jmp f7chos
f7chsb
	lda nicktemp
	beq moveonterm
moveonterm
	jsr enablemodem
	jmp term

prmopt	.byte <op1txt,>op1txt,<op2txt,>op2txt,<op6txt,>op6txt,<op3txt,>op3txt,<op4txt,>op4txt,<op5txt,>op5txt
prmlen	.byte 4,18,8,10,20,19
op1txt	.byte "fULLhALF"
op2txt	.byte 'uSER pORT 300-2400'
	.byte 'up9600 / ez232    '
	.byte 'sWIFT / tURBO de  '
	.byte 'sWIFT / tURBO df  '
	.byte 'sWIFT / tURBO d7  '
op6txt	.byte "sTANDARDzIMODEM "
op3txt	.byte "pUNTER    ","xMODEM    ","xMODEM-crc"
	;themes
	;0-classic
	;1-Iman of XPB v7.1
	;2-v8.1 Predator/FCC
	;3-9.4 Ice THEME
	;4-17.2 Defcon/Unicess
op4txt	.byte "cLASSIC ccgms V5.5  "
	.byte "iMAN / xpb V7.1     "
	.byte "pREDATOR / fcc V8.1 "
	.byte "iCE THEME V9.4      "
	.byte "dEFCON/uNICESS V17.2"
	.byte "aLWYZ / ccgms 2021  "
op5txt	.byte 29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,"ef  ",29,29,29,29,29,29,29,29,29,29,29,29,29,29,29,"dISK"
prmtab
	lda #$0d
	jsr chrout
	jsr chrout
	ldx #17
	jmp outspc
prmclc;duplex/modem type/protocol display
	tya
	asl a
	tax
	lda prmopt,x
	sta prmadr+1
	lda prmopt+1,x
	sta prmadr+2
	rts
prmprt
	dex
	bmi prmpr2
	lda prmadr+1
	clc
	adc prmlen,y
	sta prmadr+1
	lda prmadr+2
	adc #$00
	sta prmadr+2
	bne prmprt
prmpr2
	inx
prmadr
	lda op1txt,x
	jsr chrout
	inx
	txa
	cmp prmlen,y
	bne prmadr
	jmp prmtab
;
f7parm
	lda #19
	jsr chrout
	lda #1
	sta 646
	ldy f7thob
prmlop
	jsr prmtab
	dey
	bne prmlop
	jsr prmclc
	lda baudrt
	asl a
	tax
	lda bpsspd+1,x
	pha
	lda bpsspd,x
	tax
	pla
	jsr outnum
	lda #$20
	jsr chrout
	jsr chrout
	jsr prmtab
	ldy #0;duplex
	jsr prmclc
	ldx duplex
	jsr prmprt
	iny
	jsr prmclc
	ldx motype
	jsr prmprt
	ldy #2
	jsr prmclc
	ldx mopo1
	jsr prmprt
	ldy #3
	jsr prmclc
	ldx protoc
	jsr prmprt
	ldy #4
	jsr prmclc
	ldx theme
	jsr prmprt
	lda efbyte
	beq skipeflisting
	ldy #5
	jsr prmclc
	ldx diskoref
	jmp prmprt
skipeflisting
	rts

scracf	.byte "S0:",0
svctxt	.byte $93,13,5,"fILENAME: ",0
conffn	.byte "CCGMS-PHONE",0
f7thob	.byte 2
f7mtxt	.byte $93,16,14,5
	.byte "   dIALER/pARAMETERS",13
	.byte 31,"   ",163,163,163,163,163,163,163,163,163,163,163,163,163,163
	.byte 163,163,163,13,5
f7mtx1	.byte 16
	.byte 05,32,2,"AUTO-dIALER/pHONEBOOK",13,13
	.byte 32,2,"BAUD rATE   -",13,13
	.byte 32,2,"DUPLEX      -",13,13
	.byte 32,2,"MODEM tYPE  -",13,13
f7mtxpre
	.byte 32,2,"F IRMWARE    -",13,13
	.byte 32,2,"PROTOCOL    -",13,13
	.byte 32,2,"THEME       -",13,13,0
f7mtx3noef
	.byte 32,2,"EDIT mACROS",13,13,0
f7mtx3ef
	.byte 32,2,"EDIT mACROS  ",32,2,"CFG dEVICE -",13,13,0
f7mtxcont
	.byte 32,2,"LOAD/",2,"SAVE pHONE bOOK AND cONFIG.",13,13
	.byte 32,2,"VIEW aUTHOR'S mESSAGE",13,13,0
f7mtx2
prret	.byte 3,22,0,5,cp,"RESS <",158,18,"r",e,t,u,cr,n,146,5,"> TO ABORT.",13,0
prret2	.byte 3,22,7,159,"return",13,0

bpsspd	.byte 44,1,176,4,96,9,192,18,128,37,0,75,0,150;new rates
	;  300  1200  2400 4800   9600   19200  38400
	;  00   01    02    03   04     05     06
	;  256  256   1024  2304 4608   9472   19200

