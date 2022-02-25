; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; RS232 Driver Dispatch
;

;----------------------------------------------------------------------
; Dispatch: Enable modem
enablemodem:
	ldx #MODEM_TYPE_SWIFTLINK_DE
	lda modem_type
	cmp #MODEM_TYPE_SWIFTLINK_DE
	bcc :+
	txa
:	asl
	tax
	lda modem_drivers,x
	sta tmp02
	lda modem_drivers+1,x
	sta tmp02+1
	ldx #1
	ldy #0
:	lda (tmp02),y
	sta rs232_funcs,x
	iny
	inx
	lda (tmp02),y
	sta rs232_funcs,x
	iny
	inx
	inx
	cpy #2*6
	bne :-

rs232_funcs:
; setup
	jmp $ffff
func_enable:
	jmp $ffff
func_disable:
	jmp $ffff
func_getxfer:
	jmp $ffff
func_putxfer:
	jmp $ffff
func_dropdtr:
	jmp $ffff

	.res 6*2

modem_drivers:
	.word rsuser_funcs	; MODEM_TYPE_USERPORT
	.word up9600_funcs	; MODEM_TYPE_UP9600
	.word sw_funcs		; MODEM_TYPE_SWIFTLINK_DE, ...

;----------------------------------------------------------------------
; Dispatch: Enable transfer
enablexfer:
	pha
	txa
	pha
	tya
	pha
	jsr func_enable
	jmp xferout

;----------------------------------------------------------------------
; Dispatch: Disable transfer
disablexfer:
disablemodem:
	pha
	txa
	pha
	tya
	pha
	jsr func_disable
xferout:
	pla
	tay
	pla
	tax
	pla
	rts

;----------------------------------------------------------------------
; Dispatch: Get byte from modem
modget:
	jsr func_getxfer
	pha
	php
	lda #0
	rol
	sta status		; some callers want STATUS set
	plp			; others want C set on error/no data
	pla
	rts

;----------------------------------------------------------------------
; Dispatch: Send byte to modem
modput:
	pha
	lda #0
	sta status
	pla
	jmp func_putxfer

;----------------------------------------------------------------------
; Dispatch: Hang up
dropdtr	= func_dropdtr
