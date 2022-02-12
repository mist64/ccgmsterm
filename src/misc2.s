; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Miscellaneous 2
;

;----------------------------------------------------------------------
txt_newpunter:
	.byte CR,CR,WHITE,"new pUNTER ",0
txt_up:
	.byte "uP",0
txt_down:
	.byte "dOWN",0
txt_load:
	.byte "LOAD.",CR,0
txt_enter_filename:
	.byte "eNTER fILENAME: ",0
txt_yellow:
	.byte CR,YELLOW,"  ",0
txt_loading:
	.byte "LOADING: ",CYAN,0
txt_press_c_to_abort:
	.byte CR,WHITE,"  (pRESS c= TO ABORT.)",CR,CR,0
txt_aborted:
	.byte "aBORTED.",CR,0
txt_good_bad_blocks:
	.byte LTGREEN," ","gOOD bLOCKS: ",WHITE,"000",WHITE,"   -   "
	.byte LTGREEN,"bAD bLOCKS: ",WHITE,"000",CR,0
txt_graphics:
	.byte LTGREEN,"gRAPHICS",0
txt_graphics2:
	.byte RVSON,BLUE,"c",LTBLUE,"/",CYAN,"g",RVSOFF,YELLOW,0
txt_ascii:
	.byte CYAN,"aNSCII",0
txt_terminal_ready:
	.byte " tERMINAL rEADY.",LTGRAY,CR,CR,0
txt_term_activated:
	.byte " tERM aCTIVATED.",LTGRAY,CR,CR,0
txt_disconnecting:
	.byte CR,CR,WHITE,"dISCONNECTING...",LTGRAY,CR,CR,0

;----------------------------------------------------------------------
drtype:	.byte "DSPUR"
drtyp2:	.byte "EERSE"
drtyp3:	.byte "LQGSL"

;----------------------------------------------------------------------
directory_format:
	.byte YELLOW
	.byte $02	; ctrl-b: blocks
	.byte 157
	.byte 157
	.byte WHITE
	.byte $06	; ctrl-f: file type
	.byte " "
	.byte CYAN
	.byte $0e	; ctrl-n: file name
	.byte LTGREEN
	.byte " "
	.byte 63
	.byte " "
	.byte 0
directory_format_end:

;----------------------------------------------------------------------
aciaemu_filename:
	.byte $08	; 2400 baud
	.byte $00

	.byte $51,$0d	; [XXX unused]

aciaemu_filename_len:
	.byte 2		; [XXX only read; should be constant]

filename_i0:
	.byte "I0"

; device number of the (first) disk drive
device_disk:
	.byte 8

; is a drive present in the system
drive_present:
	.byte 1

config_file_loaded:
	.byte 0

prev_char:
	.byte 0

newbuf	.byte <endprg,>endprg

; System Timing
;  0: NTSC
;  1: PAL
is_pal_system:
	.byte 0

; SuperCPU detected
;  0: no SuperCPU
;  1: SuperCPU detected
;  2: SuperCPU detected, message already printed (don't print again)
supercpu:
	.byte 0

txt_supercpu_enabled:
	.byte "sUPERcpu eNABLED!",CR,CR,0

nicktemp:
	.byte 0		; [XXX unused]

drivetemp:
	.byte 0

;----------------------------------------------------------------------
; pre-calculate CRC16 tables for XMODEM/CRC
crctable:
	ldx 	#0
	txa
:	sta 	crclo,x
	sta 	crchi,x
	inx
	bne	:-
	ldx	#0
@1:	txa
	eor	crchi,x
	sta	crchi,x
	ldy	#8
@2:	asl	crclo,x
	rol	crchi,x
	bcc	@3
	lda	crchi,x
	eor	#$10
	sta	crchi,x
	lda	crclo,x
	eor	#$21
	sta	crclo,x
@3:	dey
	bne	@2
	inx
	bne	@1
	rts

;----------------------------------------------------------------------
; SuperCPU
supercpu_on:
	lda supercpu
	beq scpuout
	lda #1
	sta $d07b
scpuout	rts

supercpu_off:
	lda supercpu
	beq scpuout
	lda #1
	sta $d07a
	rts

;----------------------------------------------------------------------
; Clear RS232 buffer
clear232:
	pha
	lda #0
	sta rtail
	sta rhead
	sta rfree
	pla
	rts

;----------------------------------------------------------------------
; [XXX this should be closer to the PUNTER code]
puntdelay:
; you got a better way to do this? have at it!
	pha
	txa
	pha
	tya
	pha
	ldx #0
	ldy #0
:	inx
	bne :-
	iny
	bne :-
	pla
	tay
	pla
	tax
	pla
	rts
