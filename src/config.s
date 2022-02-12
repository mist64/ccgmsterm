; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Configuration data & phone book
;

;  This data gets saved to disk/EasyFlash
config_data:

baud_rate:
	.byte BAUD_2400

; indicates whether dialing should use ATD, followed by a quote
firmware_zimmers:
	.byte 0

mopo2:
	.byte $20	; unused, but needs to stay for bin compat

modem_type:
	.byte MODEM_TYPE_USERPORT

; Phone book
phbmem:
	; | len | contents |
	; |-----|----------|
	; |   2 | ?        |
	; |  18 | name     |
	; |  33 | address  |
	; |   6 | port?    |
	; |  12 | user     |
	; |  12 | password |
	; total: 83 bytes

SET_PETSCII
	;.byte 0,6
	;.byte "Afterlife         "
	;.byte "192.168.0.8     ",0,"               ",0
	;.byte "6401 ",0
	;.byte "MYUSERID   ",0
	;.byte "MYPASSWORD1",0

	;.byte 0,6
	;.byte "Afterlife         "
	;.byte "192.168.0.8:6401                ",0
	;.byte "6400 ",0
	;.byte "ANOTHERUSER",0
	;.byte "MYPASSWORD1",0

	;.byte 0,6
	;.byte "Afterlife         "
	;.byte "192.168.0.8:6401                ",0
	;.byte "23   ",0
	;.byte "MYID       ",0
	;.byte "MYPASSWORD1",0

	.repeat 29
	.res 83,0
	.endrep

	.byte 0,6
	.byte "Commodoreserver   "
	.byte "commodoreserver.com",0,CR,0,0,0,0,0,0,0,0,0,0,0,0
	.byte "1541",0,13
	.byte "id         ",0
	.byte "pin        ",0
	.byte 0,0

; Macros
macmem:
macmm1:
	.byte "Hello World"
	.res 64,0	; [XXX too many 0s]
macmm2:
	.res 64,0
macmm3:
	.res 64,0
macmm4:
	.res 64,0

; file transmission protocol
protoc:
	.byte 0

; 0: classic
; 1: Iman of XPB v7.1
; 2: v8.1 Predator/FCC
; 3: 9.4 Ice THEME
; 4: 17.2 Defcon/Unicess
theme:
	.byte 0

diskoref:
	.byte 0;00 = ef - 01=disk

config_data_end:
	.byte 0		; [XXX not necessary, *symbol* is used as end address]

