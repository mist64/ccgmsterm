; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Show instructions and credits
;

show_instructions:
	lda #<txt_instructions1
	ldy #>txt_instructions1
	jsr outstr
	lda #0		; [XXX replace with call to identical code below]
	sta 198
:	lda 198
	beq :-
	lda #<txt_instructions2
	ldy #>txt_instructions2
	jsr outstr
	lda #0
	sta 198
:	lda 198
	beq :-
	rts
