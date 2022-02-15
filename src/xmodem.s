; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz, Michael Steil. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; XMODEM, XMODEM-CRC and XMODEM-1K Send and Receive
;

MAX_RETRIES		= 10
PAYLOAD_SIZE_128	= 128
PAYLOAD_SIZE_1K		= 1024

; KERNAL
STATUS	= $90	; channel I/O error/EOF indicator
RIDBE = $029b
RIDBS = $029c
RODBS = $029d
RODBE = $029e

; protocol constants
SOH	= $01	; Start of Heading
STX_	= $02	; Start of Heading (1K blocks)
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
;  protoc	protocol (XMODEM, -CRC, -1K)
;  buffer	contains 3 XMODEM buffers

_enablexfer = reset

xmstat	.byte 0		; final error code
xmoblk	.byte 0		; current block index
xmochk	.byte 0		; checksum
xmobad	.byte 0		; error counter
xmodel	.byte 0		; receive timeout
xmoend	.byte 0		; send: EOT flag (and EOT send counter), receive: protocol error counter
xmostk	.byte $ff	; stack pointer


;----------------------------------------------------------------------
; SEND
; * The sender picks the block size - we use the "protoc" setting.
; * The receiver picks checksum vs. CRC, we support both.
;----------------------------------------------------------------------
;
;                     | Receiver: checksum | Receiver: CRC  |
;---------------------|--------------------|----------------|
; Setting: XMODEM     | 128 checksum       | 128 CRC16      |\sa
; Setting: XMODEM-CRC | 128 checksum       | 128 CRC16      |/me
; Setting: XMODEM-1K  | 1K checksum        | 1K CRC16       |
;
; If the receiver does not support 1K, we *could* fall back to 128B, but
; this would be tricky:
; * A receiver that understands the "STX" code for 1K doesn't ACK it; it
;   just keeps receiving the block and ACKs at the end.
; * A receiver that does not understand the "STX" code just ignores it,
;   receiving more bytes and hoping for a SOH, EOT or CAN.
; Therefore, it's tricky to detect whether a receiver supports 1K blocks.
; The common way of doing a fallback is to do a full retry with a 128B
; after sending the 1K block, but:
; * this is slow
; * would require lots of extra logic to send the 1 KB worth of buffer
;   contents as eight 128B blocks, since we can't rewind the source file.
;----------------------------------------------------------------------
xmodem_send:
	; save stack pointer
	tsx
	stx xmostk

	jsr init_transfer
	jsr _enablexfer

	lda protoc
	cmp #PROTOCOL_XMODEM_1K
	bne @b128
	lda #0
	ldx #>PAYLOAD_SIZE_1K
	bne @contsz
@b128:	lda #PAYLOAD_SIZE_128
	ldx #1
@contsz:
	sta firstpagebytes
	stx pagectr

; expect NAK (chksum) or 'C' (CRC)
@loop:
	lda #6		; 60 secs
	jsr modem_get
	beq :+
@abort:	jmp xmabrt	; timeout -> cancelled
:	cmp #CAN
	beq @abort	; CAN -> cancelled
	cmp #NAK
	beq @nakok
	cmp #CRC
	bne @loop
@nakok:	sta xprotoc

@block_loop:
	jsr setup_buffer
	ldy #0
	sty xmoend	; reset EOT flag
	sty xmobad	; init error counter

	jsr disablexfer

; read block into buffer
	ldx #LFN_FILE
	jsr chkin

	lda pagectr
	sta tmppagectr
	jsr crcinit

	ldy #0
@snd2:	jsr getin	; read from file
	ldx STATUS
	stx xmoend	; set EOT flag if end of file (or error)
@snd3:	jsr store_byte
	bne :+
	inc xmobuf+1
	dec tmppagectr
	beq @snd5
:	ldx xmoend	; end of file?
	beq @snd2	; no, next byte

	lda #CPMEOF	; EOF (or error)
	bne @snd3	; -> fill with end of file code

@snd5:
	jsr clrchn

@send_again:
	jsr clear_buffers
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout

; send block header
	lda #SOH
	ldx protoc
	cpx #PROTOCOL_XMODEM_1K
	bne :+
	lda #STX_
:	jsr chrout	; 0: SOH/STX (128/1K)
	lda xmoblk
	jsr chrout	; 1: block index
	eor #$ff
	jsr chrout	; 2: block index ^ $FF

	jsr setup_buffer

	ldx pagectr
	ldy #0
:	lda (xmobuf),y
	jsr chrout
	iny
	cpy firstpagebytes
	bne :-
	inc xmobuf+1
	dex
	bne :-

	lda xprotoc
	cmp #CRC
	bne @ncrc

; send CRC
	lda crcz+1
	jsr chrout
	lda crcz
	jmp @send_crc_cont
@ncrc:
	lda xmochk
@send_crc_cont:
	jsr chrout

	jsr clrchn
	jsr clear_input_buffer

; expect CAN
	lda #3		; timeout
	jsr modem_get
	bne @snbd	; error
	cmp #CAN
	bne @snd8
	jmp xmabrt	; CAN -> cancelled

@snd8:	cmp #NAK
	bne @snd9

@snbd:
	jsr chrout	; ??? send to screen?
	jmp @send_again	; NAK -> send again

@snd9:	cmp #ACK
	bne @snbd	; error

; receiver ACK'ed the block
	lda #'-'
	jsr goobad

	ldx xmoend	; was the end of the file reached?
	bne :+		; yes

	inc xmoblk	; next block index
	jmp @block_loop

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
crcinit:
	; init checksum
	lda #0
	sta xmochk
	; init crc
	sta crcz
	sta crcz+1
	rts

;----------------------------------------------------------------------
init_effect:
	; init screen effect
	lda #<$0400
	sta scrptr
	lda #>$0400
	sta scrptr+1
	rts

; store and checksum/CRC
store_byte:
	; store
	sta (xmobuf),y
	; screen effect
scrptr=*+1
	sta $ffff
	; calc checksum
	pha
	clc
	adc xmochk
	sta xmochk
	pla
	; quick crc computation with lookup tables
	eor crcz+1
	tax
	lda crcz
	eor crchi,x
	sta crcz+1
	lda crclo,x
	sta crcz
	; update screen effect
	inc scrptr
	bne :+
	inc scrptr+1
:	lda scrptr
	cmp #<($0400+14*40)
	bne :+
	lda scrptr+1
	cmp #>($0400+14*40)
	bne :+
	jsr init_effect
:	; increment and compare
	iny
firstpagebytes=*+1
	cpy #$00
	rts

;----------------------------------------------------------------------
init_transfer:
	jsr init_effect
	lda #1
	sta xmoblk	; start block index
	lda #0
	sta xmobad
;----------------------------------------------------------------------
setup_buffer:
	lda #<xmodem_buffer
	sta xmobuf
	lda #>xmodem_buffer
	sta xmobuf+1
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
modem_get_1:
	lda #1
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

; clear garbage off stack
	ldx xmostk
	txs

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
; * The sender picks the block size, we support 128 and 1K.
; * The receiver picks checksum vs. CRC.
;
;                     | Sender: 128  | Sender: 1K  |
;---------------------|--------------|-------------|
; Setting: XMODEM     | 128 checksum | 1K checksum |
; Setting: XMODEM-CRC | 128 CRC16    | 1K CRC16    |\sa
; Setting: XMODEM-1K  | 128 CRC16    | 1K CRC16    |/me
;
;----------------------------------------------------------------------
xmodem_receive:
	tsx
	stx xmostk

	; set block size & checksum based on protocol
	lda #NAK	; XMODEM: send NAK before first block
	ldx protoc
	cpx #PROTOCOL_XMODEM
	beq :+
	lda #CRC	; XMODEM-CRC and -1K: send 'C' before first block
:	sta @receive_nak_code

	jsr _enablexfer
	jsr init_transfer
	jmp :+
@retry1:	; receive error
	jsr count_bad
:	lda #0
	sta xmoend	; reset EOT counter

@retry2:
	jsr clear232
	jsr enablexfer
	ldx #LFN_MODEM
	jsr chkout

@receive_nak_code = *+1
	lda #NAK
	jsr chrout
	jsr clrchn

; block loop
@bloop:	jsr modem_get_1
	beq @3		; ok

@error:	inc xmoend	; count protocol errors
	lda xmoend
	cmp #MAX_RETRIES
	bcc @retry2	; loop
@abort:	jmp xmabrt	; cancelled

@3:	cmp #CAN	; cancel?
	beq @abort
	cmp #EOT	; end of transmission
	bne @neot

	lda #1
	sta xmoend	; EOT!
	jmp @ackblk	; send ACK, end

@neot:	cmp #SOH
	bne @nsoh

	lda #PAYLOAD_SIZE_128
	ldx #1
	bne @contsz

@nsoh:	cmp #STX_
	bne @error	; no -> protocol error

	lda #0
	ldx #>PAYLOAD_SIZE_1K

@contsz:
	sta firstpagebytes
	stx pagectr
	stx tmppagectr

; get block index and duplicate
	jsr modem_get_1
	bne @retry1
	sta block_index
	jsr modem_get_1
	bne @retry1
	sta nblock_index

	jsr crcinit
	jsr setup_buffer
	ldy #0
	sty xmoend	; reset EOT flag

@rloop:	jsr modem_get_1
	jne @retry1	; error
	jsr store_byte
	bne @rloop

	inc xmobuf+1
	dec tmppagectr
	bne @rloop

; validate block index from duplicate
	lda block_index
	eor nblock_index; block index ^ $FF
	cmp #$ff
	jne @retry1	; incorrect

	jsr modem_get_1	; checksum byte or first CRC byte
	jne @retry1

	ldx protoc
	cpx #PROTOCOL_XMODEM
	beq @old_chksum

; CRC check for XMODEM-CRC or -1K receive
	pha
	jsr modem_get_1	; second CRC byte
	jne @retry1

	cmp crcz
	bne @bad
	pla
	cmp crcz+1
	beq @chksum_cont
@bad:	jmp @retry1

; compare old XMODEM checksum
@old_chksum:
	cmp xmochk	; compare with transmitted checksum
	jne @retry1	; incorrect

; check whether it's the expected block, a re-send, or the wrong block
@chksum_cont:
	jsr disablexfer

	lda block_index
	cmp xmoblk	; expected block?
	beq @okblk	; yes

	ldx xmoblk
	dex
	txa
	cmp block_index	; is it the preceding block again?
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
	jsr setup_buffer
	ldx #LFN_FILE
	jsr chkout
	ldx pagectr
	ldy #0
:	lda (xmobuf),y
	jsr chrout
	iny
	cpy firstpagebytes
	bne :-
	inc xmobuf+1
	dex
	bne :-

@next:	lda #0
	sta xmoend	; reset error counter
	inc xmoblk	; expect next block
	jsr clrchn
	lda #'-'	; good block
	jsr goobad

@ackblk:
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

; does not belong to XMODEM source
.include "filetype.s"

;----------------------------------------------------------------------
; error messages
SET_PETSCII
msg_cancelled:
	.byte CR,"Transfer Cancelled.",0
msg_no_eto_ack:
	.byte CR,"EOT Not Acknowleged.",0
msg_max_retries:
	.byte CR,"Too Many Bad Blocks!",0
msg_sync_lost:
	.byte CR,"Sync Lost!",0
SET_ASCII

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

xprotoc:
	.res 1
pagectr:
	.res 1
tmppagectr:
	.res 1
block_index:
	.res 1
nblock_index:
	.res 1
; used for temprarily storing the two CRC bytes
crcz:
	.res 2
