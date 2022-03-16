; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Send file or buffer to screen and/or modem
;

; bufflg
;   $80: 0: disk, 1: buffer
;   $40: 0: no delay, 1: delay
; buffl2:
;   0:   output to screen
;   !=0: output to screen and modem

dskout:
	jsr clrchn
	jsr cursor_show
	lda bufflg
	bpl @dskmo	; -> disk

; buffer
	jsr buffer_get_byte
	bit bufflg
	bvs @timdel	; -> buffer & delay
	ldx #$ff
:	dex		; short delay (about 1ms)
	bne :-
	beq @chstat	; always

; disk
@dskmo:
	jsr rs232_off
	ldx #LFN_FILE
	jsr chkin
	jsr getin	; get byte from disk
	pha
	pla		; [XXX]
@timdel:
	bit bufflg
	bvc @chstat	; -> no delay
	jsr sleep_50ms
@chstat:
	pha
	lda status
	and #$40
	jne @dskext	; -> EOF
	jsr clrchn
	jsr cursor_off
	pla
	pha
	jsr handle_control_codes
	jsr chrout
	jsr quote_insert_off
	ldx buffl2
	bne @dskmo1	; non zero: also output to modem
	pla
	jmp @chkkey	; skip

; output to modem
@dskmo1:
	jsr rs232_clear
	jsr rs232_on
	jsr rs232_clear
	pla
	ldx ascii_mode
	beq :+
	jsr petscii_to_ascii
:	jsr rs232_put

; eat echo from modem
; (this timeout failsafe makes sure the byte is received back from modem
;  before accessing disk for another byte otherwise we can have
;  all sorts of nmi related issues.... this solves everything.
;  uses the 'fake' rtc / jiffy counter function / same as xmmget...)
; [XXX this is a duplicate of rs232_get_timeout]
	lda #70		; timeout failsafe
	sta xmodel
	lda #0
	sta rtca1
	sta rtca2
	sta rtca0

:	jsr rs232_get	; get byte (and ignore)
	jcc @chkkey	; done
	jsr xmmrtc	; count up
	lda rtca1
	cmp xmodel
	bcc :-		; retry until time is up

@chkkey:
	jsr get_key
	jeq dskout	; loop

; handle keypress
	cmp #3		; STOP key
	beq @dskex2

	jsr rs232_on
	cmp #'S'
	bne @nos

; 'S'
	lda bufflg	; only in memory mode
	bpl @nos
	jsr buffer_skip_256
	ldx status	; EOI?
	bne @dskex2	; end
	jsr rs232_on
	jmp dskout	; loop
@nos:

:	jsr get_key
	beq :-

	jsr rs232_on
	jmp dskout
@dskext:
	jsr rs232_on
	pla
@dskex2:
	jsr clrchn
	jmp cursor_off

;----------------------------------------------------------------------
get_key:
	jsr clrchn
	jsr getin
	cmp #0
	rts
