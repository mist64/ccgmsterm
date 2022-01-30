
;XMODEM
;xmodem routines
xmstat	.byte 0
xmoblk	.byte 0
xmochk	.byte 0
xmobad	.byte 0
xmowbf	.byte 0
xmodel	.byte 0
xmoend	.byte 0
xmostk	.byte $ff
;
xmosnd;crc mods here
	tsx
	stx xmostk
	jsr xmoset
	jsr pnt109
	lda protoc
	cmp #$01
	beq pronak
	lda #crc
	ldx #133
	jmp promoveon
pronak	lda #nak
	ldx #132
promoveon
	sta promod+1
	stx promod2+1
xmupl1
	lda #6    ;60 secs
	jsr xmmget
	beq xmupl2
xmupab	jmp xmabrt
xmupl2
	cmp #can
	beq xmupab
promod	cmp #nak
	bne xmupl1
xmupll
	jsr xmocbf
	sty xmobad
	lda #soh
	sta (xmobuf),y
	iny
	lda xmoblk
	sta (xmobuf),y
	iny
	eor #$ff
	sta (xmobuf),y
	iny
xmsnd1
	jsr disablexfer
	ldx #2
	jsr chkin
xmsnd2
	jsr getin
	ldx $90   ;status
	stx xmoend
xmsnd3
xmsnd4
	sta (xmobuf),y
	clc
	adc xmochk
	sta xmochk
	iny
	cpy #131
	bcs xmsnd5
	ldx xmoend
	beq xmsnd2
	lda #cpmeof
	bne xmsnd3
xmsnd5
	sta (xmobuf),y
	jsr clrchn
xmsnd6
	jsr xmrclr
	jsr enablexfer
	ldx #5
	jsr chkout
	lda protoc;crc fix
	cmp #$02
	beq xmosndcrc
xmsnd77
	ldy #0
xmsnd7;crc mod
	lda (xmobuf),y
	jsr chrout
	iny
promod2	cpy #132
	bcc xmsnd7
xmmcontinue
	jsr clrchn
	jsr xmricl
	lda #3
	jsr xmmget
	bne xmsnbd
	cmp #can
	bne xmsnd8
	jmp xmabrt
xmosndcrc
	jsr 	calccrc
		ldy #131
		lda	crcz+1		; save hi byte of crc to buffer
		sta	(xmobuf),y		;
		iny			;
		lda	crcz		; save lo byte of crc to buffer
		sta	(xmobuf),y
	jmp xmsnd77
;crc mod

calccrc		lda	#$00		; yes, calculate the crc for the 128 bytes
		sta	crcz		;
		sta	crcz+1		;
		ldy	#3		;
calccrc1	lda	(xmobuf),y		;
		eor 	crcz+1 		; quick crc computation with lookup tables
			tax		 	; updates the two bytes at crc & crc+1
			lda 	crcz		; with the byte send in the "a" register
			eor 	crchi,x
			sta 	crcz+1
		 	lda 	crclo,x
			sta 	crcz
		iny			;
		cpy	#131		; done yet?
		bne	calccrc1	; no, get next
		rts			; 128 bytes achieved, 4-131 (#03-#130)
;end crc mods
xmsnd8	cmp #nak
	bne xmsnd9
xmsnbd
	jsr chrout
	jmp xmsnd6
xmsnd9	cmp #ack
	bne xmsnbd
xmsnnx
	lda #'-'
	jsr goobad
	ldx xmoend
	bne xmsnen
	inc xmoblk
	inc xmowbf
	jmp xmupll
xmsnen
	lda #0
	sta xmoend
xmsne1
	jsr enablexfer
	ldx #5
	jsr chkout
	lda #eot
	jsr chrout
	lda #3
	jsr xmmget
	bne xmsne2
	cmp #ack
	bne xmsne2
	jmp xmfnok
xmsne2
	inc xmoend
	lda xmoend
	cmp #10
	bcc xmsne1
	jmp xmneot
;
;
xmoset
	lda #1
	sta xmoblk
	lda #0
	sta xmowbf
	sta xmobad
xmocbf
	lda xmowbf
	and #3
	sta xmowbf
	lda #<xmoscn
	sta xmobuf
	lda #>xmoscn
	sta xmobuf+1
	ldx xmowbf
	beq xmocb2
xmocb1
	lda xmobuf
	clc
	adc #$85
	sta xmobuf
	lda xmobuf+1
	adc #0
	sta xmobuf+1
	dex
	bne xmocb1
xmocb2	ldy #0
	sty xmochk
	sty xmoend
	rts
xmrclr
	lda $029d ;clear rs232 output
	sta $029e
xmricl
	lda $029b ;and input buffers
	sta $029c
	rts
xmmget
	sta xmodel
	lda #0
	sta rtca1
	sta rtca2
	sta rtca0
xmogt1
	jsr modget
	bcs xmmgt2
	ldx #0
	rts
xmmgt2
	jsr xchkcm
	jsr xmmrtc
	lda rtca0
	cmp xmodel
	bcc xmogt1
	jsr clrchn
	and #0
	ldx #1
	rts
xmmrtc
f69b	ldx #$00
f69d	inc rtca2
f69f	bne f6a7
f6a1	inc rtca1
f6a3	bne f6a7
f6a5	inc rtca0
f6a7	sec
f6a8	lda rtca2
f6aa	sbc #$01
f6ac	lda rtca1
f6ae	sbc #$1a
f6b0	lda rtca0
f6b2	sbc #$4f
f6b4	bcc f6bc
f6b6	stx rtca0
f6b8	stx rtca1
f6ba	stx rtca2
f6bc	rts
rtca1	.byte $00
rtca2	.byte $00
rtca0	.byte $00
xincbd
	lda #':'
	jsr goobad
	inc xmobad
	lda xmobad
	cmp #10
	bcs xmtrys
	rts
xchkcm
	ldx 653
	cpx #2
	beq xmcmab
	rts
xmfnok	lda #'*'
	jsr goobad
	lda #0
	.byte $2c
xmabrt	lda #1
	.byte $2c
xmneot	lda #2
	.byte $2c
xmtrys	lda #3
	.byte $2c
xmsync	lda #4
	.byte $2c
xmcmab	lda #5
	sta xmstat
xmoext
	tsx
	cpx xmostk
	beq xmoex2
	pla
	clc
	bcc xmoext
xmoex2
	jsr xmrclr
	lda xmstat
	cmp #4
	bcc xmoex4
	jsr pnt109
	ldx #5
	jsr chkout
	ldy #8
	lda #can
xmoex3
	jsr chrout
	dey
	bpl xmoex3
xmoex4
	jsr clrchn
	jsr disablexfer
	lda #2
	jmp close
;
xmorcv
	tsx
	stx xmostk
	jsr pnt109;clear and disable/enablexfer
	jsr xmoset
	beq xmorcp
xmorc0
	jsr xincbd
xmorcp
	lda #0
	sta xmoend
xmorc1;crc fix
	jsr clear232
	jsr enablexfer
	ldx #5
	jsr chkout
	lda protoc
	cmp #$01
	beq oldxmodemout
	lda #crc
	ldx #133
	jmp newcrcout
oldxmodemout
	lda #nak
	ldx #132
newcrcout
	sta crcrcvfix1+1
	stx crcrcvfix2+1
crcrcvfix1	lda #nak
	jsr chrout
	jsr clrchn
xmorcl
	lda #1
	jsr xmmget
	beq xmorc2
xmorci
	inc xmoend
	lda xmoend
	cmp #10
	bcc xmorc1
xmrcab	jmp xmabrt
xmorc2
	cmp #can
	beq xmrcab
	cmp #eot
	bne xmorcs
	lda #1
	sta xmoend
	jmp xmorak
xmorcs
	cmp #soh
	bne xmorci
	jsr xmocbf
	beq xmorc4
xmorc3
	lda #1
	jsr xmmget
	bne xmorc0
xmorc4
	sta (xmobuf),y
	iny
crcrcvfix2	cpy #132
	bcc xmorc3
;doing the old checksum check
	ldy #1
	lda (xmobuf),y;byte 2
	iny
	eor (xmobuf),y;byte 3 (packet #/ff check)
	cmp #$ff
	bne xmorc0
	jsr disablexfer
	lda protoc
	cmp #$02
jeq	receivecheck;bypass the checksum and go to the crc check for xmodem-crc
	lda #0
xmorc5
	iny
	cpy #131
	bcs xmorc6
	adc (xmobuf),y
	clc
	bcc xmorc5
xmorc6
	sta xmochk
	cmp (xmobuf),y;132(#131-checksum byte)
jne	xmorc0
;old checksum is done
backcrc
	ldy #1
	lda (xmobuf),y
	cmp xmoblk
	beq xmorc7
	ldx xmoblk
	dex
	txa
	cmp (xmobuf),y
	bne xmorsa
	lda #'/'
	jsr goobad
	jmp xmorc9
xmorsa	jmp xmsync
xmorc7
	jsr clrchn
	jsr disablexfer
	ldx #2
	jsr chkout
	ldy #3
xmorc8
	lda (xmobuf),y
	jsr chrout
	iny
	cpy #131
	bcc xmorc8
xmorc9
	lda #0
	sta xmoend
	inc xmoblk
	jsr clrchn
	lda #'-';good block
	jsr goobad
xmorak
	inc xmowbf
	jsr clear232
	jsr enablexfer
	ldx #5
	jsr chkout
	lda #ack
	jsr chrout
	jsr clrchn
	lda #0
	sta xmobad
	lda xmoend
	bne xmor10
	jmp xmorcl;next block
xmor10
	jmp xmfnok;end of file, send * key
;
;crc check for xmodem-crc receive
receivecheck
	jsr 	calccrc
		ldy #131
		lda	crcz+1		; save hi byte of crc to buffer
		cmp	(xmobuf),y		;
		bne badcrc
		iny			;
		lda	crcz		; save lo byte of crc to buffer
		cmp	(xmobuf),y
		bne badcrc
	jmp backcrc
badcrc	jmp xmorc0
;
xmopsu	.byte 2,'PRG, ',2,'SEQ, or ',2,'USR? ',0
xmotyp
	lda #<xmopsu
	ldy #>xmopsu
	jsr outstr
	jsr savech
xmoty2
	jsr getin
	beq xmoty2
	and #$7f
	ldx #3
xmoty3
	cmp upltyp,x
	beq xmoty4
	dex
	bne xmoty3
	beq xmoty2
xmoty4
	stx pbuf+27
	rts
;
;crc mods here
xmo1er	.byte 13,'tRANSFER cANCELLED.',0
xmo2er	.byte 13,'eot nOT aCKNOWLEGED.',0
xmo3er	.byte 13,'tOO mANY bAD bLOCKS!',0
xmo4er	.byte 13,c,'sYNC lOST!',0
xmoupl
	jsr xmosnd
	jmp xmodon
xmodow
	jsr xmorcv
xmodon
	lda #$0d
	jsr chrout
	lda xmstat
	bne xmodn2
	jmp xfrdun
xmodn2
	cmp #5
	beq xmodna
	cmp #1
	bne xmodn3
	lda #<xmo1er
	ldy #>xmo1er
	bne xmodnp
xmodn3
	cmp #2
	bne xmodn4
	lda #<xmo2er
	ldy #>xmo2er
	bne xmodnp
xmodn4	cmp #3
	bne xmodn5
	lda #<xmo3er
	ldy #>xmo3er
	bne xmodnp
xmodn5
	lda #<xmo4er
	ldy #>xmo4er
xmodnp
	jsr outstr
	jsr gong
	lda #$0d
	jsr chrout
xmodna
	jmp abortx
