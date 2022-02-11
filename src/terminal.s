; CCGMS Main Terminal Code

; enter here on program start
term_entry_first:
	jsr enablemodem
	jsr bell
	jsr themeroutine

; enter here to print banner again
term_entry:
	jsr print_banner; title screen/CCGMS!
	jsr print_instr	; display commands f1 etc to terminal ready

; enter here to just return into terminal mode
term_mainloop:
	lda supercpu
	beq @loop1
	cmp #2		; already printed once
	beq :+
	lda #<txt_supercpu_enabled
	ldy #>txt_supercpu_enabled
	jsr outstr
	lda #2
	sta supercpu
:	; supercpu = turn on 20mhz mode - for after all file transfer situations.
	; already on? turn on again. no biggie. save code.
	jsr supercpu_on

@loop1:
; print tempbuf, unless empty
	lda bustemp
	beq @skip
	ldy #1
:	lda tempbuf,y
	jsr chrout
	iny
	cpy bustemp
	bne :-
	ldy #0
	sty bustemp
@skip:

	ldx #$ff
	txs

	; set keyboard matrix routine
	lda #<$eb48	; [XXX this is the KERNAL default; it is never changed]
	sta KEYLOG
	lda #>$eb48
	sta KEYLOG+1

	jsr clrchn
	jsr cursor_show

;----------------------------------------------------------------------
; modem output
@loop2:
	lda buffer_ptr
	sta newbuf
	lda buffer_ptr+1
	sta newbuf+1

	jsr clrchn
	jsr getin	; get character from keyboard
	cmp #0
	jeq @input_loop	; skip output code

; cbm-ctrl-f: reset/init user port RS-232
	cmp #6		; ctrl-f
	bne @no1
	ldx SHFLAG
	cpx #SHFLAG_CBM | SHFLAG_CTRL
	bne @no1
	; cia2ddrb and cia2pb need to be here
	; for user port modem to function
	ldx #16
	stx cia2ddrb
	ldx #0
	stx cia2pb
	jmp @loop2
@no1
;	cmp #UNDERLINE
;	bne @no2
;	ldx SHFLAG	; shift <- toggles
;	beq @no4	; n/d cursor
;	cpx #SHFLAG_SHIFT
;	beq :+
;	lda allcap
;	eor #1
;	sta allcap
;	jmp @loop2
;:	jmp crsrtg
;@no2:

; shift-ctrl-[1..4]: swap screen
	ldx SHFLAG
	cpx #SHFLAG_SHIFT | SHFLAG_CTRL
	bcc @no3
	ldx #3
:	cmp COLTAB,x	; PETSCII codes for ctrl-[1..4]
	beq :+
	dex
	bpl :-
	jmp @input_loop
:	jmp swap_screen	; x holds pos 0-3
@no3:

; shift-stop: hang up
	cmp #$83
	bne @no4
	jmp hangup
@no4:

; f1..f8: functions
	cmp #133	; <= F1
	bcc @no5
	cmp #140+1	; > F8
	bcs @no5
	ldx #0
	stx $d020
	stx $d021
	pha
	jsr cursor_off
	pla
	sec
	sbc #133	; F1
	sta tmp03
	asl tmp03
	clc
	adc tmp03
	sta @bbcarg
	clc
@bbcarg=*+1
	bcc *+2
	jmp handle_f1_upload
	jmp handle_f3_download
	jmp handle_f5_diskcommand
	jmp handle_f7_config
	jmp handle_f2_send_read
	jmp handle_f4_buffer
	jmp handle_f6_directory
	jmp handle_f8_switch_term
@no5:

;	ldx allcap
;	beq @upplow
;	ldx $d018
;	cpx #23
;	bne @upplow
;	cmp #$41
;	bcc @upplow
;	cmp #$5b  ;'z'+1
;	bcs @upplow
;	ora #$80
;@upplow:

; ASCII conversion
	sta tmp03
	ldx ascii_mode
	beq :+
	jsr petscii_to_ascii
	bne :+
@loop2b:
	jmp @loop2
:

; send to modem
	pha
	ldx #LFN_MODEM
	jsr chkout
	pla
	jsr chrout

; convert back to PETSCII
	ldx ascii_mode
	beq :+
	jsr ascii_to_petscii
	sta tmp03
	jeq @loop2
:

; half-duplex
	ldx half_duplex
	beq @nohd
	jsr clrchn
	lda tmp03	; char
	ldx ascii_mode
	beq :+
	cmp #UNDERLINE	; [XXX no-op]
	bne :+			; [XXX no-op]
	lda #UNDERLINE
	sta tmp03	; _ in ascii/half dup
:	jmp @bufchk	; skip modem input
@nohd:

;----------------------------------------------------------------------
; modem input
@input_loop:
	jsr clrchn

; macro printing
	ldx SHFLAG
	cpx #SHFLAG_CTRL; ctrl pressed
	bne :+
	ldx LSTX	; last keyboard scancode
	cpx #3		; 3-6 are F7/F1/F3/F5
	bcc :+		; [XXX this branches into code that checks X
	cpx #7		; [XXX thinking it's SHFLAG; it works by accident]
	bcs :+
	lda #0
	sta macmdm
	jsr print_macro
	jmp @loop1
:

; charset switching
	cpx #SHFLAG_SHIFT | SHFLAG_CBM
	bne :+
	ldx MODE	; charset switching allowed?
	bpl :+		; no
	ldx #$17
	stx $d018	; set lowercase charset
:

; modem input
	ldx #LFN_MODEM
	jsr chkin	; get the byte from the modem
	jsr getin
	cmp #0
	beq @loop2b	; = @loop2
	ldx status
	bne @loop2b	; = @loop2
	pha
	jsr clrchn
	pla

; ASCII conversion
	ldx ascii_mode
	beq :+
	jsr ascii_to_petscii
	beq @input_loop
:	cmp #DEL
	bne @bufchk	; [XXX no-op]
	lda #$14	; [XXX no-op; was: $5F in Craig Smith source]
@bufchk:
	jsr buffer_put
	jmp contn

; [XXX this code is at a very awkward location, could be integrated better]
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; store modem byte into buffer
buffer_put:
	; skip if closed
	ldx buffer_open
	beq @4
	; skip if full
	ldx buffer_ptr
	cpx bufend
	bne @1
	ldx buffer_ptr+1
	cpx bufend+1
	beq @4

@1:	ldy reu_enabled
	beq @2
	jsr reuwrite
	jmp @3

@2:	ldy #0
	sta (buffer_ptr),y
@3:	inc buffer_ptr
	bne @4
	inc buffer_ptr+1
@4:	rts
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

contn:
	jsr handle_control_codes
	bcc contn2
	jmp term_mainloop

; [XXX this code is at a very awkward location, could be integrated better]
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; handle control codes sent from the BBS
handle_control_codes:
	cmp #$0a	; ctrl-j: cursor on
	beq @1
	cmp #$0b	; ctrl-k: cursor off
	bne @2

@1:
	ldx ascii_mode
	bne @2
	pha
	jsr cursor_off
	pla
	and #1		; form to ch flag
	eor #1
	sta cursor_flag
	sec
	rts

@2:
	cmp #$0e	; ctrl-n: reset background to black
	bne @3

	ldx #0
	stx $d020
	stx $d021

@3:
	cmp #$07	; ctrl-g: bell sound from bbs side
	bne @4

	jsr bell

@4:
	cmp #$16	; ctrl-v: end of file transfer or boomy sound
	bne @5

	jsr gong

@5:
;	cmp #$15	; ctrl-u: uppercase from bbs side
;	bne @6

;	ldx #$15
;	stx $d018
;	bne ctrlex

;@6:
;	cmp #$0c	; ctrl-l: lowercase from bbs side
;	bne @7

;	ldx #$17
;	stx $d018
;	bne ctrlex

;@7:
;	cmp #$5f	; false del
;	bne @8		; (buff and 1/2 duplx)

;	lda #DEL
;	bne ctrlex

;@8:
	ldx prev_char
	cpx #$02	; ctrl-b: set background color
	bne @9

	ldx #15
:	cmp COLTAB,x	; check ctrl+[1-8], cbm+[1-8]
	beq :+
	dex
	bpl :-
	bmi @9
:	stx $d020
	stx $d021
	lda #$10	; ctrl-p: non printable
@9:
	sta prev_char
	clc
	rts
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

contn2:
	pha
	jsr cursor_off
	pla
	jsr chrout	; print input byte to screen
	jsr quote_insert_off; kill modes the char might have enabled
	jmp term_mainloop

