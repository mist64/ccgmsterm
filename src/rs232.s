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
	lda modem_type
	beq @2		; MODEM_TYPE_USERPORT
	cmp #MODEM_TYPE_UP9600
	beq @1
	jmp sw_setup
@1:	jmp up9600_setup
@2:	jmp rsuser_setup

;----------------------------------------------------------------------
; Dispatch: Enable transfer
enablexfer:
	pha
	txa
	pha
	tya
	pha
	lda modem_type
	beq @1		; MODEM_TYPE_USERPORT
	cmp #MODEM_TYPE_UP9600
	beq @2
	jsr sw_enable
	jmp xferout
@1:	jsr rsuser_enable
	jmp xferout
@2:	jsr up9600_enable
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
	lda modem_type
	beq @2		; MODEM_TYPE_USERPORT
	cmp #MODEM_TYPE_UP9600
	beq @1
	jsr sw_disable
	jmp xferout
@1:	jsr up9600_disable
	jmp xferout
@2:	jsr rsuser_disable
	jmp xferout		; [XXX redundant]
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
	lda modem_type
	beq @2			; MODEM_TYPE_USERPORT
	cmp #MODEM_TYPE_UP9600
	beq @1
	jsr sw_getxfer		; swiftlink
	jmp @cont
@1:	jsr up9600_getxfer	; up9600
	jmp @cont
@2:	jsr $F04F		; XXX necessary for User Port driver
	jsr rsuser_getxfer	; regular
@cont:	pha
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
	lda modem_type
	beq @2			; MODEM_TYPE_USERPORT
	cmp #MODEM_TYPE_UP9600
	beq @1
	pla
	jmp sw_putxfer		; swiftlink
@1:	pla
	jmp up9600_putxfer	; up9600
@2:	;jsr $EFE3		; XXX maybe necessary for User Port driver
	pla
	jmp rsuser_putxfer	; regular

;----------------------------------------------------------------------
; Dispatch: Hang up
dropdtr:
	lda modem_type
	jeq rsuser_dropdtr	; MODEM_TYPE_USERPORT
	cmp #MODEM_TYPE_UP9600
	jeq up9600_dropdtr
	jmp sw_dropdtr
