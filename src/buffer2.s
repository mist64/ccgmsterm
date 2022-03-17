; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Screen to Buffer
;

stbrvs	.byte 0	; current reverse state
stbcol	.byte 0	; current color
stbxps	.byte 0	; current x position
stbyps	.byte 0	; current y position
stbmax	.byte 0	; max x for this line
stbmay	.byte 0	; max y

tmpchr	= tmp02
tmpcol	= tmp03

cf7_screen_to_buffer:
	lda #40
	bit col80_enabled
	bpl :+
	lda #80
:	sta @mode_line_with

	lda #0
	sta NDX		; clear kbd buffer

	lda #$100-15	; delay .25s
	sta JIFFIES
:	lda JIFFIES
	bne :-

	jsr getin
	cmp #$8c	; f8
	bne :+
	jsr bufclr
:	lda buffer_open
	pha
	lda #1
	sta buffer_open
	lda #0
	sta stbrvs
	lda #255
	sta stbcol	; illegal col, different to any col

	; find screen height by counting empty lines from the bottom
	lda #24
	sta stbyps
@bf1:	ldx @mode_line_with
	dex
	stx stbxps
@bf2:	jsr read_scr_chr
	cmp #' '
	bne :+
	dec stbxps
	bpl @bf2
	dec stbyps
	bpl @bf1
	jmp @br4	; empty screen - skip everything
:

	lda #CR
	jsr buffer_put	; [XXX why?]
	lda #CLR
	jsr buffer_put

	; emit code to switch to correct charset
	jsr get_charset
	lsr a
	lsr a
	ror a
	eor #$8e
	jsr buffer_put

	; emit code to set background color
	lda $d021
	and #15
	beq :+		; 0 is default, so skip
	tax
	lda COLTAB,x
	pha
	lda #2		; CCGMS-specific code that next
	jsr buffer_put	; color code will change bg color
	pla
	jsr buffer_put
:

	lda #10
	jsr buffer_put
	lda stbyps
	sta stbmay
	lda #0
	sta stbyps

@loop_lines:
	; find length of line by counting spaces from the right
	ldx @mode_line_with
	dex
	stx stbxps
@4:	jsr read_scr_chr
	cmp #' '
	bne @5
	dec stbxps
	bpl @4
	inc stbxps
	jmp @brt	; skip line
@5:	lda stbxps
	sta stbmax

	; convert line to PETSCII
	lda #0
	sta stbxps
@loop_chars:
	jsr read_scr_chr
	sta tmpchr
	jsr read_scr_col
	sta tmpcol
	lda tmpchr
	and #$80	; RVS?
	cmp stbrvs
	beq @norvs
	lda stbrvs
	eor #$80
	sta stbrvs
	ora #RVSON
	eor #$80
	jsr buffer_put	; emit RVSON or RVSOFF
@norvs:
	lda tmpchr
	cmp #' '
	beq @nocol
	lda tmpcol
	cmp stbcol
	beq @nocol
	sta stbcol
	tax
	lda COLTAB,x
	jsr buffer_put	; emit color code
@nocol:
	; convert char to PETSCII
	lda tmpchr
	and #$7f	; remove reverse bit
	cmp #$7f
	beq @9
	cmp #$20
	bcs @10
@9:	clc
	adc #$40
	bne @11
@10:	cmp #$40
	bcc @11
	ora #$80
@11:	jsr buffer_put	; emit character

	inc stbxps
	lda stbxps
	cmp stbmax
	bcc @loop_chars
	beq @loop_chars

@brt:
	lda stbxps
@mode_line_with=*+1
	cmp #40
	bcs :+		; no CR if 40 char wide
	lda #CR
	jsr buffer_put
	lda #0
	sta stbrvs	; CR resets RVS
:
	inc stbyps
	lda stbyps
	cmp stbmay
	beq :+
	bcs @bre
:	jmp @loop_lines

@bre:
	; finally, set current cursor color
	ldx textcl
	lda COLTAB,x
	jsr buffer_put

@br4:
	pla
	sta buffer_open
	jmp term_mainloop

;----------------------------------------------------------------------
; read character from screen
read_scr_chr:
	bit col80_enabled
	bpl :+
	ldx stbxps
	ldy stbyps
	jmp col80_read_scr_chr

:	ldy stbyps
	lda LDTB2,y	; line address lo
	sta locat
	lda LDTB1,y	; line address hi
	and #$7f	; remove double-line bit
	sta locat+1
	ldy stbxps
	lda (locat),y	; read char
	rts

;----------------------------------------------------------------------
; read color
read_scr_col:
	bit col80_enabled
	bpl :+
	ldx stbxps
	ldy stbyps
	jmp col80_read_scr_col

:	jsr read_scr_chr	; [XXX redundant]
	lda locat+1
	clc
	adc #(>$d800)-(>$0400)
	sta locat+1
	lda (locat),y	; read color
	and #15
	rts
