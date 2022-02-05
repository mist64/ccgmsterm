;----------------------------------------------------------------------
; RS232 Generic Code
;----------------------------------------------------------------------

;----------------------------------------------------------------------
; RS232 driver dispatch: enable modem
enablemodem
	lda motype
	beq @2
	cmp #$01	; UP9600
	beq @1
	cmp #$02
	beq @3
	cmp #$03
	beq @4
	cmp #$04
	beq @5
	rts
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
; RS232 driver dispatch: enable transfer
enablexfer:
	pha
	txa
	pha
	tya
	pha
	lda motype
	beq @1
	cmp #1		; UP9600
	beq @2
	jsr sw_enable
	jmp xferout
@1:	jsr rsuser_enable
	jmp xferout
@2:	jsr up9600_enable
	jmp xferout

;----------------------------------------------------------------------
; RS232 driver dispatch: disable transfer
disablexfer:
disablemodem:
	pha
	txa
	pha
	tya
	pha
	lda motype
	beq @2
	cmp #1		; UP9600
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
; RS232 driver dispatch: get byte from modem
modget:
	lda motype
	beq @2
	cmp #1
	beq @1
	jmp sw_getxfer		; swiftlink
@1:	jmp up9600_getxfer	; up9600
@2:	jmp rsuser_getxfer	; regular

