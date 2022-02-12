; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; XMODEM and XMODEM/CRC Send and Receive
;

MAX_RETRIES	= 10
PAYLOAD_SIZE	= 128
BLOCK_SIZE_XMODEM	= PAYLOAD_SIZE+4
BLOCK_SIZE_XMODEM_CRC	= PAYLOAD_SIZE+5

; KERNAL
STATUS	= $90	; channel I/O error/EOF indicator
RIDBE = $029b
RIDBS = $029c
RODBS = $029d
RODBE = $029e

; protocol constants
SOH	= $01	; Start of Heading
EOT	= $04	; End of Transmission
ACK	= $06	; Acknowledge
NAK	= $15	; Negative Acknowledge
CAN	= $18	; Cancel
CRC	= 'C'	; sent by receiver as first char instead of NAK to indicate CRC instead of checksum
CPMEOF	= $1a	; CP/M EOF character

; final status of the transfer
STAT_OK			= 0 ; transfer OK
STAT_CANCELLED		= 1 ; peer sent CAN or didn't respond in time
STAT_NO_EOT_ACK		= 2 ; during send, receiver did not ack the EOT signal
STAT_MAX_RETRIES	= 3 ; too many errors retrying receiving a block
STAT_SYNC_LOST		= 4 ; sender sent the wrong block
STAT_USER_ABORTED	= 5 ; the user aborted the transfer

; memory
xmobuf	= $fd	; zero page pointer to access the buffer
xmoscn	= buffer; 3 send and receiver buffers
crcz	= $cb00	; used for temprarily storing the two CRC bytes

; uses the following KERNAL calls:
;  chkin
;  chkout
;  chrout
;  close
;  clrchn
;  getin

; calls from outside code:
;  xmodem_download	download, will jump back to main
;  xmodem_upload	upload, will jump back to main
;  xmmrtc		increment counter, generic code
; symbols used from outside code
;  xmodel		receive timeout, reused var
;  rtca0		counter, see xmmrtc
;  rtca2		 "
;  rtca1		 "

; uses the following CCGMSTERM symbols:
;  ui_abort	jumped to after a transfer has failed or was user-aborted
;  gong		play sound when printing error
;  xfrdun	jumped to after a transfer has succeeded
;  outstr	print error message
;  clear232	clear buffer
;  modget	receive byte
;  goobad	show transmission status "key" to user
;  crclo	pre-computed crc table
;  crchi	pre-computed crc table
;  enablexfer	enable serial driver
;  disablexfer	disable serial driver
;  reset	same as "enablexfer" (no punter dep)
;  protoc	protocol flag: 0: XMODEM, 1: XMODEM/CRC
;  buffer	contains 3 XMODEM buffers

_enablexfer = reset

xmstat	.byte 0		; final error code
xmoblk	.byte 0		; current block index
xmochk	.byte 0		; checksum
xmobad	.byte 0		; error counter
xmowbf	.byte 0		; buffer 0-3
xmodel	.byte 0		; receive timeout
xmoend	.byte 0		; send: EOT flag (and EOT send counter), receive: protocol error counter
xmostk	.byte $ff	; stack pointer


;----------------------------------------------------------------------
; SEND
;----------------------------------------------------------------------
xmodem_send:
	; save stack pointer
	tsx
	stx xmostk

	jsr init_transfer
	jsr _enablexfer

	; set code & block size based on protocol
	lda protoc
	cmp #PROTOCOL_XMODEM
	beq @1
	lda #CRC
	ldx #BLOCK_SIZE_XMODEM_CRC
	jmp @2
@1:	lda #NAK
	ldx #BLOCK_SIZE_XMODEM
@2:	sta @send_nak_code
	stx send_block_size

; expect NAK
@loop:
	lda #6		; 60 secs
	jsr modem_get
	beq :+
@abort:	jmp xmabrt	; timeout -> cancelled
:	cmp #CAN
	beq @abort	; CAN -> cancelled
@send_nak_code = *+1
	cmp #NAK
	bne @loop

send_loop:
	jsr setup_buffer
	sty xmobad	; init error counter

; generate block header
	lda #SOH
	sta (xmobuf),y	; 0: SOH
	iny
	lda xmoblk
	sta (xmobuf),y	; 1: block index
	iny
	eor #$ff
	sta (xmobuf),y	; 2: block index ^ $FF
	iny

	jsr disablexfer

; read block into buffer
	ldx #LFN_FILE
	jsr chkin

@snd2:	jsr getin	; read from file
	ldx STATUS
	stx xmoend	; set EOT flag if end of file (or error)
@snd3:	sta (xmobuf),y
	clc
	adc xmochk
	sta xmochk	; calc checksum
	iny
	cpy #BLOCK_SIZE_XMODEM-1
	bcs @snd5
	ldx xmoend	; end of file?
	beq @snd2	; no, next byte

	lda #CPMEOF	; EOF (or error)
	bne @snd3	; -> fill with end of file code

@snd5:	sta (xmobuf),y	; store checksum as last byte

	jsr clrchn

xmsnd6	jsr clear_buffers
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout

	; checksum calculation patch for XMODEM-CRC
	; [XXX the should be done *before* xmsnd6, otherwise CRC]
	; [XXX gets calculated again for a re-send              ]
	lda protoc
	cmp #PROTOCOL_XMODEM_CRC
	beq send_crc_patch

; send all block bytes to modem
send_crc_cont:
	ldy #0
:	lda (xmobuf),y
	jsr chrout
	iny
send_block_size = *+1
	cpy #BLOCK_SIZE_XMODEM	; *will be overwritten*
	bcc :-

	jsr clrchn
	jsr clear_input_buffer

; expect CAN
	lda #3		; timeout
	jsr modem_get
	bne xmsnbd	; error
	cmp #CAN
	bne xmsnd8
	jmp xmabrt	; CAN -> cancelled

; [XXX this code is at a very awkward location, could be integrated better]
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; put CRC into block
send_crc_patch:
	jsr calccrc
	ldy #BLOCK_SIZE_XMODEM-1
	lda crcz+1
	sta (xmobuf),y
	iny
	lda crcz
	sta (xmobuf),y
	jmp send_crc_cont

; calculate CRC using tables
calccrc:
	lda #0		; yes, calculate the crc for the 128 bytes
	sta crcz
	sta crcz+1
	ldy #3		; start offset in block
:	lda (xmobuf),y
	eor crcz+1 	; quick crc computation with lookup tables
	tax 	 	; updates the two bytes at crc & crc+1
	lda crcz	; with the byte send in the "a" register
	eor crchi,x
	sta crcz+1
	lda crclo,x
	sta crcz
	iny
	cpy #PAYLOAD_SIZE+3
	bne :-
	rts
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

xmsnd8	cmp #NAK
	bne xmsnd9

xmsnbd
	jsr chrout	; ??? send to screen?
	jmp xmsnd6	; NAK -> send again

xmsnd9	cmp #ACK
	bne xmsnbd	; error

; receiver ACK'ed the block
xmsnnx
	lda #'-'
	jsr goobad

	ldx xmoend	; was the end of the file reached?
	bne :+		; yes

	inc xmoblk	; next block index
	inc xmowbf	; next buffer
	jmp send_loop

:	lda #0
	sta xmoend	; reset EOT flag

; send EOT
@sne1:
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout
	lda #EOT
	jsr chrout	; send EOT
	lda #3		; timeout
	jsr modem_get
	bne :+
	cmp #ACK	; ACK received!
	bne :+
	jmp xmfnok	; set status: OK

:	inc xmoend
	lda xmoend
	cmp #MAX_RETRIES
	bcc @sne1	; retries...
	jmp xmneot	; set status: no EOT ack


;----------------------------------------------------------------------
init_transfer:
	lda #1
	sta xmoblk	; start block index
	lda #0
	sta xmowbf	; start buffer
	sta xmobad
;----------------------------------------------------------------------
setup_buffer:
	lda xmowbf	; buffer mod 3
	and #3
	sta xmowbf
	lda #<xmoscn	; set buffer
	sta xmobuf
	lda #>xmoscn
	sta xmobuf+1
	ldx xmowbf
	beq @skip

@loop:	lda xmobuf	; calc buffer start address: xmowbf * BLOCK_SIZE_XMODEM_CRC
	clc
	adc #BLOCK_SIZE_XMODEM_CRC
	sta xmobuf
	lda xmobuf+1
	adc #0
	sta xmobuf+1
	dex
	bne @loop

@skip:	ldy #0
	sty xmochk	; init checksum
	sty xmoend	; reset EOT flag
	rts

;----------------------------------------------------------------------
clear_buffers:
	lda RODBS	; clear rs232 output
	sta RODBE
;----------------------------------------------------------------------
clear_input_buffer:
	lda RIDBE	; and input buffers
	sta RIDBS
	rts

;----------------------------------------------------------------------
; get modem byte with timeout
modem_get:
	sta xmodel
	lda #0
	sta rtca1
	sta rtca2
	sta rtca0

@1:	jsr modget	; receive byte
	bcs :+
	ldx #0		; ok
	rts
:	jsr xchkcm	; check for keyboard abort
	jsr xmmrtc
	lda rtca0
	cmp xmodel
	bcc @1

	; timeout
	jsr clrchn
	and #0
	ldx #1
	rts

;----------------------------------------------------------------------
; timeout counter
RTCMOD = 72271		; ???
xmmrtc
	ldx #0
	inc rtca2
	bne @1
	inc rtca1
	bne @1
	inc rtca0
@1:	sec
	lda rtca2
	sbc #RTCMOD >> 16
	lda rtca1
	sbc #>RTCMOD
	lda rtca0
	sbc #<RTCMOD
	bcc @2
	stx rtca0
	stx rtca1
	stx rtca2
@2:	rts

rtca1	.byte 0
rtca2	.byte 0
rtca0	.byte 0

;----------------------------------------------------------------------
; increment number of retries, and abort if maximum reached
count_bad:
	lda #':' ; BAD
	jsr goobad
	inc xmobad
	lda xmobad
	cmp #MAX_RETRIES
	bcs xmtrys	; max retries reached
	rts

;----------------------------------------------------------------------
; test for CBM key pressed (abort transfer)
xchkcm
	ldx SHFLAG
	cpx #SHFLAG_CBM
	beq xmcmab
	rts

;----------------------------------------------------------------------
; set final status and clean up
xmfnok	lda #'*' ; GOOD
	jsr goobad
	lda #STAT_OK
	.byte $2c
xmabrt	lda #STAT_CANCELLED
	.byte $2c
xmneot	lda #STAT_NO_EOT_ACK
	.byte $2c
xmtrys	lda #STAT_MAX_RETRIES
	.byte $2c
xmsync	lda #STAT_SYNC_LOST
	.byte $2c
xmcmab	lda #STAT_USER_ABORTED
	sta xmstat

; clear garbage off stack [XXX just assign S; this is copied from punter]
:	tsx
	cpx xmostk
	beq :+
	pla
	clc
	bcc :-

:	jsr clear_buffers

	lda xmstat
	cmp #STAT_SYNC_LOST
	bcc @ex4

	; send CAN if STAT_SYNC_LOST and STAT_USER_ABORTED
	jsr _enablexfer
	ldx #LFN_MODEM
	jsr chkout

	ldy #8
	lda #CAN
:	jsr chrout
	dey
	bpl :-		; 9x CAN

@ex4:	jsr clrchn
	jsr disablexfer
	lda #LFN_FILE
	jmp close	; close file on disk


;----------------------------------------------------------------------
; RECEIVE
;----------------------------------------------------------------------
xmodem_receive:
	tsx
	stx xmostk
	jsr _enablexfer
	jsr init_transfer
	beq :+	; always
retry1	; receive error
	jsr count_bad
:	lda #0
	sta xmoend	; reset EOT counter

retry2:	jsr clear232
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout

	; set block size & code based on protocol
	; [XXX this should be done before the block loop]
	lda protoc
	cmp #PROTOCOL_XMODEM
	beq @1
	lda #CRC	; XMODEM/CRC: send 'C' insteaf of NAK before first block
	ldx #BLOCK_SIZE_XMODEM_CRC
	jmp @2
@1:	lda #NAK
	ldx #BLOCK_SIZE_XMODEM
@2:	sta @receive_nak_code
	stx @receive_block_size

@receive_nak_code = *+1
	lda #NAK
	jsr chrout
	jsr clrchn

; block loop
@bloop:	lda #1		; no timeout!
	jsr modem_get
	beq @3		; ok

@error:	inc xmoend	; count protocol errors
	lda xmoend
	cmp #MAX_RETRIES
	bcc retry2	; loop
@abort:	jmp xmabrt	; cancelled

@3:	cmp #CAN	; cancel?
	beq @abort
	cmp #EOT	; end of transmission
	bne @neot

	lda #1
	sta xmoend	; EOT!
	jmp @ackblk	; send ACK, end

@neot:	cmp #SOH
	bne @error	; no -> protocol error

	jsr setup_buffer
	beq :+		; always - skip writing first byte
	; y is 0 now
@rloop:	lda #1
	jsr modem_get
	bne retry1	; error
:	sta (xmobuf),y
	iny
@receive_block_size = *+1
	cpy #BLOCK_SIZE_XMODEM	; *will be overwritten*
	bcc @rloop

; validate block index from duplicate
	ldy #1
	lda (xmobuf),y	; block index
	iny
	eor (xmobuf),y	; block index ^ $FF
	cmp #$ff
	bne retry1	; incorrect

	jsr disablexfer

	lda protoc
	cmp #PROTOCOL_XMODEM_CRC
	jeq @receive_crc_patch

; calculate & compare old XMODEM checksum
	lda #0
:	iny
	cpy #BLOCK_SIZE_XMODEM-1
	bcs :+
	adc (xmobuf),y
	clc
	bcc :-

:	sta xmochk	; save chacksum
	cmp (xmobuf),y	; compare with transmitted checksum
	jne retry1	; incorrect

; check whether it's the expected block, a re-send, or the wrong block
@receive_crc_cont:
	ldy #1		; offset of
	lda (xmobuf),y	; block index
	cmp xmoblk	; expected block?
	beq @okblk	; yes

	ldx xmoblk
	dex
	txa
	cmp (xmobuf),y	; is it the preceding block again?
	bne @xmorsa	; no, sync error

	; sender misunderstood our ACK, did a re-send;
	; we can just ignore the block
	lda #'/' ; duplicate block
	jsr goobad
	jmp @next

@xmorsa	jmp xmsync	; sync error

; we just received the next block intact
@okblk:	jsr clrchn
	jsr disablexfer

; write payload to disk
	ldx #LFN_FILE
	jsr chkout
	ldy #3
:	lda (xmobuf),y
	jsr chrout
	iny
	cpy #PAYLOAD_SIZE+3
	bcc :-

@next:	lda #0
	sta xmoend	; reset error counter
	inc xmoblk	; expect next block
	jsr clrchn
	lda #'-'	; good block
	jsr goobad

@ackblk	inc xmowbf	; next buffer
	jsr clear232

; send ACK
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout
	lda #ACK
	jsr chrout
	jsr clrchn

	lda #0
	sta xmobad	; reset bad block counter
	lda xmoend
	bne :+		; EOT!
	jmp @bloop	; next block

:	jmp xmfnok	; end of file, send * key

; [XXX this code is at an awkward location, could be integrated better]
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; CRC check for XMODEM/CRC receive
@receive_crc_patch:
	jsr calccrc
	ldy #BLOCK_SIZE_XMODEM-1
	lda crcz+1		; save hi byte of crc to buffer
	cmp (xmobuf),y		;
	bne @badcrc
	iny			;
	lda crcz		; save lo byte of crc to buffer
	cmp (xmobuf),y
	bne @badcrc
	jmp @receive_crc_cont
@badcrc	jmp retry1
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

; does not belong to XMODEM source
.include "filetype.s"

;----------------------------------------------------------------------
; error messages
msg_cancelled:
	.byte CR,"tRANSFER cANCELLED.",0
msg_no_eto_ack:
	.byte CR,"eot nOT aCKNOWLEGED.",0
msg_max_retries:
	.byte CR,"tOO mANY bAD bLOCKS!",0
msg_sync_lost:
	.byte CR
	.byte 'C'+128 ; [XXX this should not be here]
	.byte "sYNC lOST!",0

;----------------------------------------------------------------------
; *** upload: send, handle status
xmodem_upload
	jsr xmodem_send	; send
	jmp xmodon

;----------------------------------------------------------------------
; *** download: receive, handle status
xmodem_download:
	jsr xmodem_receive	; receive
xmodon
	lda #CR
	jsr chrout
	lda xmstat
	bne :+		; success
	jmp xfrdun

:	cmp #STAT_USER_ABORTED
	beq xmodna	; error-return with no message
	cmp #STAT_CANCELLED
	bne xmodn3
	lda #<msg_cancelled
	ldy #>msg_cancelled
	bne xmodnp
xmodn3
	cmp #STAT_NO_EOT_ACK
	bne xmodn4
	lda #<msg_no_eto_ack
	ldy #>msg_no_eto_ack
	bne xmodnp
xmodn4	cmp #STAT_MAX_RETRIES
	bne xmodn5
	lda #<msg_max_retries
	ldy #>msg_max_retries
	bne xmodnp
xmodn5
	lda #<msg_sync_lost
	ldy #>msg_sync_lost
xmodnp
	jsr outstr
	jsr gong
	lda #CR
	jsr chrout
xmodna
	jmp ui_abort
