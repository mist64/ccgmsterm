cosave
	ldx textcl
	stx tmp04
cochng
	ldx #tcolor
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
	jmp main

;----------------------------------------------------------------------
handle_f8_switch_term:
	ldx SHFLAG
	cpx #SHFLAG_CBM
	jeq cf7

	lda ascii_mode
	eor #1
	sta ascii_mode
	jsr bell
	jmp term

;----------------------------------------------------------------------
; ascii crsr toggle
crsrtg:
	jsr cursor_off
	lda cursor_flag
	eor #1
	sta cursor_flag
	jmp main

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
	lda motype
	beq droprs
	cmp #$01
	beq dropup
	jmp dropswift
hangup6	jmp main

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
	jmp main

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
	jmp main

dropswift
	jsr sw_dropdtr
	jmp main
