cosave
	ldx textcl
	stx $04
cochng
	ldx #tcolor
	stx textcl
	rts
coback
	ldx $04
	stx textcl
	rts
f6	;directory
	lda #$01
	ldx #<dirfn
	ldy #>dirfn
dodir
	jsr setnam
	jsr dir
	jsr enablexfer
	jmp main
f8	;term toggle
	ldx 653
	cpx #2
	bne termtg
	jmp cf7
termtg
	lda grasfl
	eor #$01
	sta grasfl
	jsr bell
	jmp term
crsrtg	;ascii crsr toggle
	jsr curoff
	lda cursfl
	eor #$01
	sta cursfl
	jmp main

hangup	;hang up phone
	ldx 653
	cpx #2
	bne hangup6;not C= Stop
	jsr curoff
	lda #<dsctxt
	ldy #>dsctxt
	jsr outstr
	lda motype
	beq droprs
	cmp #$01
	beq dropup
	jmp dropswift
hangup6	jmp main

droprs	lda #%00000100
	sta $dd03
	lda #0
	sta $dd01
	ldx #226
		stx $a2
:	bit $a2
		bmi :-
	lda #4
	sta $dd01
	jmp main

dropup	lda #$04
	sta $dd03    ;cia2: data direction register b
	lda #$02
	sta $dd01    ;cia2: data port register b
	ldx #$e2
		stx $a2
a7ef3	bit $a2
	bmi a7ef3
	lda #$02
	sta $dd03    ;cia2: data direction register b
	jmp main
dropswift
	jsr dropdtr
	jmp main
