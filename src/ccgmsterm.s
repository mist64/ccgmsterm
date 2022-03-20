; CCGMS Terminal
;
; Copyright (c) 2016,2022, Craig Smith, alwyz, Michael Steil. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Main .s file
;

	.feature labels_without_colons
	.feature string_escapes
	.macpack longbranch

; RS232 driver API
.include "../rs232lib/rs232.inc"
; symbols required by rs232lib
.export modem_type, baud_rate, is_pal_system	; modem settings
.export ribuf, revtabup				; buffer, temp storage

; 80columns
.import col80_init, col80_set_charset, col80_on, col80_off, col80_resume, col80_pause
.import col80_wait
.import col80_active, col80_bg_update
.import col80_read_scr_chr, col80_read_scr_col
.export locat, nlocat   ; for 80col

.define VERSION "0.2"

	.include "declare.inc"
	.include "encoding.inc"

.segment "HEADER"
	.word $0801	; PRG load address

.segment "CODE"

	.word next_line
easyflash_support:	; encode EasyFlash support into the BASIC line number
	.word EASYFLASH	; 0 SYS2061 -> no EasyFlash; 1 SYS2061 -> EasyFlash
	.byte $9e,"2061"
	.word 0
next_line:
	.byte 0

.assert * = 2061, error
.assert * = start, error
	.include "init.s"
	.include "terminal.s"
	.include "sound.s"
	.include "screens.s"
	.include "banner.s"
	.include "dir.s"
	.include "ansi.s"
	.include "cursor.s"
	.include "input.s"
	.include "misc.s"
	.include "diskcmd.s"
	.include "macroex.s"
	.include "buffer2.s"
	.include "xmodem.s"
	.include "xfer.s"
	.include "disk.s"
	.include "outstr.s"
	.include "multixfer.s"
	.include "buffer.s"
	.include "phonebook.s"
	.include "configldsv.s"
	.include "instrprint.s"
	.include "macro.s"
	.include "configedit.s"
	.include "reu.s"
	.include "theme.s"
	.include "config.s"
	.include "easyflash.s"
	.include "instr.s"
	.include "punter.s"
	.include "misc2.s"

.segment "END"	; empty segment guaranteed by .cfg to be at the end
endprg:
