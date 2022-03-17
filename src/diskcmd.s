; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Disk Command
;

;----------------------------------------------------------------------
txt_diskcommand:
	.byte WHITE,CR
	.byte "#"
txt_diskcommand_devno:
	.byte "**"
	.byte ">      "
	.byte CSR_LEFT,CSR_LEFT,CSR_LEFT,CSR_LEFT,CSR_LEFT,CSR_LEFT,0
int2dectab:
	.byte "8 "	; [XXX potential for optimization ($bdcd]
	.byte "9 "
	.byte "10"
	.byte "11"
	.byte "12"
	.byte "13"
	.byte "14"
	.byte "15"
	.byte "16"
	.byte "17"
	.byte "18"
	.byte "19"
	.byte "20"
	.byte "21"
	.byte "22"
	.byte "23"
	.byte "24"
	.byte "25"
	.byte "26"
	.byte "27"
	.byte "28"
	.byte "29"
	.byte "30"

;----------------------------------------------------------------------
handle_f5_diskcommand:
	jsr col80_pause
	jsr rs232_off
	jsr ercopn
	jsr text_color_save
dskcmd
	lda device_disk
	sec
	sbc #$08
	asl a
	tay
	lda int2dectab,y
	sta txt_diskcommand_devno
	lda int2dectab+1,y
	sta txt_diskcommand_devno+1
	lda #<txt_diskcommand
	ldy #>txt_diskcommand
	ldx #36;1 - what does this do? limit length of command?
	jsr input
	beq drverr	; nothing entered, drive error code?
	lda inpbuf
	cmp #'#'	; drive
	beq chgdev
	jsr is_drive_present
	bmi drvext
	lda #CR		; exit
	jsr chrout
	lda inpbuf
	cmp #'$'	; directory
	bne drvsnd
	lda max
	ldx #<inpbuf
	ldy #>inpbuf
	jmp dodir
drvsnd
	ldx device_disk
	stx 612		; dev# table, log#15
	ldx #LFN_DISK_CMD
	jsr chkout
	ldx #0
drvlop
	lda inpbuf,x
	jsr chrout
	inx
	cpx max
	bne drvlop
	lda #CR
	jsr chrout
drvext
	jsr clrchn
	jsr text_color_restore
	lda #CR
	jsr chrout
	jsr rs232_on
	jmp term_mainloop
drverr
	jsr is_drive_present
	bmi drvext
	jsr clrchn
	ldx #LFN_DISK_CMD
	jsr chkin
drver2
	jsr getin
drver3
	jsr chrout
	cmp #CR
	bne drver2
	jsr clrchn
	jsr col80_wait
	jmp drvext

;----------------------------------------------------------------------
chgdev:
	ldy #1
	ldx inpbuf,y
	txa
	sec
	sbc #$30
	beq chgdv2	; if first char is 0 as in 08 or 09
	cmp #$03	; devices 10-29 "1x or 2x"
	bpl chgdv8	; might be 8 or 9.. anything over 3 doesnt count here so lets try and see if it matches 8 or 9.
	clc		; definitely starts with 1 or 2 if it makes it this far
	adc #$09	; $0a-$0b for device starting with 1x or 2x, convert to hex
	jmp chgdv2
chgdv8
	cmp #$07
	bpl chgdv9	; assume its 8 or 9, which is the only options when it starts with 8 or 9
	jmp drvext	; nope there was nothing in the 00-29 range
chgdv2	iny		; get the second character
	sta drivetemp
	lda inpbuf,y
	sec
	sbc #'0'	; decimal petscii to hex, again...
	clc
	adc drivetemp
chgdv9
	cmp #8		; lowest drive # (8)
	bcc drvext
	cmp #30		; highest drive # (30)
	bcs drvext
	tay		;y now holds complete hex of drive #
	lda device_disk
	pha
	sty device_disk
	sty 612
	jsr is_drive_present
	bmi chgdv3
	pla
	lda #CSR_UP
	jsr chrout
	jmp dskcmd
chgdv3
	pla
	sta device_disk
	sta 612
chgdv4
	lda #' '
	jsr chrout
	lda #'-'
	jsr chrout
	lda #' '
	jsr chrout
	ldy #0
chgdv5
	lda $a1d0,y  ;device not present
	php
	and #$7f
	jsr chrout
	plp
	bmi chgdv6
	iny
	bne chgdv5
chgdv6
	jmp drvext
