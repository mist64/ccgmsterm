; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; File transfer generic code and UI
;

;----------------------------------------------------------------------
SET_PETSCII
txt_xmodem:
	.byte "XMODEM",0
txt_xmodem_crc:
	.byte "XMODEM-CRC",0
txt_xmodem_1k:
	.byte "XMODEM-1K",0
SET_ASCII

;----------------------------------------------------------------------
; display "[protocol], enter name" and input string
; A=0: upload, 1:download
ui_prompt_filename:
	pha
	lda protoc
	beq @2		; PROTOCOL_PUNTER
	lda #CR
	jsr chrout
	jsr chrout
	lda #WHITE
	jsr chrout
	pla
	pha
	bne @download
; upload
	lda protoc
	cmp #PROTOCOL_XMODEM_1K
	beq @upload_1k
	; XMODEM or XMODEM-CRC setting:
	; * we will enforce 128B block sizes,
	; * checksum vs. CRC is up to the receiver
	lda #<txt_xmodem
	ldy #>txt_xmodem
	jsr outstr
	lda #'/'
	jsr chrout
	lda #<txt_xmodem_crc
	ldy #>txt_xmodem_crc
	jsr outstr
	jmp @3
@upload_1k:
	; XMODEM-1K setting:
	; * we will enforce 128B block sizes,
	; * checksum vs. CRC is up to the receiver
	lda #<txt_xmodem_1k
	ldy #>txt_xmodem_1k
	jsr outstr
	jmp @3
@download:
	lda protoc
	cmp #PROTOCOL_XMODEM
	beq @download_old
	; XMODEM-CRC or XMODEM-1K setting:
	; * we will enforce CRC
	; * 128 vs. 1K is up to the sender
	lda #<txt_xmodem_crc
	ldy #>txt_xmodem_crc
	jsr outstr
	lda #'/'
	jsr chrout
	lda #<txt_xmodem_1k
	ldy #>txt_xmodem_1k
	jsr outstr
	jmp @3
@download_old:
	; XMODEM setting:
	; * we will enforce checkums
	; * 128 vs. 1K is up to the sender
	lda #<txt_xmodem
	ldy #>txt_xmodem
	jsr outstr
	jmp @3
@2:	lda #<txt_newpunter
	ldy #>txt_newpunter
	jsr outstr
@3:	lda #' '
	jsr chrout
	pla
	bne @4
	lda #<txt_up
	ldy #>txt_up
	clc
	bcc @5
@4:	lda #<txt_down
	ldy #>txt_down
@5:	jsr outstr
	lda #<txt_load
	ldy #>txt_load
	jsr outstr
;----------------------------------------------------------------------
ui_get_filename:
	ldx #0
:	lda #0
	sta inpbuf,x
	inx
	cpx #20
	bne :-
	lda #<txt_enter_filename
	ldy #>txt_enter_filename
	ldx #16
	jsr input
	php
	lda #CR
	jsr chrout
	plp
	rts

;----------------------------------------------------------------------
ui_abort:
	jsr clrchn
	lda #<txt_aborted
	ldy #>txt_aborted
	jsr outstr
	jsr text_color_restore
	jsr rs232_off
	lda #LFN_FILE
	jsr close
	jsr rs232_on
	jmp term_mainloop

;----------------------------------------------------------------------
xfermd	pha
	jmp xferm0

;----------------------------------------------------------------------
ui_setup_xfer_screen:
	pha
	lda #15
	sta textcl	; LT GRAY
	sta backgr	; make sure CLS fills will LT GRAY
	lda #CLR
	jsr chrout
	lda #BCOLOR
	sta backgr	; restore screen background color
xferm0	lda #13
	sta LINE
	lda #CR
	jsr chrout
	lda #6
	sta textcl
	ldx #40
	lda #192	; "─"
:	jsr chrout
	dex
	bne :-
	lda #<txt_yellow
	ldy #>txt_yellow
	jsr outstr
	pla
	bne @1
	lda #<txt_up
	ldy #>txt_up
	clc
	bcc @2
@1:	lda #<txt_down
	ldy #>txt_down
@2:	jsr outstr
	lda #<txt_loading
	ldy #>txt_loading
	jsr outstr
	ldy #0
:	lda inpbuf,y
	jsr chrout
	iny
	cpy max
	bne :-
	lda inpbuf,y
	jsr chrout
	lda inpbuf+1,y
	jsr chrout
	lda #CR
	jsr chrout
	lda #<txt_press_c_to_abort
	ldy #>txt_press_c_to_abort
	jmp outstr
margin:
	lda #<txt_good_bad_blocks
	ldy #>txt_good_bad_blocks
	jmp outstr

;----------------------------------------------------------------------
upltyp:
	.byte 0,'P','S','U'

;----------------------------------------------------------------------
handle_f1_upload:
	jsr col80_pause
	jsr supercpu_off
	jsr rs232_off
	jsr text_color_save
	lda #0
	sta mulcnt
	jsr ui_prompt_filename
	jeq ui_abort
	jsr ercopn
	ldy max
	lda #','
	sta inpbuf,y
	lda #'P'
	sta inpbuf+1,y
	jsr filtes
	beq uplfil
	ldy max
	lda #'S'
	sta inpbuf+1,y
	jsr filtes
	beq uplfil
	ldy max
	lda #'U'
	sta inpbuf+1,y
uplmen:
	jsr filtes
	beq uplfil
	pha
	ldx #LFN_DISK_CMD
	jsr chkin
	pla
	jmp drver3
uplfil:	ldy max
	ldx #3
:	lda upltyp,x
	cmp inpbuf+1,y
	beq :+
	dex
	bne :-
:	stx filetype
	jmp uplok

;----------------------------------------------------------------------
filtes:
	ldy max
	iny
	iny
	tya
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #LFN_FILE
	ldx device_disk
	ldy #0
	jsr setlfs
filopn:
	jsr open
	ldx #LFN_DISK_CMD
	jsr chkin
	jsr getin
	cmp #'0'
	beq :+
	php
	pha
	lda #LFN_FILE
	jsr close
	pla
	plp
:	rts

;----------------------------------------------------------------------
uplok:
	lda #0
	jsr ui_setup_xfer_screen
	jsr clrchn
	lda protoc
	beq :+		; PROTOCOL_PUNTER
	; XMODEM
	jsr crctable
	jsr margin
	jmp xmodem_upload

:	; PUNTER
	jsr rs232_clear
	jsr punter_reset
	jsr punter_trantype; transmit file type header
	lda inpbuf
	cmp #1
	bne :+		; not user cancelled
	jsr bell
	jmp ui_abort

:	jsr margin
	jsr punter_reset
	lda #$ff
	sta maxsize
	jsr punter_transmit; transmit file contents
xfrend:
	jsr rs232_off
	lda #LFN_FILE
	jsr close
	jsr clrchn
	lda #CR
	jsr chrout
	lda mulcnt
	beq :+
	rts
:	lda inpbuf
	cmp #1
	bne xfrdun
	jmp ui_abort
xfrdun:
	jsr reset	; clear and reenable
	jsr gong
	jmp term_mainloop

;----------------------------------------------------------------------
handle_f3_download:
	jsr col80_pause
	jsr rs232_off
	lda #0
	sta mulcnt
	jsr text_color_save
	jsr supercpu_off
	lda #1
	jsr ui_prompt_filename
	jeq ui_abort
	lda protoc
	beq :+		; PROTOCOL_PUNTER
	jsr prompt_file_type
	jmp dowmen
:	ldy max
	lda #160
	sta inpbuf,y
	sta inpbuf+1,y
dowmen:
	lda #1
	jsr ui_setup_xfer_screen
	ldx protoc
	bne @1		; != PROTOCOL_PUNTER
	lda inpbuf
	pha
	jsr clrchn
	jsr punter_reset; enable rs232 to receive;reset
	jsr punter_rectype; zero out punter buffers for new download and get file info from sender
	ldx inpbuf
	pla
	sta inpbuf
	lda mulcnt
	bne @1
	cpx #1
	bne @1
	jsr bell
	jmp ui_abort

@1:	ldx #$ff
	stx maxsize
	jsr rs232_off
	jsr ercopn
	ldx #LFN_DISK_CMD
	jsr chkout
	lda #'I'
	jsr chrout
	lda #'0'
	jsr chrout
	lda #CR
	jsr chrout
	jsr clrchn
	ldx #LFN_DISK_CMD
	jsr chkout
	lda #'S'
	jsr chrout
	lda #'0'
	jsr chrout
	lda #':'
	jsr chrout
	ldx #0
:	lda inpbuf,x
	jsr chrout
	inx
	cpx max
	bne :-
	lda #CR
	jsr chrout
	jsr dowsfn
	lda #1
	jsr xfermd
	jsr margin
	jmp dowopn

;----------------------------------------------------------------------
dowsfn:
	jsr clrchn
	ldx max
	lda #','
	sta inpbuf,x
	sta inpbuf+2,x
	inx
	lda #'W'
	sta inpbuf+2,x
	lda mulcnt
	bne :+
	ldy filetype
	lda upltyp,y
	sta inpbuf,x
:	lda max
	clc
	adc #$04
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #LFN_FILE
	ldx device_disk
	tay
	jmp setlfs

;----------------------------------------------------------------------
dowopn:
	jsr filopn
	beq :+
	pha
	ldx #LFN_DISK_CMD
	jsr chkin
	pla
	jmp drver3

:	lda protoc
	beq :+		; PROTOCOL_PUNTER
	jsr crctable	; create crc tables
	jmp xmodem_download; pick punter or xmodem here to really start downloading

:	jsr punter_reset; reset
	jsr punter_receive; get data
	jsr rs232_clear
	jmp xfrend	; close file

;----------------------------------------------------------------------
SET_PETSCII
txt_read_or_send:
	.byte CR,CR,WHITE,HILITE,"read or",HILITE,"send file? ",0
txt_read_or_send2:
	.byte "Space to pause - R/S to abort",CR,CR,0
SET_ASCII

;----------------------------------------------------------------------
handle_f2_send_read:
	ldx SHFLAG
	cpx #SHFLAG_CBM
	bne send
	jmp cf1_multi_send

;----------------------------------------------------------------------
; send text file
send:
	jsr col80_pause
	jsr rs232_off
	jsr text_color_save
	lda #<txt_read_or_send
	ldy #>txt_read_or_send
	jsr outstr
	jsr invert_csr_char
@loop:	jsr getin
	cmp #'S'
	bne @1
	ldx #$40	; flags: disk to modem, with delay
	bne @3
@1:	cmp #'R'
	bne @2
	ldx #0		; flags: disk screen, no delay
	beq @3
@2:	cmp #CR
	bne @loop
	jsr restore_csr_char
	lda #CR
	jsr chrout
@abt:	jmp ui_abort

@3:	ora #$80
	jsr outcap
	lda #CR
	jsr chrout
	stx bufflg	; flags: disk/mem, delay/no delay
	stx buffl2	; flags: send to modem
	jsr ui_get_filename
	beq @abt
	lda #CR
	jsr chrout
	jsr col80_resume
	lda max
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #<txt_read_or_send2
	ldy #>txt_read_or_send2
	jsr outstr
	lda #LFN_FILE
	ldx device_disk
	tay
	jsr setlfs
	jsr open
	jsr dskout
	lda #LFN_FILE
	jsr close
	lda #0
	jsr rs232_on
	jsr text_color_set
	lda #CR
	jsr chrout
	jmp term_mainloop

;----------------------------------------------------------------------
	.byte 0	; [XXX unused]

;----------------------------------------------------------------------
sleep_50ms:
	ldx #0
	stx JIFFIES
:	ldx JIFFIES
	cpx #3		; delay 1/20 sec
	bcc :-
	ldx #$ff
:	dex		; [XXX this delay is insignificant in comparison]
	bne :-
	rts
