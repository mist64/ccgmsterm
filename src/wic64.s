; CCGMS Terminal
;
; Copyright (c) 2022, Michael Steil. All rights reserved.
; This project is licensed under the BSD 2-Clause License.
;
; WiC64 Driver
;  based on "Simple Telnet Demo" source by KiWi, 2-clause BSD
;

;DEBUG	= 1

zpcmd=$40

;----------------------------------------------------------------------
wic64_funcs:
	.word wic64_setup
	.word wic64_enable
	.word wic64_disable
	.word wic64_getxfer
	.word wic64_putxfer
	.word wic64_dropdtr

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

	lda #0
	sta rhead
	sta rtail

	; set DDR PA2 to output (data direction indicator for device)
	lda $dd02
	ora #$04
	sta $dd02

	; XXX for now, connect to fixed server immediately
	lda #0
	sta bytes_in_buffer
	sta bytes_in_buffer+1

	; count string length
	ldy #0
:	lda server_address,y
	iny
	and #$ff
	bne :-
	iny
	iny
	iny
	sty commandserver+1

	lda #<commandserver
	sta zpcmd
	lda #>commandserver
	sta zpcmd+1
	lda #4
	jsr sendcommand2

	ldy #0
:	lda server_address,y
	beq :+
	jsr write_byte
	iny
	bne :-
:

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

;----------------------------------------------------------------------
wic64_putxfer:
	inc $d020
	sta cmd_tcp_put+4
	ldx #<cmd_tcp_put
	ldy #>cmd_tcp_put
	stx zpcmd
	sty zpcmd+1
	lda #5
	jsr sendcommand2

	jsr read_status
	bcs BADBADBAD2
	rts

sendcommand:
	stx zpcmd
	sty zpcmd+1

.ifdef DEBUG
	lda #<txt_sendcmd
	ldy #>txt_sendcmd
	jsr $ab1e
	ldy #3
	lda (zpcmd),y
	tax
	lda #0
	jsr $bdcd
	lda #CR
	jsr $ffd2
.endif

	ldy #1
	lda (zpcmd),y	; length of command
sendcommand2:
	sta @len

	lda #$ff	; DDR PB  input
	sta $dd03
	lda $dd00
	ora #$04	; PA2 := HIGH -> put device into receiving move
	sta $dd00

	ldy #0
:	lda (zpcmd),y
	jsr write_byte
	iny
@len=*+1
	cpy #$ff
	bne :-
	rts

get_reply_size:
	lda #$00	; DDR PB input
	sta $dd03
	lda $dd00
	and #$ff-4	; PA2 := LOW -> put device into sending mode
	sta $dd00
	jsr read_byte	; dummy byte
	jsr read_byte	; data size HI
	tax
	jmp read_byte	; data size LO

read_status:
; Any command that returns a status will send one of these strings
; * OK:    1, 0, "0"
; * ERROR: 2, 0, "!E"
; (The first two bytes being the length of the string.)
; We decide on the first character ('0' or not), which one it is.
	jsr get_reply_size
	jsr read_byte
	cmp #'0'
	bne :+
	clc
	rts
:	jsr read_byte
	sec
	rts

get_tcp_bytes:
	ldx #<cmd_tcp_get
	ldy #>cmd_tcp_get
	jsr sendcommand

	jsr get_reply_size
	sta rtail	; lo; hi is assumed 0
	ldx #0
:	jsr read_byte
	sta ribuf,x
	inx
	cpx rtail
	bne :-
	lda #0
	sta rhead

.ifdef DEBUG
	lda #<txt_length
	ldy #>txt_length
	jsr $ab1e
	lda bytes_in_buffer+1
	ldx bytes_in_buffer
	jsr $bdcd
	lda #CR
	jsr $ffd2
.endif
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
:	;inc $d021
	bit $dd0d	; wait for device to accept the byte
	beq :-
	rts

read_byte:
	lda #$10	; wait for device to have a byte ready
:	;inc $d020
	bit $dd0d
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

wic64_getxfer:
	stx @save_x
	sty @save_y

.ifdef DEBUG
	lda #<txt_bufferx
	ldy #>txt_bufferx
	jsr $ab1e
	lda bytes_in_buffer+1
	ldx bytes_in_buffer
	jsr $bdcd
	lda #CR
	jsr $ffd2
.endif

	lda rhead
	cmp rtail
	bne @skip_command

;	inc $d020
	jsr get_tcp_bytes

	lda rhead
	cmp rtail
	bne @skip_command

	lda #0		; no data
	sec
	beq @end

@skip_command:
	ldx rhead
	lda ribuf,x
	inx
	stx rhead

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

	clc
@end:
@save_x=*+1
	ldx #$ff
@save_y=*+1
	ldy #$ff
	rts

wic64_enable:
	rts

wic64_disable:
	rts

cmd_tcp_get:
	.byte 'W'
	.word 6
	.byte 34
	.word 40

cmd_tcp_put:
	.byte 'W'
	.word 5
	.byte 35
	.byte $00	; <- will be overwritten

commandserver:
	.byte 'W'
	.word $00	; <- will be overwritten
	.byte 33

server_address:
	.byte "192.168.176.104:25232",0
;	.byte "raveolution.hopto.org:64128",0
;	.byte "lu8fjh-c64.ddns.net:6400",0

txt_sendcmd:
	.byte "CMD: ",0
txt_length:
	.byte "LEN: ",0
txt_bufferx:
	.byte "BUF: ",0
txt_char:
	.byte "CHR: ",0
txt_write_byte:
	.byte "WRITE: ",0
txt_read_byte:
	.byte "READ: ",0

bytes_in_buffer:
	.word 0
ribuf_index:
	.byte 0

