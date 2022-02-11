	.feature labels_without_colons, loose_char_term, loose_string_term
	.macpack longbranch

	.include "declare.s"

.segment "S07FF"

	.word $0801

.segment "S0801"

	.word $080d
	.word 10
	.byte $9e,'4096'
	.word 0
	.byte 0

	jmp prestart

.segment "S0812"  ;pxxxxx

	.include "punter.s"
	.include "misc2.s"

efbyte ; 0 = no easyflash 1=easyflash mode
	.byte EASYFLASH

	;about 40 bytes still free here to play with before $1000

.segment "S1000"

	.include "init.s"
	.include "main.s"
	.include "sound.s"
	.include "screens.s"
	.include "banner.s"
	.include "dir.s"
	.include "ansi.s"
	.include "input.s"
	.include "misc.s"
	.include "disk2.s"
	.include "macro2.s"
	.include "buffer2.s"
	.include "xmodem.s"
	.include "xfer.s"
	.include "disk.s"
	.include "outstr.s"
	.include "multixfer.s"
	.include "buffer.s"
	.include "phonebook.s"
	.include "hayes.s"
	.include "config2.s"
	.include "viewmg.s"
	.include "macro.s"
	.include "params.s"
	.include "rs232_userport.s"
	.include "rs232_swiftlink.s"
	.include "rs232_up9600.s"
	.include "rs232.s"
	.include "reu.s"
	.include "theme.s"
	.include "easyflash.s"

.segment "S5100"

	.include "config.s"

.segment "S5C00"

	.include "credits.s"

endprg	.byte 0
