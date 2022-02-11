;----------------------------------------------------------------------
txt_xmodem:
	.byte CR,CR,WHITE,cx,m,'ODEM ',0
txt_xmodem_crc:
	.byte CR,CR,WHITE,cx,m,'ODEM-crc ',0

;----------------------------------------------------------------------
; display "[protocol], enter name" and input string
ui_prompt_filename:
	pha
	lda protoc
	beq @2		; PROTOCOL_PUNTER
	cmp #PROTOCOL_XMODEM_CRC
	beq @1
	lda #<txt_xmodem
	ldy #>txt_xmodem
	jsr outstr
	jmp @3
@1:	lda #<txt_xmodem_crc
	ldy #>txt_xmodem_crc
	jsr outstr
	jmp @3
@2:	lda #<txt_newpunter
	ldy #>txt_newpunter
	jsr outstr
@3:	pla
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
	lda #$0d
	jsr chrout
	plp
	rts

;----------------------------------------------------------------------
ui_abort:
	jsr clrchn
	lda #<txt_aborted
	ldy #>txt_aborted
	jsr outstr
	jsr coback
	jsr disablexfer
	lda #$02
	jsr close
	jsr enablexfer
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
	lda #$0d
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
	jsr supercpu_off
	jsr disablexfer
	jsr cosave
	lda #0
	sta mulcnt
	jsr ui_prompt_filename
	jeq ui_abort
	jsr ercopn
	ldy max
	lda #','
	sta inpbuf,y
	lda #$50;'P'
	sta inpbuf+1,y
	jsr filtes
	beq uplfil
	ldy max
	lda #$53;'S'
	sta inpbuf+1,y
	jsr filtes
	beq uplfil
	ldy max
	lda #$55;'U'
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
	ldx #03
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
	lda #2
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
	lda #$02
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
	jsr clear232
	jsr punter_reset
	jsr p49164
	lda inpbuf
	cmp #1
	bne :+
	jsr bell
	jmp ui_abort

:	jsr margin
	jsr punter_reset
	lda #$ff
	sta maxsize
	jsr p49158
xfrend:
	jsr disablexfer
	lda #02
	jsr close
	jsr clrchn
	lda #$0d
	jsr chrout
	lda mulcnt
	beq :+
	rts
:	lda inpbuf
	cmp #$01
	bne xfrdun
	jmp ui_abort
xfrdun:
	jsr reset;clear and reenable
	jsr gong
	jmp term_mainloop

;----------------------------------------------------------------------
handle_f3_download:
	jsr disablexfer
	lda #0
	sta mulcnt
	jsr cosave
	jsr supercpu_off
	lda #1
	jsr ui_prompt_filename
	jeq ui_abort
	lda protoc
	beq :+		; PROTOCOL_PUNTER
	jsr xmotyp
	jmp dowmen
:	ldy max
	lda #160
	sta inpbuf,y
	sta inpbuf+1,y
dowmen:
	lda #01
	jsr ui_setup_xfer_screen
	ldx protoc
	bne @1		; != PROTOCOL_PUNTER
	lda inpbuf
	pha
	jsr clrchn
	jsr punter_reset	; enable rs232 to receive;reset
	jsr p49161		; zero out punter buffers for new download and get file info from sender
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
	jsr disablexfer
	jsr ercopn
	ldx #LFN_DISK_CMD
	jsr chkout
	lda #'I'
	jsr chrout
	lda #'0'
	jsr chrout
	lda #$0d
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
	lda #$0d
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
	lda #02
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
	jsr p49155	; get data
	jsr clear232
	jmp xfrend	; close file

;----------------------------------------------------------------------
txt_read_or_send:
	.byte CR,CR,WHITE,2,'READ OR',2,'SEND FILE? ',00
txt_read_or_send2:
	.byte 'sPACE TO PAUSE - r/s TO ABORT',CR,CR,00

;----------------------------------------------------------------------
handle_f2_send_read:
	ldx SHFLAG
	cpx #SHFLAG_CBM
	bne send
	jmp cf1

;----------------------------------------------------------------------
; send text file
send
	jsr disablexfer
	jsr cosave
	lda #<txt_read_or_send
	ldy #>txt_read_or_send
	jsr outstr
	jsr savech
sndlop
	jsr getin
	cmp #'S'
	bne @1
	ldx #$40
	bne @3
@1:	cmp #'R'
	bne @2
	ldx #0
	beq @3
@2:	cmp #$0d
	bne sndlop
	jsr restch
	lda #$0d
	jsr chrout
@abt:	jmp ui_abort

@3:	ora #$80
	jsr outcap
	lda #$0d
	jsr chrout
	stx bufflg
	stx buffl2
	jsr ui_get_filename
	beq @abt
	lda #$0d
	jsr chrout
	lda max
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #<txt_read_or_send2
	ldy #>txt_read_or_send2
	jsr outstr
	lda #2
	ldx device_disk
	tay
	jsr setlfs
	jsr open
	ldx #LFN_MODEM
	jsr chkout
	;lda #15
	;jsr chrout
	jsr dskout
	lda #2
	jsr close
	lda #0
	jsr enablexfer
	jsr cochng
	lda #$0d
	jsr chrout
	jmp term_mainloop

;----------------------------------------------------------------------
	.byte 0	; [XXX unused]

;----------------------------------------------------------------------
tmsetl:
	ldx #0
	stx JIFFIES
:	ldx JIFFIES
	cpx #$03  ;***time del
	bcc :-
	ldx #255
:	dex
	bne :-
	rts
