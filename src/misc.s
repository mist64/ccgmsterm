; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Miscellaneous 1
;

;----------------------------------------------------------------------
text_color_save:
	ldx textcl
	stx tmp04
;----------------------------------------------------------------------
text_color_set:
	ldx #TCOLOR
	stx textcl
	rts
;----------------------------------------------------------------------
text_color_restore:
	ldx tmp04
	stx textcl
	rts

;----------------------------------------------------------------------
handle_f6_directory:
	lda #1
	ldx #<dirfn
	ldy #>dirfn
dodir:
	jsr setnam
	jsr dir
	jsr enablexfer
	jmp term_mainloop

;----------------------------------------------------------------------
handle_f8_switch_term:
	ldx SHFLAG
	cpx #SHFLAG_CBM
	jeq cf7_screen_to_buffer

	lda ascii_mode
	eor #1
	sta ascii_mode
	jsr bell
	jmp term_entry

;----------------------------------------------------------------------
toggle_cursor:		; [XXX unused]
	jsr cursor_off
	lda cursor_flag
	eor #1
	sta cursor_flag
	jmp term_mainloop
