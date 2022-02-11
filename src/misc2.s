;----------------------------------------------------------------------
txt_newpunter:
	.byte CR,CR,WHITE,'new pUNTER ',00
txt_up:
	.byte 'uP',00
txt_down:
	.byte 'dOWN',00
txt_load:
	.byte 'LOAD.',CR,00
txt_enter_filename:
	.byte 'eNTER fILENAME: ',00
txt_yellow:
	.byte CR,YELLOW,' ',' ',0
txt_loading:
	.byte 'LOADING: ',CYAN,0
txt_press_c_to_abort:
	.byte CR,WHITE,'  (pRESS c= TO ABORT.)',CR,CR,00
txt_aborted:
	.byte 'aBORTED.',CR,00
txt_good_bad_blocks:
	.byte LTGREEN,' ','gOOD bLOCKS: ',WHITE,'000',WHITE,'   -   '
	.byte LTGREEN,'bAD bLOCKS: ',WHITE,'000',CR,0
txt_graphics:
	.byte LTGREEN,'gRAPHICS',00
txt_graphics2:
	.byte 18,BLUE,'c',LTBLUE,'/',CYAN,'g',146,YELLOW,0
txt_ascii:
	.byte CYAN,'aNSCII',00
txt_terminal_ready:
	.byte ' tERMINAL rEADY.',LTGRAY,CR,CR,00
txt_term_activated:
	.byte ' tERM aCTIVATED.',LTGRAY,CR,CR,00
txt_disconnecting:
	.byte CR,CR,WHITE,'dISCONNECTING...',LTGRAY,CR,CR,0

;----------------------------------------------------------------------
drtype	.byte 'D','S','P','U','R'
drtyp2	.byte 'E','E','R','S','E'
drtyp3	.byte 'L','Q','G','S','L'

;----------------------------------------------------------------------
drform	.byte YELLOW,2,157,157,WHITE,6,' ',CYAN,14,LTGREEN,' ',63,' ',0

;----------------------------------------------------------------------
proto	.byte $08   ;start with
proto1	.byte $00   ;2400 baud setng
bdoutl	.byte $51
bdouth	.byte $0d
protoe	.byte $02 ;length of proto
dreset	.byte "I0"

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

nicktemp
	.byte $00
drivetemp
	.byte $00

;----------------------------------------------------------------------
;MAKECRCTABLE
crctable
	ldx 	#$00
	txa
zeroloop
	sta 	crclo,x
	sta 	crchi,x
	inx
	bne	zeroloop
	ldx	#$00
fetch	txa
	eor	crchi,x
	sta	crchi,x
	ldy	#$08
fetch1	asl	crclo,x
	rol	crchi,x
	bcc	fetch2
	lda	crchi,x
	eor	#$10
	sta	crchi,x
	lda	crclo,x
	eor	#$21
	sta	crclo,x
fetch2	dey
	bne	fetch1
	inx
	bne	fetch
	rts

;----------------------------------------------------------------------
;SuperCPU ROUTINES
supercpu_on:
	lda supercpu
	beq scpuout
	lda #1
	sta $d07b
scpuout	rts

supercpu_off:
	lda supercpu
	beq scpuout
	lda #$01
	sta $d07a
	rts

;----------------------------------------------------------------------
;CLEAR RS232 BUFFER POINTERS
clear232
	pha
	lda #$00
	sta rtail
	sta rhead
	sta rfree
	pla
	rts

;----------------------------------------------------------------------
; [XXX this should be closer to the PUNTER code]
puntdelay; you got a better way to do this? have at it!
	pha
	txa
	pha
	tya
	pha
	ldx #$00
	ldy #$00
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
