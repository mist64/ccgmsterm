; Configuration
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

	;.byte 0,6
	;.byte 'aFTERLIFE         '
	;.byte '192.168.0.8     ',0,'               ',0
	;.byte '6401 ',0
	;.byte 'myuserid   ',0
	;.byte 'mypassword1',0

	;.byte 0,6
	;.byte 'aFTERLIFE         '
	;.byte '192.168.0.8:6401                ',0
	;.byte '6400 ',0
	;.byte 'anotheruser',0
	;.byte 'mypassword1',0

	;.byte 0,6
	;.byte 'aFTERLIFE         '
	;.byte '192.168.0.8:6401                ',0
	;.byte '23   ',0
	;.byte 'myid       ',0
	;.byte 'mypassword1',0

	.repeat 29
	.res 83,0
	.endrep

	.byte 0,6
	.byte 'cOMMODORESERVER   '
	.byte 'COMMODORESERVER.COM',0,CR,0,0,0,0,0,0,0,0,0,0,0,0
	.byte '1541',0,13
	.byte 'ID         ',0
	.byte 'PIN        ',0
	.byte 0,0

; Macros
macmem:
macmm1:
	.byte 'hELLO wORLD'
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

endsav:
	.byte 0		; [XXX not necessary, *symbol* is used as end address]

