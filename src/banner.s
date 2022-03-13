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
	lda #<txt_banner1
	ldy #>txt_banner1
	jsr outstr
	lda #<txt_banner2
	ldy #>txt_banner2
	jsr outstr

	ldx ascii_mode
	bne @2
	lda #<txt_graphics
	ldy #>txt_graphics
	bne @3
@2:	lda #<txt_ascii
	ldy #>txt_ascii
@3:	jsr outstr
	lda #<txt_terminal_ready
	ldy #>txt_terminal_ready
	jmp outstr

;----------------------------------------------------------------------
SET_PETSCII
txt_banner:
	.byte CR,CLR,LCKCASE,WHITE,LOCASE,RVSON," ",RED
	.byte " C "
	.byte ORANGE
	.byte " C "
	.byte YELLOW
	.byte " G "
	.byte GREEN
	.byte " M "
	.byte BLUE
	.byte " S "
	.byte PURPLE
	.byte " ! "
	.byte WHITE
	.byte " Terminal FUTURE ",VERSION," "
	.byte 0

txt_author:
	.byte "  by Craig Smith, Alwyz, Michael Steil  "
	.byte RVSOFF,DKGRAY,0

txt_banner1:
tcol1:	.byte WHITE
	.byte "  ",RVSON,"F1",RVSOFF," "
tcol2:	.byte LTRED
	.byte "Upload          "
tcol9:	.byte WHITE
	.byte RVSON,"F2",RVSOFF," "
tcol10:	.byte LTRED
	.byte "Send/Read file",CR
tcol3:	.byte WHITE
	.byte "  ",RVSON,"F3",RVSOFF," "
tcol4:	.byte YELLOW
	.byte "Download        "
tcol11:	.byte WHITE
	.byte RVSON,"F4",RVSOFF," "
tcol12:	.byte YELLOW
	.byte "Buffer commands",CR
tcol5:	.byte WHITE
	.byte "  ",RVSON,"F5",RVSOFF," "
tcol6:	.byte LTGREEN
	.byte "Disk command    "
tcol13:	.byte WHITE
	.byte RVSON,"F6",RVSOFF," "
tcol14:	.byte LTGREEN
	.byte "Directory",CR
tcol7:	.byte WHITE
	.byte "  ",RVSON,"F7",RVSOFF," "
tcol8:	.byte GREEN
	.byte "Dialer/Params   "
tcol15:	.byte WHITE
	.byte RVSON,"F8",RVSOFF," "
tcol16:	.byte GREEN
	.byte "Switch terms",CR,0

txt_banner2:
tcol17a	.byte BLUE
	.byte "C"
tcol26a	.byte RED
	.byte "="
tcol18	.byte WHITE
	.byte RVSON,"F1",RVSOFF," "
tcol19	.byte CYAN
	.byte "Multi-Send    "
tcol17b	.byte BLUE
	.byte "C"
tcol26b	.byte RED
	.byte "="
tcol20	.byte WHITE
	.byte RVSON,"F3",RVSOFF," "
tcol21	.byte CYAN
	.byte "Multi-Receive",CR
tcol17c	.byte BLUE
	.byte "C"
tcol26c	.byte RED
	.byte "="
tcol22	.byte WHITE
	.byte RVSON,"F5",RVSOFF," "
tcol23	.byte LTBLUE
	.byte "Send dir.     "
tcol17d	.byte BLUE
	.byte "C"
tcol26d	.byte RED
	.byte "="
tcol24	.byte WHITE
	.byte RVSON,"F7",RVSOFF," "
tcol25	.byte LTBLUE
	.byte "Screen to Buff.",CR,CR,0

mlswrn:	; [XXX code that uses this is commented out]
	.byte CR,WHITE,"Buffer too big - Save or Clear First!",CR,0
SET_ASCII
