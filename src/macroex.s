; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Macro Execution
;

;----------------------------------------------------------------------
; xfer id and pw to macros F5 and F7
xferidpw:
	ldy #59
:	lda (nlocat),y
	sta macmem+69,y
	iny
	lda (nlocat),y
	beq :+
	jmp :-		; [XXX short jmp]
:	sta macmem+69,y
	ldy #71
:	lda (nlocat),y
	sta macmem+121,y
	iny
	lda (nlocat),y
	beq :+
	jmp :-		; [XXX short jmp]
:	sta macmem+121,y
	rts

;----------------------------------------------------------------------
macro_dry_run_mode:
	.byte 0
macro_tmp:
	.byte 0

;----------------------------------------------------------------------
decode_fkey_scancode:
	cpx #3		; from LSTX f-key value
	bne @1
	ldx #7
@1:	txa
	sec
	sbc #4		; now a = 0..3 for f1,f3,f5,f7
	ldx #5
:	asl a
	dex
	bpl :-		; a = 0,64,128,192
	sta macro_tmp
	rts

;----------------------------------------------------------------------
print_macro:
	lda LSTX	; 3-6 are F7/F1/F3/F5
	cmp #7
	bcc print_macro	; wait until key released

	jsr decode_fkey_scancode
prtmc0
	ldx macro_tmp	; index into macro text
	lda macmem,x
	beq @end
	pha
	ldx macro_dry_run_mode
	bne @mc2	; -> don't send

; send character
	ldx #LFN_MODEM
	jsr chkout
	pla
	pha
	ldx ascii_mode
	beq :+
	jsr petscii_to_ascii
:	jsr chrout	; send character to modem
	jsr clrchn
	lda #$100-3
	sta JIFFIES
:	lda JIFFIES
	bne :-		; wait 50 msec
	lda #$100-3
	sta JIFFIES
:	lda JIFFIES
	bne :-		; wait 50 msec [XXX combine]

; get echo
	ldx #LFN_MODEM
	jsr chkin
	jsr getin
	cmp #0
	bne @mci
	ldx half_duplex
	beq @mca
	ldx ascii_mode
	beq @mc2
	pla
	jsr petscii_to_ascii
	bne @mck
	beq @mc3
@mca:	pla
	bne @mc3
@mci:	tax
	pla
	txa
@mck:	ldx ascii_mode
	beq :+
	jsr ascii_to_petscii
:	pha

@mc2:	jsr cursor_off
	pla
	ldx macro_dry_run_mode
	bne :+		; then don't put into buffer
	jsr buffer_put
:	jsr handle_control_codes
	bcs @mc3
	jsr chrout
	jsr quote_insert_off
	jsr cursor_show
@mc3:	inc macro_tmp
	cmp #255
	bne prtmc0
@end:	jmp cursor_off
