; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; ASCII/PETSCII conversion and ANSI control code emulation
;

; 0: not escape mode
; 1: ESC encountered
; 2: ESC-set-color encountered
ansi_escape_mode:
	.byte 0

ansitemp:
	.byte 0

ansi_color_table:
	.byte 0

ansi0colors:
	.byte RVSOFF,RED,GREEN,BROWN,BLUE,PURPLE,CYAN,GRAY,0,0,0
ansi1colors:
	.byte DKGRAY,LTRED,LTGREEN,YELLOW,LTBLUE,PURPLE,CYAN,WHITE,0,0,0

;----------------------------------------------------------------------
; Convert an ASCII character to PETSCII; interpret ANSI control codes
ascii_to_petscii:
	pha
	lda ansi_escape_mode
	jeq plain_mode	; not in ANSI escape mode, check for it

; in ANSI escape mode
	cmp #2		; is ansi color code on?
	beq coloron2

	pla
	cmp #'2'
	beq ansi_clrhome
	cmp #'3'
	beq ansi_set_color_mode
	cmp #'4'
	beq ansi_set_color_mode	; ansi_rvs_on when we figure out rvs
	cmp #'0'
	beq ansi_set_color_table_0
	cmp #'7'
	beq ansi_rvs_on		; rvs
	cmp #'1'
	beq ansi_set_color_table_1
	cmp #';'
	jeq ansi_semicolon
	cmp #'['
	beq ansi_leftbracket	; [ after escape code
	cmp #'M'
	bne :+
@end:	jmp ansi_end		; [XXX beq @end]
:	cmp #'m'
	beq @end
	cmp #'J'
	beq ansi_end
	cmp #'j'
	beq ansi_end
	cmp #'H'
	beq ansi_end
	cmp #'h'
	beq ansi_end
	cmp #']'
	beq ansi_return_0
	jmp ansi_return	; out of ideas,move on

ansi_set_color_table_0:
	lda #0
	sta ansi_color_table
	jmp ansi_return_0

ansi_set_color_table_1:
	lda #1
	sta ansi_color_table
	jmp ansi_return_0

ansi_rvs_on:
	lda #1		; escape mode stays on
	sta ansi_escape_mode
	lda #RVSON
	jmp ansi_return

ansi_clrhome:
	lda #1		; escape mode stays on
	sta ansi_escape_mode
	lda #CLR
	jmp ansi_return

ansi_leftbracket:	; ansi is on and got the left bracket
	lda #1		; escape mode stays on
	sta ansi_escape_mode
	lda #0		; display nothing and move on in ansi mode
	jmp ansi_return

ansi_set_color_mode:
	lda #2
	sta ansi_escape_mode
ansi_return_0:
	lda #0
	jmp ansi_return

; in ANSI escape *color* mode
coloron2:
	lda ansi_color_table
	beq @1

; color table 1
	lda #0
	sta ansi_color_table
	pla
	sec
	sbc #'0'
	tay
	lda #1
	sta ansi_escape_mode
	lda ansi1colors,y
	jmp ansi_return

; color table 0
@1:	pla
	sec
	sbc #'0'
	tay
	lda #1
	sta ansi_escape_mode
	lda ansi0colors,y
	jmp ansi_return

ansi_semicolon:
	lda #1		; escape mode stays on
	sta ansi_escape_mode
	lda #0
	jmp ansi_return

ansi_end:
	lda #0
	sta ansi_escape_mode
	jmp ansi_return

; not in ANSI escape mode
plain_mode:
	pla
	cmp #27		; ESC: ANSI escape code
	beq :+
	jmp plain_char	; [XXX bne plain_char]

:	lda #1
	sta ansi_escape_mode
	lda #0
	jmp ansi_return

plain_char:
	cmp #UNDERLINE
	bne @0
	lda #UNDERLINE	; [XXX remove]
	bne ansi_return
@0:	and #$7f
	cmp #'z'+1
	bcs ansi_return
	cmp #'a'
	bcc @1
	sbc #' '
	bne ansi_return
@1:	cmp #'A'
	bcc @2
	cmp #'Z'+1
	bcs ansi_return
	adc #$80
	bne ansi_return
@2:	cmp #8		; backspace
	bne @3
	lda #DEL
@3:	cmp #$0c	; form feed
	bne @4
	lda #CLR
@4:	cmp #' '
	bcs ansi_return
	cmp #7		; bell
	beq ansi_return
	cmp #CR
	beq ansi_return
	cmp #DEL
	beq ansi_return	; [XXX]
	bne ansi_return_0b

ansi_return:
	cmp #0
	rts
ansi_return_0b:		; [XXX duplicate]
	lda #0
	beq ansi_return

;----------------------------------------------------------------------
; Convert PETSCII to ASCII
petscii_to_ascii:
	cmp #DEL
	bne @0
	lda #8		; ctrl-h (backspace)
	bne @exit

@0:	cmp #UNDERLINE	; [XXX no-op]
	bne @1		; [XXX no-op]
	lda #UNDERLINE	; [XXX no-op]
@1:	cmp #'A'
	bcc ansi_return	; if < then no conv
	cmp #'Z'+1
	bcs @2
	adc #' '	; lower a...z..._
	bne @exit

@2:	cmp #' '+$80
	bne @3
	lda #' '	; shift to space
	bne @exit

@3:	and #$7f
	cmp #'A'
	bcc ansi_return_0b
	cmp #'a'	; upper a...z
	bcs ansi_return_0b
@exit:	cmp #0
	rts
