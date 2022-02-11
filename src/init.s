;pal/ntsc detect
prestart
l1	lda $d012
l2	cmp $d012
	beq l2
	bmi l1
	cmp #$20
	bcc start	; ntsc selected
	ldx #1
	stx is_pal_system

start

supercpudetect:
; "it should just tell you to turn that shit off.
; who needs 20MHz for 9600 baud, anyway?"
	lda $d0bc
	asl a
	bcs :+
	lda #1
	sta supercpu
:

;SETUP INIT
	jsr $e3bf;refresh basic reset - mostly an easyflash fix
	sei
	cld
	ldx #$ff
	txs
	lda #$2f
	sta $00
	lda #$37
	sta $01
	lda #1
	sta 204
	lda #bcolor  ;settup
	sta backgr
	sta border
	lda #tcolor
	sta textcl
	lda #$80
	sta 650      ;rpt
	lda #$0e
	sta $d418
	lda #$00
	sta locat
	lda #$e0       ;clear secondary
	sta locat+1    ;screens
	lda #$20
	ldy #$00
erasl1
	sta (locat),y
	iny
	bne erasl1
	inc locat+1
	bne erasl1
	cli
initdrive
	lda $ba        ;current dev#
	jmp stodv2
stodev	inc diskdv
	lda diskdv
	cmp #16;originally #16, try #30 here for top drive #?
	beq stodv5
	jmp stodv2
stodv5
	lda #$00
	sta drivepresent;we have no drives
	lda #$08
	sta diskdv
	jmp stodv3
stodv2	sta diskdv
	jsr drvchk
	bmi stodev
	lda #$01
	sta drivepresent;we have a drive!
stodv3
	lda efbyte
	beq stodv6;no easyflash - go ahead and look to see if we have an reu
	jsr noreu
	jmp stodv7
stodv6
	jsr detectreu
stodv7
	lda newbuf	; init. buffer
	sta buffer_ptr	; & open rs232
	lda newbuf+1
	sta buffer_ptr+1
stodv4
	jsr rsopen
	jsr ercopn
	jmp init
rsopen	;open rs232 file
	jsr rsuser_disable
	jsr up9600_disable
	jsr enablemodem
	jsr clall
	lda #LFN_MODEM
	ldx #DEV_MODEM
	ldy #SA_MODEM
	jsr setlfs
	lda protoe
	ldx #<proto
	ldy #>proto
	jsr setnam
	jsr open;$ffc2
	lda #>ribuf ;move rs232 buffers
	sta 248       ;for the userport 300-2400 modem nmi handling
	jsr disablemodem
	rts
ercopn
	lda drivepresent
	beq ercexit
	lda #$02;file length      ;open err chan
	ldx #<dreset
	ldy #>dreset
	jsr setnam
	lda #15
	ldx diskdv
	tay
	jsr setlfs
	jsr open;$ffc0
ercexit	rts
init
	lda #1
	sta cursor_flag	; non-destructive
	lda #0
	sta $9d		; suppress all KERNAL messages
	sta ascii_mode	; PETSCII mode
	;sta allcap     ; upper/lower
	sta buffer_open
	sta half_duplex	; full duplex
	jsr $e544	; clear screen
	lda alrlod	; already loaded config file?
	bne noload
	lda drivepresent
	beq noload	; no drive exists
;-------------
	jsr disablemodem
	lda #1
	sta alrlod
	ldx #<conffn
	ldy #>conffn
	lda #11
	jsr setnam
	lda #2
	ldx diskdv
	ldy #0
	jsr setlfs
	jsr loadcf
;-------------
	jmp begin
