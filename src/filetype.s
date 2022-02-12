; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; File type prompt
;

;----------------------------------------------------------------------
txt_prg_seq_usr:
	.byte HILITE,"PRG, ",HILITE,"SEQ, or ",HILITE,"USR? ",0

;----------------------------------------------------------------------
; prompt user about CBM DOS file type
prompt_file_type:
	lda #<txt_prg_seq_usr
	ldy #>txt_prg_seq_usr
	jsr outstr
	jsr invert_csr_char

@1:	jsr getin
	beq @1
	and #$7f
	ldx #3
@2:	cmp upltyp,x
	beq @3
	dex
	bne @2
	beq @1

@3:	stx filetype
	rts
