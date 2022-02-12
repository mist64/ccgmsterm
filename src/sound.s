; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Sounds
;

;----------------------------------------------------------------------
bell:
	ldx #9
	stx $D413
	ldx #0
	stx $D414
	ldx #$40
	stx $D40F
	ldx #0
	stx $D412
	ldx #$11
	stx $D412
	rts

;----------------------------------------------------------------------
gongm1:
	.byte 24,6,13,20,4,11,18,15,8,1,5,19,12,14,7,0,4,11,18,24
gongm2:
	.byte 47,0,0,0,0,0,0,4,8,16,13,13,11,28,48,68,21,21,21,15
; [XXX it's shorter to just store 25 bytes and write them backwards into the SID]

gong:
	pha
	ldx #0
:	lda gongm1,x
	tay
	lda gongm2,x
	sta $d400,y
	inx
	cpx #20
	bcc :-
	pla
	rts
