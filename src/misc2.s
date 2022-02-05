;----------------------------------------------------------------------
txt_newpunter:
	.byte 13,13,5,'new pUNTER ',00
txt_up:
	.byte 'uP',00
txt_down:
	.byte 'dOWN',00
txt_load:
	.byte 'LOAD.',13,00
txt_enter_filename:
	.byte 'eNTER fILENAME: ',00
txt_yellow:
	.byte 13,158,32,32,0 ; CR, YELLOW, SP, SP
txt_loading:
	.byte 'LOADING: ',159,0
txt_press_c_to_abort:
	.byte 13,5,'  (pRESS c= TO ABORT.)',13,13,00
txt_aborted:
	.byte 'aBORTED.',13,00
txt_good_bad_blocks:
	.byte 153,32,'gOOD bLOCKS: ',5,'000',5,'   -   '
	.byte 153,'bAD bLOCKS: ',5,'000',13,0
txt_graphics:
	.byte 153,'gRAPHICS',00
txt_graphics2:
	.byte 18,31,'c',154,'/',159,'g',146,158,0
txt_ascii:
	.byte 159,'aNSCII',00
txt_terminal_ready:
	.byte ' tERMINAL rEADY.',155,13,13,00
txt_term_activated:
	.byte ' tERM aCTIVATED.',155,13,13,00
txt_disconnecting:
	.byte 13,13,5,'dISCONNECTING...',155,13,13,0

;----------------------------------------------------------------------
drtype	.byte 'D','S','P','U','R'
drtyp2	.byte 'E','E','R','S','E'
drtyp3	.byte 'L','Q','G','S','L'

;----------------------------------------------------------------------
drform	.byte 158,2,157,157,5,6,32,159,14,153,32,63,32,0

;----------------------------------------------------------------------
proto	.byte $08   ;start with
proto1	.byte $00   ;2400 baud setng
bdoutl	.byte $51
bdouth	.byte $0d
protoe	.byte $02 ;length of proto
dreset	.byte "I0"
diskdv	.byte $08
drivepresent
	.byte $01
alrlod	.byte 0

xlastch	.byte 0

newbuf	.byte <endprg,>endprg
ntsc	.byte $00   ;pal=1 - ntsc =0
supercpubyte
	.byte $00

supertext
	.byte "sUPERcpu eNABLED!",13,13,0

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
turnonscpu
	lda supercpubyte
	beq scpuout
	lda #$01
	sta $d07b

scpuout	rts

turnoffscpu
	lda supercpubyte
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
