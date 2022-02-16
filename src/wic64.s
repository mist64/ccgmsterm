;
; C64 to NODEMCU V1 - Simple Telnet Demo
;
; This part of WiC64 was written 2020-2022 by KiWi
;
; 2-clause BSD

zp=$40

wic64_connect:
	lda #0
	sta bytes_in_buffer
	sta bytes_in_buffer+1

	lda #<commandserver
	sta zp
	lda #>commandserver
	sta zp+1
	jsr fixsting
	jsr sendcommand

	jsr read_status
	bcs BADBADBAD		  ; Could not connect
	rts

BADBADBAD:
	inc $d021
	jmp BADBADBAD

wic64_send:
	sta commandputbyte+4
	lda #<commandputbyte
	sta zp
	lda #>commandputbyte
	sta zp+1
	jsr sendcommand
	jsr read_status
	bcs BADBADBAD
	rts




fixsting:
	ldy #4
countstring:
	iny
	lda (zp),y
	bne countstring
	tya
	ldy #1
	sta (zp),y
	rts

txt_sendcmd:
	.byte "CMD: ",0
txt_length:
	.byte "LEN: ",0
txt_bufferx:
	.byte "BUF: ",0
txt_char:
	.byte "CHR: ",0

sendcommand:
;	lda #<txt_sendcmd
;	ldy #>txt_sendcmd
;	jsr $ab1e
;	ldy #3
;	lda (zp),y
;	tax
;	lda #0
;	jsr $bdcd
;	lda #CR
;	jsr $ffd2

	lda $dd02
	ora #$04
	sta $dd02				; Datenrichtung Port A PA2 auf Ausgang
	lda #$ff				; Datenrichtung Port B Ausgang
	sta $dd03
	lda $dd00
	ora #$04				; PA2 auf HIGH = ESP im Empfangsmodus
	sta $dd00

	ldy #$01
	lda (zp),y				; Länge des Kommandos holen
	sec
	sbc #$01
	sta stringexit		; Als Exit speichern

	ldy #$ff
string_next:
	iny
	lda (zp),y
	jsr write_byte
stringexit=*+1
	cpy #$00				; Selbstmodifizierender Code - Hier wird die länge des Kommandos eingetragen -> Siehe Ende von send_string
	bne string_next
	rts

getanswer_data:
	lda #$00	; Datenrichtung Port B Eingang
	sta $dd03
	lda $dd00
	and #$ff-4	; PA2 auf LOW = ESP im Sendemodus
	sta $dd00
	jsr read_byte	; dummy byte
	jsr read_byte	; data size HI
	sta bytes_in_buffer+1
	sta $0401
	jsr read_byte	; data size LO
	sta bytes_in_buffer
	sta $0400

	lda #<txt_length
;	ldy #>txt_length
;	jsr $ab1e
;	lda bytes_in_buffer+1
;	ldx bytes_in_buffer
;	jsr $bdcd
;	lda #CR
;	jsr $ffd2

;:	inc $d020
;	jmp :-

	rts




read_status:
	lda #$00
	sta $dd03
	lda $dd00
	and #251
	sta $dd00
	jsr read_byte	; dummy
	jsr read_byte	; data size HI
	jsr read_byte	; data size LO
	pha
	jsr read_byte	; '0' or '!'
	pla
	cmp #1
	bne :+
	clc		; ok
	rts
:	jsr read_byte	; 'E'
	sec		; error
	rts



write_byte:
	sta $dd01		; Bit 0..7: Userport Daten PB 0-7 schreiben
:	lda $dd0d
	and #$10		; Warten auf NMI FLAG2 = Byte wurde gelesen vom ESP
	beq :-
	rts

read_byte:
	lda $dd0d
	and #$10		; Warten auf NMI FLAG2 = Byte wurde gelesen vom ESP
	beq read_byte
	lda $dd01
	rts

commandget:
	.byte 'W',$04,$00,34
commandputbyte:
	.byte 'W',$05,$00,35,$00
commandserver:
	.byte 'W',$00,$00,33
;	.byte "192.168.177.171:25232",0
	.byte "raveolution.hopto.org:64128",0


wic64_getxfer:
	php
	sei
	stx @save_x
	sty @save_y

	lda #0
	sta status

;	lda #<txt_bufferx
;	ldy #>txt_bufferx
;	jsr $ab1e
;	lda bytes_in_buffer+1
;	ldx bytes_in_buffer
;	jsr $bdcd
;	lda #CR
;	jsr $ffd2

	lda bytes_in_buffer
	ora bytes_in_buffer+1
	bne @skip_command

	lda #<commandget
	sta zp
	lda #>commandget
	sta zp+1
	jsr sendcommand
	inc $d020
	jsr getanswer_data
	cmp #2
	jeq BADBADBAD

	lda bytes_in_buffer
	ora bytes_in_buffer+1
	bne @skip_command

	lda #0		; no data
	beq @end

@skip_command:
	lda bytes_in_buffer
	bne :+
	dec bytes_in_buffer+1
:	dec bytes_in_buffer
	jsr read_byte

;	pha
;	lda #<txt_char
;	ldy #>txt_char
;	jsr $ab1e
;	pla
;	pha
;	tax
;	lda #0
;	jsr $bdcd
;	pla

@end:
@save_x=*+1
	ldx #$ff
@save_y=*+1
	ldy #$ff
	plp
	rts

wic64_setup:
	lda #<wic64_outup
	ldx #>wic64_outup
	sta $0326
	stx $0327
	lda #<wic64_inup
	ldx #>wic64_inup
	sta $032a
	stx $032b
wic64_enable:
	rts

wic64_disable:
	rts



;----------------------------------------------------------------------
; new BSOUT
wic64_outup:
	pha		;dupliciaton of original kernal routines
	lda DFLTO	;test dfault output device for
	cmp #2		;screen, and...
	beq :+
	pla		;if so, go back to original rom routines
	jmp oldout
:

	rts

wic64_putxfer:
	rts
wic64_dropdtr:
	rts

;----------------------------------------------------------------------
; new GETIN
wic64_inup:
	lda DFLTN
	cmp #2		; see if default input is modem
	beq :+
	jmp ogetin	; nope, go back to original

:
;	inc $d021
	jsr wic64_getxfer
	clc
	rts

bytes_in_buffer:
	.word 0
