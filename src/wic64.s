; CCGMS Terminal
;
; Copyright (c) 2022, Michael Steil. All rights reserved.
; This project is licensed under the BSD 2-Clause License.
;
; WiC64 Driver
;  based on "Simple Telnet Demo" source by KiWi, 2-clause BSD
;

zpcmd=$40

;----------------------------------------------------------------------
wic64_funcs:
	.word wic64_setup
	.word wic64_enable
	.word wic64_disable
	.word wic64_getxfer
	.word wic64_putxfer
	.word wic64_dropdtr

wic64_putxfer:
	rts
wic64_dropdtr:
	rts

once:
	.byte 0

;----------------------------------------------------------------------
wic64_setup:
	lda once
	beq :+
	rts
:	inc once


	; XXX for now, connect to fixed server immediately
	lda #0
	sta bytes_in_buffer
	sta bytes_in_buffer+1

	lda #<commandserver
	sta zpcmd
	lda #>commandserver
	sta zpcmd+1

	ldy #4
:	iny
	lda (zpcmd),y
	bne :-
	tya
	ldy #1
	sta (zpcmd),y

	jsr sendcommand

	jsr read_status
	bcs BADBADBAD1		  ; Could not connect
	rts

BADBADBAD1:
	inc $d021
	jmp BADBADBAD1
BADBADBAD2:
	inc $d020
	jmp BADBADBAD2
BADBADBAD3:
	inc $0400
	jmp BADBADBAD3
BADBADBAD4:
	inc $0401
	jmp BADBADBAD4

;----------------------------------------------------------------------
wic64_send:
	sta cmd_tcp_put+4
	lda #<cmd_tcp_put
	sta zpcmd
	lda #>cmd_tcp_put
	sta zpcmd+1
	jsr sendcommand
	jsr read_status
	bcs BADBADBAD2
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
;	lda (zpcmd),y
;	tax
;	lda #0
;	jsr $bdcd
;	lda #CR
;	jsr $ffd2

	ldy #1
	lda (zpcmd),y				; Länge des Kommandos holen

sendcommand2:
	tay

	lda $dd02
	ora #$04
	sta $dd02	; DDR Port A PA2 auf Ausgang
	lda #$ff	; DDR Port B Ausgang
	sta $dd03
	lda $dd00
	ora #$04	; PA2 auf HIGH = ESP im Empfangsmodus
	sta $dd00

	tya
	sta @len
	ldy #0
:	lda (zpcmd),y
	jsr write_byte
	iny
@len=*+1
	cpy #$ff
	bne :-
	rts

getanswer_data:
	lda #$00	; DDR Port B Eingang
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
	jsr read_byte	; data size HI (always 0)
	jsr read_byte	; data size LO (1: ok, 2: error)
	pha
	jsr read_byte	; '0': ok, '!': error
	pla
	cmp #1
	bne :+
	clc		; ok
	rts
:	jsr read_byte	; always 'E'
	sec		; error
	rts

write_byte:
.ifdef DEBUG
	sta @save_a
	pha
	txa
	pha
	tya
	pha
	lda #<txt_write_byte
	ldy #>txt_write_byte
	jsr $ab1e
@save_a=*+1
	ldx #$00
	lda #0
	jsr $bdcd
	lda #CR
	jsr $ffd2
	pla
	tay
	pla
	tax
	pla
.endif

	sta $dd01	; Bit 0..7: Userport Daten PB 0-7 schreiben
	lda #$10
:	bit $dd0d	; Warten auf NMI FLAG2 = Byte wurde gelesen vom ESP
	beq :-


	rts

txt_write_byte:
	.byte "WRITE: ",0
txt_read_byte:
	.byte "READ: ",0

read_byte:
	lda #$10	; Warten auf NMI FLAG2 = Byte wurde gelesen vom ESP
:	bit $dd0d
	beq :-
	lda $dd01

.ifdef DEBUG
	php
	sta @save_a
	pha
	txa
	pha
	tya
	pha
	lda #<txt_read_byte
	ldy #>txt_read_byte
	jsr $ab1e
@save_a=*+1
	ldx #$00
	lda #0
	jsr $bdcd
	lda #CR
	jsr $ffd2
	pla
	tay
	pla
	tax
	pla
	plp
.endif
	rts

cmd_tcp_get:
	.byte 'W'
	.word 4
	.byte 34

cmd_tcp_put:
	.byte 'W'
	.word 5
	.byte 35
	.byte $00	; <- will be overwritten

commandserver:
	.byte 'W'
	.word $00	; <- will be overwritten
	.byte 33
	.byte "192.168.176.104:25232",0
;	.byte "raveolution.hopto.org:64128",0


wic64_getxfer:
	php
	sei
	stx @save_x
	sty @save_y

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

	lda #<cmd_tcp_get
	sta zpcmd
	lda #>cmd_tcp_get
	sta zpcmd+1
	jsr sendcommand
	inc $d020
	jsr getanswer_data
	cmp #2
	jeq BADBADBAD2

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
	clc
	rts

wic64_enable:
	rts

wic64_disable:
	rts

bytes_in_buffer:
	.word 0
