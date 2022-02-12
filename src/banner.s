; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Startup message and instructions
;

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
	lda #<txt_intro1
	ldy #>txt_intro1
	jsr outstr
	lda #<txt_intro2
	ldy #>txt_intro2
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
	.byte CR,CLR,LCKCASE,WHITE,LOCASE,RVSON," ",RED
	.byte " c "
	.byte ORANGE
	.byte " c "
	.byte YELLOW
	.byte " g "
	.byte GREEN
	.byte " m "
	.byte BLUE
	.byte " s "
	.byte PURPLE
	.byte " ! "
	.byte WHITE
	.byte "     tERMINAL 2021   "
	.byte 0

txt_author:
	.byte "BY cRAIG sMITH       mODS BY aLWYZ   "
	.byte RVSOFF,DKGRAY,0

txt_intro1:
tcol1:	.byte WHITE
	.byte "  ",RVSON,"f1",RVSOFF," "
tcol2:	.byte LTRED
	.byte "uPLOAD          "
tcol9:	.byte WHITE
	.byte RVSON,"f2",RVSOFF," "
tcol10:	.byte LTRED
	.byte "sEND/rEAD FILE",CR
tcol3:	.byte WHITE
	.byte "  ",RVSON,"f3",RVSOFF," "
tcol4:	.byte YELLOW
	.byte "dOWNLOAD        "
tcol11:	.byte WHITE
	.byte RVSON,"f4",RVSOFF," "
tcol12:	.byte YELLOW
	.byte "bUFFER COMMANDS",CR
tcol5:	.byte WHITE
	.byte "  ",RVSON,"f5",RVSOFF," "
tcol6:	.byte LTGREEN
	.byte "dISK COMMAND    "
tcol13:	.byte WHITE
	.byte RVSON,"f6",RVSOFF," "
tcol14:	.byte LTGREEN
	.byte "dIRECTORY",CR
tcol7:	.byte WHITE
	.byte "  ",RVSON,"f7",RVSOFF," "
tcol8:	.byte GREEN
	.byte "dIALER/pARAMS   "
tcol15:	.byte WHITE
	.byte RVSON,"f8",RVSOFF," "
tcol16:	.byte GREEN
	.byte "sWITCH TERMS",CR,0

txt_intro2:
tcol17a	.byte BLUE
	.byte "c"
tcol26a	.byte RED
	.byte "="
tcol18	.byte WHITE
	.byte RVSON,"f1",RVSOFF," "
tcol19	.byte CYAN
	.byte "mULTI-sEND    "
tcol17b	.byte BLUE
	.byte "c"
tcol26b	.byte RED
	.byte "="
tcol20	.byte WHITE
	.byte RVSON,"f3",RVSOFF," "
tcol21	.byte CYAN
	.byte "mULTI-rECEIVE",CR
tcol17c	.byte BLUE
	.byte "c"
tcol26c	.byte RED
	.byte "="
tcol22	.byte WHITE
	.byte RVSON,"f5",RVSOFF," "
tcol23	.byte LTBLUE
	.byte "sEND DIR.     "
tcol17d	.byte BLUE
	.byte "c"
tcol26d	.byte RED
	.byte "="
tcol24	.byte WHITE
	.byte RVSON,"f7",RVSOFF," "
tcol25	.byte LTBLUE
	.byte "sCREEN TO bUFF.",CR,CR,0
;
mlswrn:	; [XXX code that uses this is commented out]
	.byte CR,WHITE,"bUFFER TOO BIG - sAVE OR cLEAR fIRST!",CR,0
;
