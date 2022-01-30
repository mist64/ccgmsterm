;xmodem-crc fix here til xferpt
xmdtxt	.byte 13,13,5,cx,m,'ODEM ',0
xmctxt	.byte 13,13,5,cx,m,'ODEM-crc ',0
xferfn
	pha
	lda protoc
	beq xferpt
	cmp #$02
	beq crctxt
	lda #<xmdtxt
	ldy #>xmdtxt
	jsr outstr
	jmp xferwc
crctxt
	lda #<xmctxt
	ldy #>xmctxt
	jsr outstr
	jmp xferwc
xferpt
	lda #<ptrtxt
	ldy #>ptrtxt
	jsr outstr
xferwc
	pla
	bne xferdw
	lda #<upltxt
	ldy #>upltxt
	clc
	bcc entfnt
xferdw
	lda #<dowtxt
	ldy #>dowtxt
entfnt
	jsr outstr
	lda #<lodtxt
	ldy #>lodtxt
	jsr outstr
entfil
	ldx #0
entfil2
	lda #0
	sta inpbuf,x
	inx
	cpx #20
	bne entfil2
	lda #<flntxt
	ldy #>flntxt
	ldx #16
	jsr input
	php
	lda #$0d
	jsr chrout
	plp
	rts
abortx
	jsr clrchn
	lda #<abrtxt
	ldy #>abrtxt
	jsr outstr
	jsr coback
	jsr disablexfer
	lda #$02
	jsr close
	jsr enablexfer
	jmp main
xfermd	pha
	jmp xferm0
xfrmsg
	pha
	lda #15
	sta textcl
	sta backgr
	lda #$93
	jsr chrout
	lda #bcolor
	sta backgr
xferm0	lda #13
	sta 214
	lda #$0d
	jsr chrout
	lda #06
	sta textcl
	ldx #40
	lda #192
xferm1	jsr chrout
	dex
	bne xferm1
	lda #<xfrmed
	ldy #>xfrmed
	jsr outstr
	pla
	bne xferm2
	lda #<upltxt
	ldy #>upltxt
	clc
	bcc xferm3
xferm2
	lda #<dowtxt
	ldy #>dowtxt
xferm3
	jsr outstr
	lda #<xfrtxt
	ldy #>xfrtxt
	jsr outstr
	ldy #0
xferm4	lda inpbuf,y
	jsr chrout
	iny
	cpy max
	bne xferm4
	lda inpbuf,y
	jsr chrout
	lda inpbuf+1,y
	jsr chrout
	lda #$0d
	jsr chrout
	lda #<xf2txt
	ldy #>xf2txt
	jmp outstr
margin
	lda #<mrgtxt
	ldy #>mrgtxt
	jmp outstr
upltyp	.byte 0,'P','S','U'
f1	;upload
	jsr turnoffscpu
	jsr disablexfer
	jsr cosave
	lda #0
	sta mulcnt
	jsr xferfn
	bne uplfff
	jmp abortx
uplfff
	jsr ercopn
	ldy max
	lda #','
	sta inpbuf,y
	lda #$50;'P'
	sta inpbuf+1,y
	jsr filtes
	beq uplfil
	ldy max
	lda #$53;'S'
	sta inpbuf+1,y
	jsr filtes
	beq uplfil
	ldy max
	lda #$55;'U'
	sta inpbuf+1,y
uplmen
	jsr filtes
	beq uplfil
	pha
	ldx #$0f
	jsr chkin
	pla
	jmp drver3
uplfil
	ldy max
	ldx #03
fltpsr	lda upltyp,x
	cmp inpbuf+1,y
	beq fltpfo
	dex
	bne fltpsr
fltpfo	stx pbuf+27
	jmp uplok
filtes
	ldy max
	iny
	iny
	tya
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #02
	ldx diskdv
	ldy #00
	jsr setlfs
filopn	jsr open
	ldx #15
	jsr chkin
	jsr getin
	cmp #'0'
	beq filtso
	php
	pha
	lda #$02
	jsr close
	pla
	plp
filtso	rts
uplok
	lda #0
	jsr xfrmsg
	jsr clrchn
	lda protoc
	beq uplok2;punter
;crc fix - create tables
	jsr crctable
;end crc fix
	jsr margin
	jmp xmoupl
uplok2
	jsr clear232
	jsr p49173
	jsr p49164
	lda inpbuf
	cmp #01
	bne uplcon
	jsr bell
	jmp abortx
uplcon
	jsr margin
	jsr p49173
	lda #$ff
	sta pbuf+24
	jsr p49158
xfrend
	jsr disablexfer
	lda #02
	jsr close
	jsr clrchn
	lda #$0d
	jsr chrout
	lda mulcnt
	beq xfrnrm
	rts
xfrnrm
	lda inpbuf
	cmp #$01
	bne xfrdun
	jmp abortx
xfrdun
	jsr pnt109;clear and reenable
	jsr gong
	jmp main
f3	;download
	jsr disablexfer
	lda #0
	sta mulcnt
	jsr cosave
	jsr turnoffscpu
	lda #$01
	jsr xferfn;display "punter protocol, enter name" and input string
	bne dowfok
	jmp abortx
dowfok
	lda protoc
	beq dowfo2
	jsr xmotyp
	jmp dowmen
dowfo2
	ldy max
	lda #160
	sta inpbuf,y
	sta inpbuf+1,y
dowmen
	lda #01
	jsr xfrmsg;set up screen
	ldx protoc
	bne dowcon
	lda inpbuf
	pha
	jsr clrchn
dowmen2
	jsr p49173;enable rs232 to receive;pnt109
	jsr p49161;zero out punter buffers for new download and get file info from sender
	ldx inpbuf
	pla
	sta inpbuf
	lda mulcnt
	bne dowcon
	cpx #01
	bne dowcon
dowabt
	jsr bell
	jmp abortx
dowcon
	ldx #$ff
	stx pbuf+24
	jsr disablexfer
	jsr ercopn
	ldx #$0f
	jsr chkout
	lda #'I'
	jsr chrout
	lda #'0'
	jsr chrout
	lda #$0d
	jsr chrout
	jsr clrchn
	ldx #$0f
	jsr chkout
	lda #'S'
	jsr chrout
	lda #'0'
	jsr chrout
	lda #':'
	jsr chrout
	ldx #0
scrlop
	lda inpbuf,x
	jsr chrout
	inx
	cpx max
	bne scrlop
	lda #$0d
	jsr chrout
	jsr dowsfn
	lda #1
	jsr xfermd
	jsr margin
	jmp dowopn
dowsfn
	jsr clrchn
	ldx max
	lda #','
	sta inpbuf,x
	sta inpbuf+2,x
	inx
	lda #'W'
	sta inpbuf+2,x
	lda mulcnt
	bne dowksp
	ldy pbuf+27
	lda upltyp,y
	sta inpbuf,x
dowksp
	lda max
	clc
	adc #$04
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #02
	ldx diskdv
	tay
	jmp setlfs
dowopn
	jsr filopn
	beq dowop2
	pha
	ldx #$0f
	jsr chkin
	pla
	jmp drver3
dowop2
	lda protoc
	beq dowop3
	jsr crctable;create crc tables;crc fix
	jmp xmodow;pick punter or xmodem here to really start downloading
dowop3
	jsr p49173;pnt109
	jsr p49155;get data;pnt87
	jsr clear232
	jmp xfrend;close file
;
sndtxt	.byte 13,13,5,2,'READ OR',2,'SEND FILE? ',00
sndtxttwo
	.byte 'sPACE TO PAUSE - r/s TO ABORT',13,13,00
f2
	ldx 653
	cpx #02
	bne send
	jmp cf1
;send textfile
send
	jsr disablexfer
	jsr cosave
	lda #<sndtxt
	ldy #>sndtxt
	jsr outstr
	jsr savech
sndlop
	jsr getin
	cmp #'S'
	bne sndc1
	ldx #$40
	bne sndfil
sndc1
	cmp #'R'
	bne sndc2
	ldx #0
	beq sndfil
sndc2
	cmp #$0d
	bne sndlop
	jsr restch
	lda #$0d
	jsr chrout
sndabt
	jmp abortx
sndfil
	ora #$80
	jsr outcap
	lda #$0d
	jsr chrout
	stx bufflg
	stx buffl2
	jsr entfil
	beq sndabt
	lda #$0d
	jsr chrout
	lda max
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #<sndtxttwo
	ldy #>sndtxttwo
	jsr outstr
	lda #02
	ldx diskdv
	tay
	jsr setlfs
	jsr open
	ldx #$05
	jsr chkout
;lda #15
;jsr chrout
	jsr dskout
	lda #02
	jsr close
	lda #0
	jsr enablexfer
	jsr cochng
	lda #$0d
	jsr chrout
	jmp main

nickdelaybyte
	.byte $00

tmsetl
	ldx #0
	stx $a2
tmloop
	ldx $a2
	cpx #$03  ;***time del
	bcc tmloop
tmlop3
	ldx #255
tmlop2	dex
	bne tmlop2
	rts
