; CCGMS Terminal
;
; Copyright (c) 2022, Michael Steil. All rights reserved.
; This project is licensed under the BSD 2-Clause License.
;
; WiC64 Driver
;  based on "Simple Telnet Demo" source by KiWi, 2-clause BSD
;

BYTES_PER_TCP_GET	= 128	; max 255

;----------------------------------------------------------------------
wic64_funcs:
	.word wic64_setup
	.word wic64_enable
	.word wic64_disable
	.word wic64_getxfer
	.word wic64_putxfer
	.word wic64_dropdtr

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

	; count string length
	ldy #0
:	lda server_address,y
	iny
	and #$ff
	bne :-
	iny
	iny
	iny
	sty cmd_tcp_connect_len

	lda #<cmd_tcp_connect
	sta zpcmd
	lda #>cmd_tcp_connect
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
wic64_getxfer:
	stx @save_x
	sty @save_y

	; is there data in the buffer?
	lda rhead
	cmp rtail
	bne @skip

	; ask for more data
	ldx #<cmd_tcp_get
	ldy #>cmd_tcp_get
	jsr sendcommand
	lda #0
	sta rhead
	jsr get_reply_size
	sta rtail	; length lo (hi is assumed 0)
	sec
	beq @end	; no data, return with C=1
	ldx #0
:	jsr read_byte	; read data into buffer
	sta ribuf,x
	inx
	cpx rtail
	bne :-

@skip:
	ldx rhead
	lda ribuf,x	; get byte from buffer
	inx
	stx rhead

	clc
@end:
@save_x=*+1
	ldx #$ff
@save_y=*+1
	ldy #$ff
	rts

;----------------------------------------------------------------------
wic64_putxfer:
	stx @save_x
	sty @save_y
	sta cmd_tcp_put_payload
	ldx #<cmd_tcp_put
	ldy #>cmd_tcp_put
	jsr sendcommand
	jsr read_status
	bcs BADBADBAD2
	lda cmd_tcp_put_payload
@save_x=*+1
	ldx #$ff
@save_y=*+1
	ldy #$ff
	rts

;----------------------------------------------------------------------
sendcommand:
	stx zpcmd
	sty zpcmd+1

	ldy #1
	lda (zpcmd),y	; length of command
sendcommand2:
	sta @len

	lda #$ff	; DDR PB input
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

;----------------------------------------------------------------------
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

;----------------------------------------------------------------------
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

;----------------------------------------------------------------------
write_byte:
	sta $dd01	; write data
	lda #$10
:	bit $dd0d	; wait for the device to accept the byte
	beq :-
	rts

;----------------------------------------------------------------------
read_byte:
	lda #$10	; wait for device to have a byte ready
:	bit $dd0d
	beq :-
	lda $dd01
	rts

;----------------------------------------------------------------------
wic64_enable:
wic64_disable:
wic64_dropdtr:
	rts

;----------------------------------------------------------------------
cmd_tcp_get:
	.byte 'W'
	.word 6
	.byte 34
	.word BYTES_PER_TCP_GET

cmd_tcp_put:
	.byte 'W'
	.word 5
	.byte 35
cmd_tcp_put_payload:
	.byte $00	; <- will be overwritten

cmd_tcp_connect:
	.byte 'W'
cmd_tcp_connect_len:
	.word $00	; <- will be overwritten
	.byte 33

server_address:
	.byte 0
	.byte "192.168.176.104:25232",0
;	.byte "raveolution.hopto.org:64128",0
;	.byte "lu8fjh-c64.ddns.net:6400",0

;----------------------------------------------------------------------
once:
	.byte 0
