;ANSI STUFF HERE
ansi	.byte 00
ansitemp
	.byte 00
ansicolor
	.byte 00
ansi0colors
	.byte 146,28,30,149,31,156,159,152,0,0,0
ansi1colors
	.byte 151,150,153,158,154,156,159,05,0,0,0
;convert standard ascii to c= ascii
satoca
	pha
	lda ansi
jeq	satoca2;no ansi, but check for ansi
ansion
	cmp #$02;is ansi color code on?
	beq coloron2
	pla
	cmp #'2'
	beq clrhomeansi
	cmp #'3'
	beq coloron
	cmp #'4'
	beq coloron;code4on when we figure out rvs
	cmp #'0'
	beq turn0on
	cmp #'7'
	beq code4on;7 is rvs
	cmp #'1'
	beq turn1on
	cmp #$3b;semicolon
jeq	semion
	cmp #'['
	beq leftbracketansi;[ after escape code
	cmp #'M'
	bne :+
ansimend2:
	jmp ansimend
:
	cmp #'m'
	beq ansimend2
	cmp #'J'
	beq ansimend
	cmp #'j'
	beq ansimend
	cmp #'H'
	beq ansimend
	cmp #'h'
	beq ansimend
	cmp #']'
	beq outtahere
	jmp cexit;out of ideas,move on
turn0on
	lda #0
	sta ansicolor
	jmp outtahere
turn1on
	lda #1
	sta ansicolor
	jmp outtahere
code4on;rvs on for next color
	lda #$01
	sta ansi
	lda #$12;rvs on
	jmp cexit
clrhomeansi;rvs on for next color
	lda #$01;ansi stays on to see if there's another command after
	sta ansi
	lda #$93;clr/home
	jmp cexit
leftbracketansi;ansi is on and got the left bracket
	lda #$01;ansi stays on to see if there's another command after
	sta ansi
	lda #$00;display nothing and move on in ansi mode
	jmp cexit
coloron
	lda #$02
	sta ansi
outtahere
	lda #$00
	jmp cexit
coloron2
	lda ansicolor
	beq ansizerocolors
ansionecolors
	lda #0
	sta ansicolor
	pla
	sec
	sbc #48
	tay
	lda #$01
	sta ansi
	lda ansi1colors,y
	jmp cexit
ansizerocolors
	pla
	sec
	sbc #48
	tay
	lda #$01
	sta ansi
	lda ansi0colors,y
	jmp cexit
semion
	lda #$01
	sta ansi
	lda #$00
	jmp cexit
ansimend
	lda #$00
	sta ansi
	jmp cexit
satoca2
	pla
	cmp #$1b;ansi escape code
	beq ansi1
	jmp satoca1
ansi1
	lda #$01
	sta ansi;turn ansi on
	lda #$00
	jmp cexit
satoca1
	cmp #$a4;underline key
	bne clab0
	lda #164   ;underline
	bne cexit
clab0
	and #127
	cmp #124
	bcs cexit
	cmp #96
	bcc clab1
	sbc #32
	bne cexit
clab1
	cmp #65
	bcc clab2
	cmp #91
	bcs cexit
	adc #128
	bne cexit
clab2
	cmp #08
	bne clab3
	lda #20
clab3
	cmp #12
	bne clab4
	lda #$93
clab4
	cmp #32     ;don't allow home,
	bcs cexit   ;cd, or cr
	cmp #07
	beq cexit
	cmp #$0d
	beq cexit
	cmp #20
	beq cexit
	bne cerrc
cexit	cmp #$00
	rts
ansi0keys
cerrc
	lda #$00
	beq cexit
;convert c= ascii to standard ascii
catosa
	cmp #20
	bne alab0
	lda #08    ;delete
	bne aexit
alab0	cmp #164 ;underline
	bne alab1
	lda #$a4;underline key
alab1	cmp #65
	bcc cexit  ;if<then no conv
	cmp #91
	bcs alab2
	adc #32    ;lower a...z..._
	bne aexit
alab2	cmp #160
	bne alab3
	lda #32    ;shift to space
	bne aexit
alab3	and #127
	cmp #65
	bcc cerrc
	cmp #96    ;upper a...z
	bcs cerrc
aexit	cmp #$00
	rts
savech
	jsr finpos
	sta tempch
	eor #$80
	sta (locat),y
	jsr fincol
	sta tempcl
	lda textcl
	sta (locat),y
	rts
restch	;restore char und non-crsr
	jsr finpos
	lda tempch
	sta (locat),y
	jsr fincol
	lda tempcl
	sta (locat),y
	rts
spleft	;output space, crsrleft
	lda #$20
	jsr chrout
	lda #left
	jmp chrout
curoff
	ldx cursfl
	bne restch
	jsr qimoff
	jmp spleft
curprt
	lda cursfl
	bne nondst
	lda #cursor
	jsr chrout
	lda #left
	jmp chrout
nondst
	jmp savech
