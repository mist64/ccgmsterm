; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Initialization
;

; PAL/NTSC detection
start:
@1:	lda $d012
@2:	cmp $d012
	beq @2
	bmi @1
	cmp #$20
	bcc :+		; NTSC
	ldx #1
	stx is_pal_system
:

; SuperCPU detection
; "it should just tell you to turn that shit off.
;  who needs 20MHz for 9600 baud, anyway?"
	lda $d0bc
	asl a
	bcs :+
	lda #1
	sta supercpu
:

; system setup
	jsr $e3bf	; refresh basic reset - mostly an easyflash fix
	sei
	cld
	ldx #$ff
	txs
	lda #$2f
	sta $00
	lda #$37
	sta $01

; editor/screen setup
	lda #1
	sta BLNSW	; disable cursor blinking
	lda #BCOLOR
	sta backgr
	sta border
	lda #TCOLOR
	sta textcl

	lda #$80
	sta RPTFLA	; key repeat on
	lda #$0e
	sta $d418	; *almost* full volume

; clear secondary screens
	lda #<SCREENS_BASE
	sta locat
	lda #>SCREENS_BASE
	sta locat+1
	lda #>$2000
	ldy #0
:	sta (locat),y
	iny
	bne :-
	inc locat+1
	bne :-

	cli

; find first disk drive
	lda FA		; current dev#
	jmp @dsk1
@loop:	inc device_disk
	lda device_disk
	cmp #16		; try #30 here for top drive #?
	beq :+
	jmp @dsk1
:	lda #0
	sta drive_present; we have no drives
	lda #8
	sta device_disk
	jmp @dsk2
@dsk1:	sta device_disk
	jsr is_drive_present
	bmi @loop
	lda #1
	sta drive_present; we have a drive!
@dsk2:

; REU detection
	lda easyflash_support
	beq @ef1	; skip REU detection if we have EasyFlash
	jsr noreu
	jmp @ef2
@ef1:
	jsr reu_detect
@ef2:

; init. buffer & open rs232
	lda newbuf
	sta buffer_ptr
	lda newbuf+1
	sta buffer_ptr+1

	jsr rsopen
	jsr ercopn
	jmp init	; [XXX the next two functions are in the way]

;----------------------------------------------------------------------
; open rs232 file
; [XXX This used to open a channel on device #2, which most serial ]
; [XXX communication went through. Now, this doesn't do much any   ]
; [XXX more, but it's still called from several places, which is   ]
; [XXX probably not necessary.                                     ]
; [XXX It needs to be called once though ("jsr rsopen" above!) to  ]
; [XXX init the RS232 dispatch jump table.                         ]
rsopen:
	jsr enablemodem
	jsr clall
	jsr disablemodem
	rts		; [XXX jmp]

;----------------------------------------------------------------------
ercopn:
	lda drive_present
	beq :+
	lda #2;file length      ;open err chan
	ldx #<filename_i0
	ldy #>filename_i0
	jsr setnam
	lda #15
	ldx device_disk
	tay
	jsr setlfs
	jsr open
:	rts

;----------------------------------------------------------------------
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
	lda config_file_loaded; already loaded config file?
	bne @noload
	lda drive_present
	beq @noload	; no drive exists

; load config file from disk
	jsr disablemodem
	lda #1
	sta config_file_loaded
	ldx #<filename_config
	ldy #>filename_config
	lda #11
	jsr setnam
	lda #2
	ldx device_disk
	ldy #0
	jsr setlfs
	jsr load_config_file

	jmp term_entry_first

@noload=term_entry_first	; [XXX]
