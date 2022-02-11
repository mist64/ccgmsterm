;----------------------------------------------------------------------
txt_multixfer:
	.byte CR,WHITE,'mULTI-TRANSFER - pUNTER ONLY.',CR,0

;----------------------------------------------------------------------
cf1	;multi-send
	jsr cosave
	lda protoc
	beq mulsav	; PROTOCOL_PUNTER
mulnop
	lda #<txt_multixfer
	ldy #>txt_multixfer
	jsr outstr
	jmp ui_abort
mulsav
	jsr supercpu_off
	lda #CLR
	jsr chrout
;lda buffer_ptr+1;old references comparing buffer area and making sure theres enough
;cmp #>mulfil;room for punter files to be stored, but since we're now
;bcc mulsok;reserving #$ff space for punter, its not neccessary
;lda buffer_ptr
;cmp #<mulfil
;bcc mulsok
;lda #<mlswrn
;ldy #>mlswrn
;jsr outstr
;jmp ui_abort
mulsok	lda #<msntxt
	ldy #>msntxt
	jsr outstr
	lda #<moptxt
	ldy #>moptxt
	jsr outstr
	jsr mltdir;grab files from directory listing
	lda mulcnt;some files to send?
	bne mlss1;yes
mlss0	jmp mlssab;nope, we are done
mlss1
	lda mulfln
	sta mulcnt;how many files to send. decrement until none left
	beq mlss0
	lda #0
	sta mulfln
	lda #<mulfil
	sta $fd
	lda #>mulfil
	sta $fe
mlslop
	ldy #19
	lda ($fd),y
	bne mlssen
mlsinc
	lda $fd
	clc
	adc #20
	sta $fd
	lda $fe
	adc #0
	sta $fe
	lda $fe
	cmp #>endmulfil
	bcc mlslop
	jmp mulab2
mlssen
	ldy #17
mlss2	lda ($fd),y
	cmp #160
	bne mlss3
	dey
	cpy #01
	bne mlss2
	jmp mulab2
mlss3	dey
	sty max
	iny
mlss4	lda ($fd),y
	sta inpbuf-2,y
	dey
	cpy #01
	bne mlss4
	ldx max
	lda #','
	sta inpbuf,x
	ldy #18
	lda ($fd),y
	and #07
	cmp #04
	bne mlsg
	jmp mulabt
mlsg
	tay
	lda drtype,y
	sta inpbuf+1,x
mlsgo
	jsr mlshdr
	ldy #0
mlsgo1	lda inpbuf,y
	jsr chrout
	iny
	cpy max
	bne mlsgo1
	lda inpbuf,y
	jsr chrout
	lda inpbuf+1,y
	jsr chrout
	lda #$0d
	jsr chrout
	jsr clrchn
	jsr uplmen;disk setup
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq mulab2
	lda inpbuf
	bne mulab2
	inc mulfln
	lda mulfln
	cmp mulcnt
	beq mlss5
	ldx #00
	stx JIFFIES
mlstim	lda JIFFIES
	cmp #110
	bcc mlstim
	jmp mlsinc
mlss5
	jsr mlshdr
	ldx #16
	lda #04   ;ctrl-d
mlss6	jsr chrout
	dex
	bne mlss6
	lda #$0d
	jsr chrout
mlssab	jsr clrchn
	jsr coback
	jsr gong
	jmp term_entry
mlshdr
	jsr clear232
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout
	ldx #16
	lda #09   ;ctrl-i
mlscri	jsr chrout
	dex
	bne mlscri
	rts
mulabt
	jsr gong
mulab2
	jsr clrchn
	lda #$0d
	jsr chrout
	lda #02
	jsr close
	lda modem_type
	cmp #MODEM_TYPE_SWIFTLINK_DE
	bmi mulab3
mulab3
	jsr enablexfer
	jmp term_entry
;
cf3	;multi-receive
	jsr disablexfer
	jsr cosave
	lda protoc
	beq mulrav	; PROTOCOL_PUNTER
	jmp mulnop
mulrav
	jsr supercpu_off
	lda #$01
	sta mulcnt
	lda #CLR
	jsr chrout
	lda #<mrctxt
	ldy #>mrctxt
	jsr outstr
mrllgc
	ldx SHFLAG
	bne mrllgc
mlrnew
	jsr enablexfer
	ldy #0
	sty max
mlrwat
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq mulab2
	ldx #LFN_MODEM
	jsr chkin
	jsr getin
	cmp #09
	bne mlrwat
mlrwt2
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq mulab2
	jsr getin
	cmp #0
	beq mlrwt2
	cmp #9    ;ctrl-i
	beq mlrwt2
	bne mlrfl1
mlrflp
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq mulab2
	ldx #LFN_MODEM
	jsr chkin
	jsr getin
	cmp #0
	beq mlrflp
mlrfl1
	cmp #$0d
	beq mlrfl2
	ldy max
	sta inpbuf,y
	inc max
	lda max
	cmp #18
	bcc mlrflp
mlrfl2
	ldy max
	cpy #03
	bcc mlfext
	dey
	dey
	lda inpbuf,y
	cmp #','
	bne mlfext
	sty max
	lda inpbuf
	cmp #04   ;ctrl-d
	bne mlffl2
mlfext	jmp mulabt
mlffl2
	jsr dowmen
	lda inpbuf
	beq mlrnew
	bne mlfext
;
goobad
	sta 1844
	cmp #'/'
	beq goober
	cmp #'*'
	bne goob2
goober	rts
goob2	cmp #':'
	beq goob3
	ldx #3
	bne goob4
goob3	ldx #25
goob4	inc 1837,x
	lda 1837,x
	cmp #':'
	bcc goober
	lda #'0'
	sta 1837,x
	dex
	bpl goob4
	rts

;----------------------------------------------------------------------
msntxt	.byte CR,14,WHITE,18,32,'mULTI-sEND ',146,32,45,32
	.byte 'sELECT FILES:',CR,CR,0
moptxt	.byte LTBLUE,' yES/nO/qUIT/sKIP8/dONE/'
	.byte 'aLL',CR,0
mrctxt	.byte CR,14,WHITE,18,32,'mULTI-rECEIVE ',CR,CR
	.byte CYAN,'wAITING FOR HEADER...c= ABORTS.',CR,0

;----------------------------------------------------------------------
;multi - choose files
mltdir
	jsr disablexfer
	lda device_disk
	jsr listen
	lda #$f0
	jsr second
	lda #'$'
	jsr ciout
	lda #'0'
	jsr ciout
	lda #':'
	jsr ciout
	lda #'*'
	jsr ciout
	jsr unlsn
	lda #<mulfil
	sta $fd
	lda #>mulfil
	sta $fe
	lda device_disk
	jsr talk
	lda #$60
	jsr tksa
	ldy #0
	sty mulcnt ;count entries
	sty mulfln
	sty mlsall
	sty mulskp
	ldy #31
mdrlp0
	jsr mgetch
	dey
	bpl mdrlp0
	ldy #$01
mdrlp1	jsr mgetch
	dey
	bpl mdrlp1
	ldy #0
	jsr mgetch
	sta ($fd),y
	sta $07e8,y
	iny
	jsr mgetch
	sta ($fd),y
	sta $07e8,y
	lda #0
	sta $06
mdrlp2	jsr mgetch
	inc $06
	cmp #'"'
	bne mdrlp2
mdrlpf
	iny
	cpy #18
	beq drlpfn
	jsr mgetch
	cmp #'"'
	bne drlpnq
	lda #160
drlpnq
	sta ($fd),y
	sta $07e8,y
	jmp mdrlpf
drlpfn
	dey
	cpy #01
	beq drlptc
	lda $07e8,y
	cmp #' '
	bne drlptc
	lda #160
	sta ($fd),y
	sta $07e8,y
	bne drlpfn
drlptc
	jsr mgetch
	lda #00
	sta $05
	jsr mgetch
	cmp #'*'
	bne drlpsp
	lda #$80
	sta $05
drlpsp
	jsr mgetch
	ldx #04
drlptl
	cmp drtype,x
	beq drlptp
	dex
	bne drlptl
drlptp
	txa
	ora $05
	sta $05
	jsr mgetch
	jsr mgetch
	jsr mgetch
	cmp #'<'
	bne drlpte
	lda $05
	ora #$40
	sta $05
drlpte	lda $05
	ldy #18
	sta ($fd),y
	sta $07e8,y
	lda #00
	iny
	sta ($fd),y
dirgrb
	jsr mgetch
	bne dirgrb
	inc mulcnt
	lda mulskp
	bne mulpmt
	jsr mdrret
	bne mulnen
mulpmt	dec mulskp
	jsr drpol7
mulnen
	lda device_disk
	jsr talk
	lda #$60
	jsr tksa
	ldy #01
	jmp mdrlp1
mgetch	jsr acptr
	ldx status
	bne mdrlp3
	cmp #00
	rts
mdrlp3	pla
	pla
mdrext	lda device_disk
	jsr listen
	lda #$e0
	jsr second
	jsr untlk
	jsr unlsn
	jsr clrchn
	jsr ercopn ; possible fix for multi upload crash on up9600 - 2018 fix
	jmp enablexfer
mdrret
	ldy #0
drpol0
	sty tmp02
	lda drform,y
	cmp #2		; ctrl-b
	bne drpol1
	ldy #00
	lda $07e8,y
	tax
	iny
	lda $07e8,y
	jsr $bdcd
	ldy $06
drprbl
	lda #' '
	jsr chrout
	dey
	bne drprbl
	beq drpol4
drpol1
	cmp #$0e  ;ctrl-n
	bne drpol2
	ldy #02
drprnm
	lda $07e8,y
	jsr chrout
	iny
	cpy #18
	bne drprnm
	beq drpol4
drpol2
	cmp #$06  ;ctrl-f
	bne drpol3
	ldy #18
	lda $07e8,y
	tay
	and #07
	tax
	tya
	and #$80
	bne drprf1
	lda #' '
	bne drprf2
drprf1	lda #'*'
drprf2	jsr chrout
	lda drtype,x
	jsr chrout
	lda drtyp2,x
	jsr chrout
	lda drtyp3,x
	jsr chrout
	tya
	and #$40
	bne drprf3
	lda #' '
	bne drprf4
drprf3	lda #'<'
drprf4	jsr chrout
	bne drpol4
drpol3
	jsr chrout
drpol4
	ldy tmp02
	iny
	cpy #14
	beq drpol5
	jmp drpol0
drpol5
	lda mlsall
	beq mlsf0
	lda #'Y'
	jsr chrout
	bne mlsyes
mlsf0
	lda #' '
	jsr chrout
	lda #CSR_LEFT
	jsr chrout
	jsr cursor_show
mlswlp	jsr getin
	beq mlswlp
	and #127
	cmp #'A'
	bcc mlswlp
	cmp #'['
	bcs mlswlp
	pha
	jsr cursor_off
	pla
	pha
	jsr chrout
	lda #CSR_LEFT
	jsr chrout
	pla
	cmp #'Y'
	bne mlsf1
mlsyes	ldy #19
	inc mulfln
	lda #$80
	sta ($fd),y
	bne mlsnpr2
mlsf1	cmp #'N'
	beq mlsnpr
	cmp #'A'
	bne mlsf2
	lda #01
	sta mlsall
	bne mlsyes
mlsf2
	cmp #'D'
	bne mlsf3
	lda #$0d
	jsr chrout
	jmp mdrlp3
mlsf3
	cmp #'Q'
	bne mlsf4
	jsr mdrext
	pla
	pla
	pla
	pla
	jsr clrchn
	jmp term_entry
mlsf4
	cmp #'S'
	bne mlsf0
	lda #07
	sta mulskp
mlsnpr	lda #$0d
	jsr chrout
drpol7
	lda $fd
	clc
	adc #0
	sta $fd
	lda $fe
	adc #0
	sta $fe
	rts
mlsnpr2	lda #$0d
	jsr chrout
drpol72
	lda $fd
	clc
	adc #20
	sta $fd
	lda $fe
	adc #0
	sta $fe
	rts
