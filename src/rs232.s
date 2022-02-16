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
	cmp #MODEM_TYPE_WIC64
	beq @0
	cmp #MODEM_TYPE_SWIFTLINK_DE
	beq @3
	cmp #MODEM_TYPE_SWIFTLINK_DF
	beq @4
	cmp #MODEM_TYPE_SWIFTLINK_D7
	beq @5
	rts
@0:	jmp wic64_setup
@1:	jmp up9600_setup
@2:	jmp rsuser_setup
@3:	lda #$de
	jmp @6
@4:	lda #$df
	jmp @6
@5:	lda #$d7
; set Swiftlink address by modifying all access code
; [XXX this should be moved to the Swiftlink code]
@6:	sta sm1+2
	sta sm2+2
	sta sm3+2
	sta sm4+2
	sta sm5+2
	sta sm6+2
	sta sm7+2
	sta sm8+2
	sta sm9+2
	sta sm10+2
	sta sm11+2
	sta sm12+2
	sta sm13+2
	sta sm14+2
	sta sm15+2
	sta sm16+2
	sta sm17+2
	sta sm18+2
	sta sm19+2
	sta sm20+2
	sta sm21+2
	sta sm22+2
	sta sm23+2
	sta sm24+2
	sta sm25+2
	jmp sw_setup

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
	cmp #MODEM_TYPE_WIC64
	beq @3
	jsr sw_enable
	jmp xferout
@1:	jsr rsuser_enable
	jmp xferout
@2:	jsr up9600_enable
	jmp xferout
@3:	jsr wic64_enable
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
	cmp #MODEM_TYPE_WIC64
	beq @3
	jsr sw_disable
	jmp xferout
@1:	jsr up9600_disable
	jmp xferout
@2:	jsr rsuser_disable
	jmp xferout
@3:	jsr wic64_disable
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
	cmp #MODEM_TYPE_WIC64
	beq @3
	jsr sw_getxfer		; swiftlink
	jmp @cont
@3:	jsr wic64_getxfer	; wic64
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
	cmp #MODEM_TYPE_WIC64
	beq @3
	pla
	jmp sw_putxfer		; swiftlink
@3:	pla
	jmp wic64_putxfer	; wic64
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
	cmp #MODEM_TYPE_WIC64
	jeq wic64_dropdtr
	jmp sw_dropdtr
