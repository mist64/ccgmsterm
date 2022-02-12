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

;----------------------------------------------------------------------
; hang up phone
hangup:
	ldx SHFLAG
	cpx #SHFLAG_CBM
	bne :+	; not C= Stop
	jsr cursor_off
	lda #<txt_disconnecting
	ldy #>txt_disconnecting
	jsr outstr
	lda modem_type
	beq droprs	; MODEM_TYPE_USERPORT
	cmp #MODEM_TYPE_UP9600
	beq dropup
	jmp dropswift
:	jmp term_mainloop

;----------------------------------------------------------------------
; Drop: Userport
droprs:
	lda #%00000100
	sta $dd03
	lda #0
	sta cia2pb
	ldx #$100-30
	stx JIFFIES
:	bit JIFFIES
	bmi :-
	lda #4
	sta cia2pb
	jmp term_mainloop

;----------------------------------------------------------------------
; Drop: UP9600
dropup	lda #%00000100
	sta cia2ddrb
	lda #%00000010
	sta cia2pb
	ldx #$100-30
	stx JIFFIES
:	bit JIFFIES
	bmi :-
	lda #%00000010
	sta cia2ddrb
	jmp term_mainloop

;----------------------------------------------------------------------
; Drop: Swiftlink
dropswift:
	jsr sw_dropdtr
	jmp term_mainloop
