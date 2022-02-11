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
	.byte CR,CLR,8,WHITE,14,18,32,RED,32
	.byte "c"
	.byte 32,ORANGE,32
	.byte "c"
	.byte 32,YELLOW,32
	.byte "g"
	.byte 32,GREEN,32
	.byte "m"
	.byte 32,BLUE,32
	.byte "s"
	.byte 32,PURPLE
	.byte " ! "
	.byte WHITE,32
	.byte "    tERMINAL 2021   "
	.byte 00
txt_author:
	.byte "BY cRAIG sMITH       mODS BY aLWYZ   "
	.byte 146,DKGRAY,00
;
txt_instructions1:
	.byte WHITE,'  ',18,'f1',146,32,LTRED,'uPLOAD          '
	.byte WHITE,18,'f2',146,32,LTRED,'sEND/rEAD FILE',CR
	.byte WHITE,'  ',18,'f3',146,32,YELLOW,'dOWNLOAD        '
	.byte WHITE,18,'f4',146,32,YELLOW,'bUFFER COMMANDS',CR
	.byte WHITE,'  ',18,'f5',146,32,LTGREEN,'dISK COMMAND    '
	.byte WHITE,18,'f6',146,32,LTGREEN,'dIRECTORY',CR
	.byte WHITE,'  ',18,'f7',146,32,GREEN,'dIALER/pARAMS   '
	.byte WHITE,18,'f8',146,32,GREEN,'sWITCH TERMS',CR,0
txt_instructions2:
	.byte BLUE,'c',RED,'=',WHITE,18,'f1',146,32,CYAN,'mULTI-sEND    '
	.byte BLUE,'c',RED,'=',WHITE,18,'f3',146,32,CYAN,'mULTI-rECEIVE',CR
	.byte BLUE,'c',RED,'=',WHITE,18,'f5',146,32,LTBLUE,'sEND DIR.     '
	.byte BLUE,'c',RED,'=',WHITE,18,'f7',146,32,LTBLUE,'sCREEN TO bUFF.',CR,CR,0
;
mlswrn:	; [XXX code that uses this is commented out]
	.byte CR,WHITE,'bUFFER TOO BIG - sAVE OR cLEAR fIRST!',CR,0
;
