; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Cursor logic
;

.import col80_invert, col80_restore

;----------------------------------------------------------------------
; invert character at cursor position
invert_csr_char:
	bit col80_active
	bpl :+
	jmp col80_invert

:	jsr calc_scr_ptr
	sta tempch
	eor #$80
	sta (locat),y	; invert character
	jsr calc_col_ptr
	sta tempcl
	lda textcl
	sta (locat),y	; set current color
	rts

;----------------------------------------------------------------------
; restore char at cursor position
restore_csr_char:
	bit col80_active
	bpl :+
	jmp col80_restore

:	jsr calc_scr_ptr
	lda tempch
	sta (locat),y
	jsr calc_col_ptr
	lda tempcl
	sta (locat),y
	rts

;----------------------------------------------------------------------
; clear character at cursor position
clear_csr_char:
	lda #' '
	jsr chrout
	lda #CSR_LEFT
	jmp chrout

;----------------------------------------------------------------------
cursor_off:
	ldx cursor_flag
	bne restore_csr_char
	jsr quote_insert_off
	jmp clear_csr_char

;----------------------------------------------------------------------
cursor_show:
	lda cursor_flag
	bne :+
	lda #CURSOR
	jsr chrout
	lda #CSR_LEFT
	jmp chrout
:	jmp invert_csr_char
