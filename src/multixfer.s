; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Punter Multi-Transfer
;

;----------------------------------------------------------------------
SET_PETSCII
txt_multixfer:
	.byte CR,WHITE,"Multi-transfer - Punter only.",CR,0
SET_ASCII

;----------------------------------------------------------------------
cf1_multi_send:
	jsr col80_pause
	jsr text_color_save
	lda protoc
	beq mulsav	; PROTOCOL_PUNTER
mulnop:
	lda #<txt_multixfer
	ldy #>txt_multixfer
	jsr outstr
	jmp ui_abort

mulsav:
	jsr supercpu_off
	lda #CLR
	jsr chrout

;	lda buffer_ptr+1; old references comparing buffer area and making sure theres enough
;	cmp #>mulfil	; room for punter files to be stored, but since we're now
;	bcc mulsok	; reserving #$ff space for punter, its not neccessary
;	lda buffer_ptr
;	cmp #<mulfil
;	bcc mulsok
;	lda #<mlswrn
;	ldy #>mlswrn
;	jsr outstr
;	jmp ui_abort
;mulsok

	lda #<txt_multisend_select
	ldy #>txt_multisend_select
	jsr outstr
	lda #<txt_yesnoquit
	ldy #>txt_yesnoquit
	jsr outstr
	jsr select_files_from_disk
	lda mulcnt	; some files to send?
	bne mlss1	; yes
mlss0	jmp mlssab	; nope, we are done
mlss1
	lda mulfln
	sta mulcnt	; how many files to send. decrement until none left
	beq mlss0
	lda #0
	sta mulfln
	lda #<mulfil
	sta tmpfd
	lda #>mulfil
	sta tmpfd+1
mlslop
	ldy #19
	lda (tmpfd),y
	bne mlssen
mlsinc
	lda tmpfd
	clc
	adc #20
	sta tmpfd
	lda tmpfd+1
	adc #0
	sta tmpfd+1
	lda tmpfd+1
	cmp #>endmulfil
	bcc mlslop
	jmp mulab2
mlssen
	ldy #17
mlss2	lda (tmpfd),y
	cmp #$a0
	bne mlss3
	dey
	cpy #1
	bne mlss2
	jmp mulab2
mlss3	dey
	sty max
	iny
mlss4	lda (tmpfd),y
	sta inpbuf-2,y
	dey
	cpy #1
	bne mlss4
	ldx max
	lda #','
	sta inpbuf,x
	ldy #18
	lda (tmpfd),y
	and #7
	cmp #4
	bne mlsg
	jmp mulabt
mlsg
	tay
	lda drtype,y
	sta inpbuf+1,x
mlsgo
	jsr mlshdr
	ldy #0
mlsgo1	lda inpbuf,y
	jsr rs232_put
	iny
	cpy max
	bne mlsgo1
	lda inpbuf,y
	jsr rs232_put
	lda inpbuf+1,y
	jsr rs232_put
	lda #CR
	jsr rs232_put
	jsr clrchn
	jsr uplmen	; disk setup
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq mulab2
	lda inpbuf
	bne mulab2
	inc mulfln
	lda mulfln
	cmp mulcnt
	beq mlss5
	ldx #0
	stx JIFFIES
mlstim	lda JIFFIES
	cmp #110
	bcc mlstim
	jmp mlsinc
mlss5
	jsr mlshdr
	ldx #16
	lda #4		; ctrl-d
:	jsr rs232_put
	dex
	bne :-
	lda #CR
	jsr rs232_put
mlssab	jsr clrchn
	jsr text_color_restore
	jsr gong
	jmp term_entry

;----------------------------------------------------------------------
; send 16 TABs
mlshdr:
	jsr rs232_clear
	jsr rs232_on
	ldx #16
	lda #9		; ctrl-i
:	jsr rs232_put
	dex
	bne :-
	rts

;----------------------------------------------------------------------
mulabt:
	jsr gong
mulab2
	jsr clrchn
	lda #CR
	jsr chrout
	lda #LFN_FILE
	jsr close
	lda modem_type
	cmp #MODEM_TYPE_SWIFTLINK_DE
	bmi mulab3
mulab3
	jsr rs232_on
	jmp term_entry

;----------------------------------------------------------------------
cf3_multi_receive:
	jsr col80_pause
	jsr rs232_off
	jsr text_color_save
	lda protoc
	beq mulrav	; PROTOCOL_PUNTER
	jmp mulnop
mulrav
	jsr supercpu_off
	lda #1
	sta mulcnt
	lda #CLR
	jsr chrout
	lda #<txt_multirecv
	ldy #>txt_multirecv
	jsr outstr
mrllgc
	ldx SHFLAG
	bne mrllgc
mlrnew
	jsr rs232_on
	ldy #0
	sty max
mlrwat
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq mulab2
	jsr rs232_get
	cmp #9		; ctrl-i
	bne mlrwat
mlrwt2
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq mulab2
	jsr rs232_get
	cmp #0
	beq mlrwt2
	cmp #9		; ctrl-i
	beq mlrwt2
	bne mlrfl1
mlrflp
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq mulab2
	jsr rs232_get
	cmp #0
	beq mlrflp
mlrfl1
	cmp #CR
	beq mlrfl2
	ldy max
	sta inpbuf,y
	inc max
	lda max
	cmp #18
	bcc mlrflp
mlrfl2
	ldy max
	cpy #3
	bcc mlfext
	dey
	dey
	lda inpbuf,y
	cmp #','
	bne mlfext
	sty max
	lda inpbuf
	cmp #4		; ctrl-d
	bne mlffl2
mlfext	jmp mulabt
mlffl2
	jsr dowmen
	lda inpbuf
	beq mlrnew
	bne mlfext

;----------------------------------------------------------------------
; count bad blocks
goobad:
	sta $0400+20*40+20
	cmp #'/'	; duplicate block?
	beq @1		; ignore in statistics
	cmp #'*'	; good?
	bne @2		; no
@1:	rts
@2:	cmp #'9'+1
	beq @3
	ldx #3
	bne @4
@3:	ldx #25
@4:	inc $0400+20*40+38-25,x
	lda $0400+20*40+38-25,x
	cmp #'9'+1
	bcc @1
	lda #'0'
	sta $0400+20*40+38-25,x
	dex
	bpl @4
	rts

;----------------------------------------------------------------------
SET_PETSCII
txt_multisend_select:
	.byte CR,LOCASE,WHITE,RVSON," Multi-Send ",RVSOFF," - "
	.byte "Select files:",CR,CR,0

txt_yesnoquit:
	.byte LTBLUE," Yes/No/Quit/Skip8/Done/All",CR,0

txt_multirecv:
	.byte CR,LOCASE,WHITE,RVSON," Multi-Receive ",CR,CR
	.byte CYAN,"Waiting for header...C= aborts.",CR,0
SET_ASCII

;----------------------------------------------------------------------
select_files_from_disk:
	jsr rs232_off
	lda device_disk
	jsr listen
	lda #$f0
	jsr second
	lda #'$'
	jsr ciout
	lda #'0'
	jsr ciout
	lda #':'
	jsr ciout
	lda #'*'
	jsr ciout
	jsr unlsn
	lda #<mulfil
	sta tmpfd
	lda #>mulfil
	sta tmpfd+1
	lda device_disk
	jsr talk
	lda #$60
	jsr tksa
	ldy #0
	sty mulcnt	; count entries
	sty mulfln
	sty mlsall
	sty mulskp
	ldy #31
mdrlp0
	jsr mgetch
	dey
	bpl mdrlp0
	ldy #1
mdrlp1	jsr mgetch
	dey
	bpl mdrlp1
	ldy #0
	jsr mgetch
	sta (tmpfd),y
	sta tmp07e8,y
	iny
	jsr mgetch
	sta (tmpfd),y
	sta tmp07e8,y
	lda #0
	sta tmp06
mdrlp2	jsr mgetch
	inc tmp06
	cmp #'"'
	bne mdrlp2
mdrlpf
	iny
	cpy #18
	beq drlpfn
	jsr mgetch
	cmp #'"'
	bne drlpnq
	lda #$a0
drlpnq
	sta (tmpfd),y
	sta tmp07e8,y
	jmp mdrlpf
drlpfn
	dey
	cpy #1
	beq drlptc
	lda tmp07e8,y
	cmp #' '
	bne drlptc
	lda #$a0
	sta (tmpfd),y
	sta tmp07e8,y
	bne drlpfn
drlptc
	jsr mgetch
	lda #0
	sta tmp05
	jsr mgetch
	cmp #'*'
	bne drlpsp
	lda #$80
	sta tmp05
drlpsp
	jsr mgetch
	ldx #4
drlptl
	cmp drtype,x
	beq drlptp
	dex
	bne drlptl
drlptp
	txa
	ora tmp05
	sta tmp05
	jsr mgetch
	jsr mgetch
	jsr mgetch
	cmp #'<'
	bne drlpte
	lda tmp05
	ora #$40
	sta tmp05
drlpte	lda tmp05
	ldy #18
	sta (tmpfd),y
	sta tmp07e8,y
	lda #0
	iny
	sta (tmpfd),y
dirgrb
	jsr mgetch
	bne dirgrb
	inc mulcnt
	lda mulskp
	bne mulpmt
	jsr mdrret
	bne mulnen
mulpmt	dec mulskp
	jsr drpol7
mulnen
	lda device_disk
	jsr talk
	lda #$60
	jsr tksa
	ldy #1
	jmp mdrlp1
mgetch	jsr acptr
	ldx status
	bne mdrlp3
	cmp #0
	rts
mdrlp3	pla
	pla
mdrext	lda device_disk
	jsr listen
	lda #$e0
	jsr second
	jsr untlk
	jsr unlsn
	jsr clrchn
	jsr ercopn ; possible fix for multi upload crash on up9600 - 2018 fix
	jmp rs232_on

;----------------------------------------------------------------------
mdrret:
	ldy #0
drpol0
	sty tmp02
	lda directory_format,y
	cmp #2		; ctrl-b
	bne @no1

; print blocks
	ldy #0
	lda tmp07e8,y
	tax
	iny
	lda tmp07e8,y
	jsr $bdcd	; print 16 bit decimal
	ldy tmp06
:	lda #' '
	jsr chrout
	dey
	bne :-
	beq drpol4
@no1:

	cmp #$0e	; ctrl-n
	bne @no2

; print file name
	ldy #2
:	lda tmp07e8,y
	jsr chrout
	iny
	cpy #18		; print 16 chars
	bne :-
	beq drpol4
@no2:

	cmp #$06	; ctrl-f
	bne @no3

; print file type
	ldy #18
	lda tmp07e8,y
	tay
	and #7
	tax
	tya
	and #$80
	bne @1
	lda #' '
	bne @2
@1:	lda #'*'	; splat
@2:	jsr chrout
	lda drtype,x	; file type
	jsr chrout
	lda drtyp2,x
	jsr chrout
	lda drtyp3,x
	jsr chrout
	tya
	and #$40
	bne @3
	lda #' '
	bne @4
@3:	lda #'<'	; write protect
@4:	jsr chrout
	bne drpol4
@no3:

	jsr chrout
drpol4
	ldy tmp02
	iny
	cpy #directory_format_end-directory_format
	beq :+
	jmp drpol0	; [XXX drpol0 is reachable]
:
	lda mlsall
	beq mlsf0
	lda #'Y'
	jsr chrout
	bne mlsyes

mlsf0
	lda #' '
	jsr chrout
	lda #CSR_LEFT
	jsr chrout
	jsr cursor_show
:	jsr getin
	beq :-
	and #$7f
	cmp #'A'
	bcc :-
	cmp #'['
	bcs :-
	pha
	jsr cursor_off
	pla
	pha
	jsr chrout
	lda #CSR_LEFT
	jsr chrout
	pla

	cmp #'Y'	; YES
	bne mlsf1

; yes
mlsyes	ldy #19
	inc mulfln
	lda #$80
	sta (tmpfd),y
	bne mlsnpr2
mlsf1

	cmp #'N'	; NO
	beq mlsnpr

	cmp #'A'	; ALL
	bne mlsf2

; all
	lda #1
	sta mlsall
	bne mlsyes
mlsf2

	cmp #'D'	; DONE
	bne mlsf3

; done
	lda #CR
	jsr chrout
	jmp mdrlp3
mlsf3

	cmp #'Q'	; QUIT
	bne mlsf4

; quit
	jsr mdrext
	pla
	pla
	pla
	pla
	jsr clrchn
	jmp term_entry
mlsf4

	cmp #'S'	; SKIP8
	bne mlsf0

; skip8
	lda #7
	sta mulskp
mlsnpr	lda #CR
	jsr chrout
drpol7
	lda tmpfd
	clc
	adc #0		; [XXX ???]
	sta tmpfd
	lda tmpfd+1
	adc #0
	sta tmpfd+1
	rts
mlsnpr2	lda #CR
	jsr chrout
drpol72
	lda tmpfd
	clc
	adc #20
	sta tmpfd
	lda tmpfd+1
	adc #0
	sta tmpfd+1
	rts
