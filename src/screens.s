; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Screen swapping, cursor logic
;

;----------------------------------------------------------------------
; swap screen with #1-4 (behind KERNAL ROM)
swap_screen:
	txa
	pha
	jsr cursor_off
	lda SHFLAG
	sta tmp04
	pla
	asl a
	asl a
	asl a
	clc
	adc #>SCREENS_BASE
	sta locat+1
	lda #>$0400
	sta tmp03
	lda #0
	sta locat
	sta tmp02
	sei
	lda $d011
	pha
	lda #$0b
	sta $d011	; screen off
	lda #<ramnmi
	sta $fffa
	lda #>ramnmi
	sta $fffb
	lda #$2f
	sta $00
	lda #$35	; disable ROMs
	sta $01
scrtg1
	jsr scrnl1
	cmp #$08
	bcc scrtg1
	lda #>$d800
	sta tmp03
scrtg2
	jsr scrnl1
	cmp #>$dc00
	bcc scrtg2
	pla
	sta $d011
	lda #$37
	sta $01		; enable ROMs
	cli
	jmp term_mainloop
ramnmi
	sta tempch
	lda #$37
	sta $01		; enable ROMs
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
	sta $01		; enable ROMs
	pla
	rti
scrnl1
	ldx tmp04	; SHFLAG
	cpx #SHFLAG_SHIFT | SHFLAG_CTRL
	beq scrnls
	ldy #0
scrnlc	lda (tmp02),y
	sta (locat),y
	dey
	bne scrnlc
	beq scrnl3
scrnls	ldy #0
scrnl2	;swap screen page
	lda (tmp02),y
	tax
	lda (locat),y
	sta (tmp02),y
	txa
	sta (locat),y
	iny
	bne scrnl2
scrnl3	lda #<ramnmi
	sta $fffa
	lda #>ramnmi
	sta $fffb
	inc locat+1
	inc tmp03
	lda tmp03
	rts
outspc
	lda #CSR_RIGHT
outsp1
	jsr chrout
	dex
	bne outsp1
	rts
bufclr
	lda buffst
	sta buffer_ptr
	lda buffst+1
	sta buffer_ptr+1
	rts

;----------------------------------------------------------------------
; calculate screen pointer (and read)
calc_scr_ptr:
	ldy LINE
	lda LDTB2,y	; low byte of screen address for line
	sta locat
	lda LDTB1,y	; hi byte
	and #$7f
	sta locat+1
	lda COLUMN
	cmp #40
	bcc :+
	sbc #40
	clc
:	adc locat
	sta locat
	lda locat+1
	adc #0
	sta locat+1
	ldy #0
	lda (locat),y
	rts

;----------------------------------------------------------------------
; calculate color RAM pointer (and read)
calc_col_ptr:
	jsr calc_scr_ptr
	lda #$d4
	clc
	adc locat+1
	sta locat+1
	lda (locat),y
	rts

;----------------------------------------------------------------------
; turn off quote mode and insert mode
quote_insert_off:
	lda #0
	sta qmode
	sta imode
	rts

