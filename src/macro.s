; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Macro editor
;

prwcmc:
	lda macro_tmp
	and #$c0
	asl a
	rol a
	rol a
	asl a
	clc
	adc #'1'
	sta txt_edit_index
	rts

;----------------------------------------------------------------------
SET_PETSCII
txt_edit_which_macro:
.ifdef BIN_2021
	.byte CLR,WHITE,CR,CR,e,"dit which macro?",CR
.else
	.byte CLR,WHITE,CR,CR,"Edit which macro?",CR
.endif
	.byte YELLOW,"(CTRL F1 / F3 or RETURN to abort.) ",WHITE,SETCSR,2,RVSON,0

txt_edit:
.ifdef BIN_2021
	.byte 19,CR,WHITE,e,"dit ",f
.else
	.byte 19,CR,WHITE,"Edit F"
.endif
txt_edit_index:
	.byte '1'
.ifdef BIN_2021
	.byte " Macro...<",c,t,cr,l,"-",cx,"> to end:",CR,CR,CR,CR,0
.else
	.byte " Macro...<CTRL-X> to end:",CR,CR,CR,CR,0
.endif
SET_ASCII

;----------------------------------------------------------------------
wchmac:
	.byte 0

macfull:
	.byte 0

;----------------------------------------------------------------------
edtmac:
	lda #<txt_edit_which_macro
	ldy #>txt_edit_which_macro
	jsr outstr
	jsr invert_csr_char
edtmlp	lda LSTX
	cmp #1    ;return
	bne edtmc2
edtmab	rts
edtmc2	cmp #4
	bcc edtmlp
	cmp #6
	bcs edtmlp
	pha
	jsr restore_csr_char
	pla
	tax
edtmc3
	lda LSTX
	cmp #7
	bcc edtmc3
	jsr decode_fkey_scancode
	sta wchmac
edtmen
	lda #0
	sta NDX
	lda #CLR
	jsr chrout
	lda #0
	sta $d020
	sta $d021
edtstr
	jsr prwcmc
	lda #<txt_edit
	ldy #>txt_edit
	jsr outstr
	lda #1
	sta macro_dry_run_mode
	sta cursor_flag
	lda wchmac
	sta macro_tmp
	clc
	adc #62
	sta macfull
	jsr restore_csr_char
	lda #' '
	jsr chrout
	lda #CSR_LEFT
	jsr chrout
	jsr prtmc0
edtinp	jsr cursor_show
edtkey
	jsr getin
	beq edtkey
	cmp #16   ;ctrl-p
	beq edtmen
	cmp #HOME	; no home or clr
	beq edtkey
	cmp #CLR
	bne edtky1
	ldx macro_tmp
edtclr
	lda #0
	sta macmem,x
	cpx wchmac
	beq edtky0
	dex
	jmp edtclr
edtky0	ldx wchmac
	stx macro_tmp
	jmp edtmen
edtky1
	cmp #24   ;ctrl-x
	beq edtbye
	cmp #DEL
	bne edtky2
	lda macro_tmp
	cmp wchmac
	beq edtkey
	tax
	jsr edtdel
jcs	edtmen
	lda macro_tmp
	and #$3f
	cmp #$3f
	bne edtkey
	jmp edtmen
edtky2
	ldx LINE
	cpx #23
	bcs edtkey
	cpx #3
	bcc edtkey
edtky3
	ldx macro_tmp
	cpx macfull;64 bytes of memory per macro
	bcs edtkey
	sta macmem,x
	pha
	txa
	cmp wchmac
	beq edtky4
	and #$3f
	bne edtky4
	pla
	jsr bell
	jmp edtmen
edtky4
	inc macro_tmp
	jsr cursor_off
	pla
	jsr handle_control_codes
	bcc edtky5
	jmp edtinp
edtky5
	jsr chrout
	jsr quote_insert_off
	jmp edtinp
edtbye	ldx macro_tmp
	lda #0
	sta macmem,x
	rts

macrvs:
	.byte RVSOFF
maccty:
	.byte 10
maccol:
	.byte 5
maccas:
	.byte LOCASE
macbkg:
	.byte 0

edtdel
	lda #RVSOFF
	sta macrvs
	lda #10
	sta maccty
	lda #5
	sta maccol
	lda #LOCASE
	sta maccas
	lda #0
	sta macbkg
	lda macmem-1,x
	cmp #UNDERLINE
	beq edtde2
	and #$7f
	cmp #$20
	bcc edtde0
	jmp edtdle
edtde0
	cmp #CSR_DOWN
	beq edtde1
	cmp #CSR_RIGHT
	bne edtde3
edtde1	lda macmem-1,x
edtdeo	eor #$80
	jmp edtdln
edtde2
	lda #INST
	jsr edprrv
	lda #CSR_RIGHT
	jmp edtdln
edtde3	lda macmem-1,x
	cmp #INST
	bne edtde4
	lda #CSR_RIGHT
	jsr edprrv
	lda #INST
	bne edtdeo
edtde4	jsr edtcok
	bmi edtde7
	ldx macro_tmp
	lda macmem-2,x
	sta macbkg
edtde5	dex
	cpx wchmac
	beq edtde6
	lda macmem-1,x
	jsr edtcok
	bmi edtde5
	ldy macmem-2,x
	cpy macbkg
	beq edtdcl
	cpy #2
	beq edtde5
	ldy macbkg
	cpy #2
	beq edtde5
edtdcl
	sta maccol
edtde6
	lda macbkg
	cmp #2
	bne edtclh
	sta prev_char
	cpx wchmac
	beq edtclb
	lda maccol
	jsr edtcok
	bmi edtclb
	tya
	tax
edtclb
	stx $d020
	stx $d021
	jmp edtdla
edtclh
	lda #0
	sta prev_char
	lda maccol
	jmp edtdln
edtde7
	cmp #10
	beq edtde8
	cmp #11
	bne edtd12
edtde8	ldx macro_tmp
edtde9	dex
	cpx wchmac
	beq edtd11
	lda macmem-1,x
	cmp #10
	beq edtd10
	cmp #11
	bne edtde9
edtd10	sta maccty
edtd11	lda maccty
	jmp edtdln
edtd12	and #$7f
	cmp #18
	bne edtd15
	ldx macro_tmp
edtd13	dex
	cpx wchmac
	beq edtd14
	lda macmem-1,x
	and #$7f
	cmp #18
	bne edtd13
	lda macmem-1,x
	sta macrvs
edtd14	lda macrvs
	and #$80
	eor #$80
	sta 199
	lda macrvs
	jmp edtdln
edtd15
	cmp #12
	beq edtd16
	cmp #LOCASE
	beq edtd16
	cmp #21
	bne edtd19
edtd16	ldx macro_tmp
edtdlc	dex
	cpx wchmac
	beq edtd18
	lda macmem-1,x
	cmp #12
	beq edtd17
	cmp #LOCASE
	beq edtd17
	cmp #21
	bne edtdlc
edtd17	sta maccas
edtd18	lda maccas
	jmp edtdln
edtd19
	cmp #CR
	bne edtdla
	lda #0
	sta 199
	lda #RVSOFF
	jsr edprrv
	dec macro_tmp
	ldx macro_tmp
	lda #0
	sta macmem,x
	sec
	rts
edtdle
	lda #20
	jsr edprrv
	lda #INST
edtdln
	jsr edprrv
edtdla
	dec macro_tmp
	ldx macro_tmp
	lda #0
	sta macmem,x
	clc
	rts
edprrv
	sta tmp02
	lda 199
	pha
	lda #0
	sta 199
	jsr cursor_off
	lda tmp02
	jsr handle_control_codes
	bcs edprr2
	jsr chrout
	jsr quote_insert_off
edprr2	pla
	sta 199
	jmp cursor_show
edtcok
	ldy #15
edtco2	cmp COLTAB,y
	beq edtco3
	dey
	bpl edtco2
edtco3	rts
