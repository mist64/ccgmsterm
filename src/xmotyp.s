;----------------------------------------------------------------------
; prompt user about CBM DOS file type
xmopsu	.byte 2,'PRG, ',2,'SEQ, or ',2,'USR? ',0
xmotyp
	lda #<xmopsu
	ldy #>xmopsu
	jsr outstr
	jsr savech

@1:	jsr getin
	beq @1
	and #$7f
	ldx #3
@2:	cmp upltyp,x
	beq @3
	dex
	bne @2
	beq @1

@3:	stx pbuf+27
	rts
