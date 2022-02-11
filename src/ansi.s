; ASCII/ANSI Support

ansi:
	.byte 0

ansitemp:
	.byte 0

ansicolor:
	.byte 0

ansi0colors:
	.byte RVSOFF,RED,GREEN,BROWN,BLUE,PURPLE,CYAN,GRAY,0,0,0
ansi1colors:
	.byte DKGRAY,LTRED,LTGREEN,YELLOW,LTBLUE,PURPLE,CYAN,WHITE,0,0,0

;----------------------------------------------------------------------
; convert standard ascii to c= ascii
ascii_to_petscii:
	pha
	lda ansi
	jeq satoca2	; no ansi, but check for ansi
	cmp #2		; is ansi color code on?
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
	cmp #';'
	jeq semion
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
	jmp cexit	; out of ideas,move on

turn0on
	lda #0
	sta ansicolor
	jmp outtahere

turn1on
	lda #1
	sta ansicolor
	jmp outtahere

; rvs on for next color
code4on
	lda #1
	sta ansi
	lda #RVSON
	jmp cexit

;rvs on for next color
clrhomeansi
	lda #1		; ansi stays on to see if there's another command after
	sta ansi
	lda #CLR
	jmp cexit

leftbracketansi		; ansi is on and got the left bracket
	lda #1		; ansi stays on to see if there's another command after
	sta ansi
	lda #0		; display nothing and move on in ansi mode
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
	lda #1
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
	cmp #$1b	; ANSI escape code
	beq ansi1
	jmp satoca1

ansi1
	lda #1
	sta ansi	; turn ansi on
	lda #0
	jmp cexit

satoca1
	cmp #UNDERLINE
	bne @0
	lda #UNDERLINE
	bne cexit
@0:	and #127
	cmp #124
	bcs cexit
	cmp #96
	bcc @1
	sbc #' '
	bne cexit
@1:	cmp #'A'
	bcc @2
	cmp #'Z'+1
	bcs cexit
	adc #$80
	bne cexit
@2:	cmp #8
	bne @3
	lda #DEL
@3:	cmp #$0c
	bne @4
	lda #CLR
@4:	cmp #' '	; don't allow home,
	bcs cexit	; cd, or cr
	cmp #7
	beq cexit
	cmp #CR
	beq cexit
	cmp #DEL
	beq cexit
	bne cerrc
cexit	cmp #0
	rts
cerrc
	lda #0
	beq cexit

;----------------------------------------------------------------------
; convert c= ascii to standard ascii
petscii_to_ascii:
	cmp #20
	bne @0
	lda #8		; ctrl-h (backspace)
	bne @exit
@0:	cmp #UNDERLINE
	bne @1
	lda #UNDERLINE
@1:	cmp #'A'
	bcc cexit  ;if<then no conv
	cmp #'Z'+1
	bcs @2
	adc #' '    ;lower a...z..._
	bne @exit
@2:	cmp #' '+$80
	bne @3
	lda #' '    ;shift to space
	bne @exit
@3:	and #127
	cmp #65
	bcc cerrc
	cmp #96    ;upper a...z
	bcs cerrc
@exit:	cmp #0
	rts

;----------------------------------------------------------------------
savech:
	jsr finpos
	sta tempch
	eor #$80
	sta (locat),y
	jsr fincol
	sta tempcl
	lda textcl
	sta (locat),y
	rts

;----------------------------------------------------------------------
; restore char und non-crsr
restch:
	jsr finpos
	lda tempch
	sta (locat),y
	jsr fincol
	lda tempcl
	sta (locat),y
	rts
;----------------------------------------------------------------------
;output space, crsrleft
spleft:
	lda #' '
	jsr chrout
	lda #CSR_LEFT
	jmp chrout

;----------------------------------------------------------------------
cursor_off:
	ldx cursor_flag
	bne restch
	jsr quote_insert_off
	jmp spleft

;----------------------------------------------------------------------
cursor_show:
	lda cursor_flag
	bne :+
	lda #CURSOR
	jsr chrout
	lda #CSR_LEFT
	jmp chrout
:	jmp savech
