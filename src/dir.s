; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Show disk directory
;

;----------------------------------------------------------------------
dir_echo_to_modem:
	.byte 0		; 0: f6, 1: c=f6
dirfn:
	.byte '$'

;----------------------------------------------------------------------
; Show the disk directory, optionally send it to the modem
; (the filename has to be set already)
dir:
	jsr rs232_off
	lda #LFN_DIR
	ldx device_disk
	ldy #0
	jsr setlfs
	jsr is_drive_present
	jmi dir_exit	; no
	jsr clrchn
	jsr text_color_save
	lda #CR
	jsr chrout
	jsr open
	lda #0
	sta dir_echo_to_modem
	lda SHFLAG
	cmp #SHFLAG_CBM	; c= f6
	bne :+
	lda #1
	sta dir_echo_to_modem
:	ldx #LFN_DIR
	jsr chkin
	ldy #3		; skip 4 bytes (load address and link pointer)
@loop1:	jsr getch
	dey
	bpl @loop1
	jsr getch	; blocks/line number (lo)
	sta tmp0b
	jsr getch	; blocks/line number (lo)
	ldx tmp0b
	jsr outnum	; print blocks
	lda #' '
	jsr chrout
@loop2:	jsr getch
	ldx dir_echo_to_modem
	beq @1
	cmp #0
	beq @2
	cmp #$20	; suppress special chars if we need to read back
	bcc @loop2	; the screen later [XXX not enough, also $80-$9F]
@1:	jsr chrout
	bne @loop2
@2:	jsr dir_once_per_line
	ldy #1		; skip 2 bytes next time (link pointer)
	bne @loop1

;----------------------------------------------------------------------
getch:
	jsr getin
	ldx status
	bne dir_cancel
	cmp #0
	rts
dir_cancel:
	pla
	pla
dir_exit:
	jsr clrchn
	jsr text_color_restore
	lda #LFN_DIR
	jsr chrout	; [XXX ugly: LFN matches code for CR]
	jsr close
	jmp rs232_on

;----------------------------------------------------------------------
dir_once_per_line:
	lda #CR
	jsr chrout
	jsr clrchn
	jsr getin	; keyboard
	beq @nokey

; keypress
	cmp #3		; STOP
	beq dir_cancel
; pause output until another keypress
	lda #0
	sta NDX		; clear keyboard queue
:	jsr getin	; wait for key
	beq :-
@nokey:

	ldx dir_echo_to_modem
	beq @skip

; send line to modem by reading back the printed line from the screen
	lda #CSR_UP
	jsr chrout	; position cursor over last printed line
	lda #3
	sta DFLTN	; input from screen
	ldy #0
@loop:
; eat all bytes from the modem
	lda #5
	sta timeout
	jsr rs232_get_timeout
	bcs :+		; nothing
	jmp @loop	; [XXX bcc @loop would work]
:

	jsr rs232_off
	jsr getin	; input from screen
	jsr rs232_on
	jsr rs232_put
	tya
	pha
	lda #21
	sta timeout
	jsr rs232_get_timeout; eat echo
	pla
	tay
	iny
	cpy #27		; max with (will send extra spaces at the end)
	bcc @loop
	lda #CR
	jsr rs232_put
	jsr clrchn
	lda #CR
	jsr chrout	; screen

; eat all bytes in the RS232 buffer
:	jsr rs232_get
	lda RIDBE
	cmp RIDBS	; [XXX isn't this what rs232_clear does?]
	bne :-

@skip:
	jsr clrchn
	ldx #LFN_DIR
	jmp chkin

;----------------------------------------------------------------------
is_drive_present:
	lda #0
	sta status
	lda device_disk
	jsr $ed0c	; LISTEN
	lda #$f0
	jsr $edbb	; SECND
	ldx status
	bmi :+
	jsr $f654	; UNLISTEN
	lda #0
:	rts

;----------------------------------------------------------------------
; get character with timeout
;
; (this timeout failsafe makes sure the byte is received back from modem
;  before accessing disk for another byte otherwise we can have
;  all sorts of nmi related issues.... this solves everything.
;  uses the 'fake' rtc / jiffy counter function / same as xmmget...)
rs232_get_timeout:
timeout=*+1
	lda #10		; timeout failsafe
	sta xmodel
	lda #0
	sta rtca1
	sta rtca2
	sta rtca0
@1:	jsr rs232_get
	bcs :+		; [XXX bcc @rts]
	jmp @rts
:	jsr xmmrtc
	lda rtca1
	cmp xmodel
	bcc @1
@rts:	rts
