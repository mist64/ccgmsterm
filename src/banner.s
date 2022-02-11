;----------------------------------------------------------------------
print_banner:
	lda #<txt_banner
	ldy #>txt_banner
	jsr outstr
	lda #' '
	jsr chrout	; [XXX fold into code below]
	ldx #2		; 2nd line start char
	;lda #163	; UPPER ONE EIGHTH BLOCK
:	jsr chrout
	dex
	bne :-
	lda #<txt_author
	ldy #>txt_author
	jsr outstr
	ldx #40
:	lda #$b7	; UPPER ONE QUARTER BLOCK
	jsr chrout
	dex
	bne :-
	rts

;----------------------------------------------------------------------
print_instr:
	lda #<txt_instructions1
	ldy #>txt_instructions1
	jsr outstr
	lda #<txt_instructions2
	ldy #>txt_instructions2
	jsr outstr

	ldx ascii_mode
	bne @2
	lda theme
	bne @1
	lda #<txt_graphics
	ldy #>txt_graphics
	bne @3
@1:	lda #<txt_graphics2
	ldy #>txt_graphics2
	bne @3
@2:	lda #<txt_ascii
	ldy #>txt_ascii
@3:	jsr outstr
	lda theme
	bne @4
	lda #<txt_terminal_ready
	ldy #>txt_terminal_ready
	jmp outstr
@4:	lda #<txt_term_activated
	ldy #>txt_term_activated
	jmp outstr

;----------------------------------------------------------------------
txt_banner:
	.byte 13,$93,8,5,14,18,32,28,32
	.byte "c"
	.byte 32,129,32
	.byte "c"
	.byte 32,158,32
	.byte "g"
	.byte 32,30,32
	.byte "m"
	.byte 32,31,32
	.byte "s"
	.byte 32,156
	.byte " ! "
	.byte 5,32
	.byte "    tERMINAL 2021   "
	.byte 00
txt_author:
	.byte "BY cRAIG sMITH       mODS BY aLWYZ   "
	.byte 146,151,00
;
txt_instructions1:
	.byte 5,'  ',18,'f1',146,32,150,'uPLOAD          '
	.byte 5,18,'f2',146,32,150,'sEND/rEAD FILE',13
	.byte 5,'  ',18,'f3',146,32,158,'dOWNLOAD        '
	.byte 5,18,'f4',146,32,158,'bUFFER COMMANDS',13
	.byte 5,'  ',18,'f5',146,32,153,'dISK COMMAND    '
	.byte 5,18,'f6',146,32,153,'dIRECTORY',13
	.byte 5,'  ',18,'f7',146,32,30,'dIALER/pARAMS   '
	.byte 5,18,'f8',146,32,30,'sWITCH TERMS',13,0
txt_instructions2:
	.byte 31,'c',28,'=',5,18,'f1',146,32,159,'mULTI-sEND    '
	.byte 31,'c',28,'=',5,18,'f3',146,32,159,'mULTI-rECEIVE',13
	.byte 31,'c',28,'=',5,18,'f5',146,32,154,'sEND DIR.     '
	.byte 31,'c',28,'=',5,18,'f7',146,32,154,'sCREEN TO bUFF.',13,13,0
;
mlswrn:	; [XXX code that uses this is commented out]
	.byte 13,5,'bUFFER TOO BIG - sAVE OR cLEAR fIRST!',13,0
;
