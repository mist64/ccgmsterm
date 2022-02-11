cosave
	ldx textcl
	stx tmp04
cochng
	ldx #TCOLOR
	stx textcl
	rts
coback
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
	jeq cf7

	lda ascii_mode
	eor #1
	sta ascii_mode
	jsr bell
	jmp term_entry

;----------------------------------------------------------------------
; ascii crsr toggle
crsrtg:
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
	bne hangup6;not C= Stop
	jsr cursor_off
	lda #<txt_disconnecting
	ldy #>txt_disconnecting
	jsr outstr
	lda modem_type
	beq droprs	; MODEM_TYPE_USERPORT
	cmp #MODEM_TYPE_UP9600
	beq dropup
	jmp dropswift
hangup6	jmp term_mainloop

;----------------------------------------------------------------------
droprs:
	lda #%00000100
	sta $dd03
	lda #0
	sta $dd01
	ldx #226
	stx JIFFIES
:	bit JIFFIES
	bmi :-
	lda #4
	sta $dd01
	jmp term_mainloop

dropup	lda #$04
	sta $dd03    ;cia2: data direction register b
	lda #$02
	sta $dd01    ;cia2: data port register b
	ldx #$e2
	stx JIFFIES
a7ef3	bit JIFFIES
	bmi a7ef3
	lda #$02
	sta $dd03    ;cia2: data direction register b
	jmp term_mainloop

dropswift
	jsr sw_dropdtr
	jmp term_mainloop
