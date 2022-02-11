; REU ROUTINES
;  17XX REU
;  Only uses first bank regardless. 64k is more than enough memory

; REU in use
;  0: no (RAM buffers)
;  1: yes (REU buffers)
reu_enabled:
	.byte 0

; detect REU
reu_detect:
	; enable this to temporarily disable REU support
	;jmp noreu

	ldx #2
:	txa
	sta $df00,x
	inx
	cpx #6
	bne :-

	ldx #2
:	txa
	cmp $df00,x
	bne noreu
	inx
	cpx #6
	bne :-

	lda #1
	sta reu_enabled
	lda #0		; set buffer start
	sta newbuf
	sta newbuf+1
	sta buffst
	sta buffst+1
	sta buffer_ptr
	sta buffer_ptr+1
	lda #$ff
	sta bufend
	sta bufend+1
	rts

noreu:
	lda #0
	sta reu_enabled
	lda #<endprg	; set buffer start
	sta buffst
	lda #>endprg
	sta buffst+1
	lda #<buftop
	sta bufend
	lda #>buftop
	sta bufend+1
	rts

bufend:
	.word 0

;read/write to from reu

length	= 1	; one byte at a time

reuwrite:
	sta bufptrreu
	pha
	lda #<bufptrreu
	sta $df02
	lda #>bufptrreu
	sta $df03
	lda buffer_ptr
	sta $df04
	lda buffer_ptr+1
	sta $df05
	lda #0
	sta $df06
	lda #<length
	sta $df07
	lda #>length
	sta $df08
	lda #0
	sta $df0a
	lda #$b0
	sta $df01
	pla
	rts

reuread:
	lda #<buffstreu
	sta $df02
	lda #>buffstreu
	sta $df03
	lda buffst
	sta $df04
	lda buffst+1
	sta $df05
	lda #0
	sta $df06
	lda #<length
	sta $df07
	lda #>length
	sta $df08
	lda #0
	sta $df0a
	lda #$b1
	sta $df01
	lda buffstreu
	rts
