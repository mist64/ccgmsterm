; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Configuration editor
;

;----------------------------------------------------------------------
; change terminal params/dial
handle_f7_config:
	jsr disablemodem
	lda #0
	sta $d020
	sta $d021
	lda #<txt_settings_menu
	ldy #>txt_settings_menu
	jsr outstr
	lda easyflash_support
	beq @1
	lda #<txt_edit_macros_cfg_device
	ldy #>txt_edit_macros_cfg_device
	jsr outstr
	jmp @2
@1:	lda #<txt_edit_macros
	ldy #>txt_edit_macros
	jsr outstr
@2:	lda #<txt_load_save_config
	ldy #>txt_load_save_config
	jsr outstr
	lda #<txt_press_return_to_abort
	ldy #>txt_press_return_to_abort
	jsr outstr

config_loop:
	lda #0
	sta NDX
	jsr f7parm
f7chos
	lda JIFFIES
	and #$0f
	bne f7chgk
	lda JIFFIES
	and #$10
	beq f7oprt
	lda #<txt_press_return_to_abort
	ldy #>txt_press_return_to_abort
	jsr outstr
	jmp f7chgk
f7oprt
	lda #<txt_return
	ldy #>txt_return
	jsr outstr
f7chgk
	jsr getin
	cmp #0
	beq f7chos

; A: auto-dial
	and #$7f
	cmp #'A'
	bne @no1

	lda baud_rate
	sta bautmp
	lda ascii_mode
	sta gratmp
	jmp phonebook
@no1:

; B: Baud Rate
	cmp #'B'
	bne @no2

	ldy modem_type
	beq @baud1	; MODEM_TYPE_USERPORT
	cpy #MODEM_TYPE_UP9600
	beq @baud2
	cpy #MODEM_TYPE_SWIFTLINK_DF; skip REU if there's SwiftLink at $DF00
	bne @inc
	jsr noreu
	jmp @inc
@baud1:	lda baud_rate
	cmp #BAUD_2400
	bmi @inc
	jmp @reset
@baud2:	lda baud_rate
	cmp #BAUD_9600
	bmi @inc
	jmp @reset
@inc:	inc baud_rate
	lda baud_rate
	cmp #BAUD_38400+1
	bne :+
@reset:	lda #BAUD_300
	sta baud_rate
:	jsr rsopen	;5-16 add failsafe....
	jmp config_loop
@no2:

; D: Duplex
	cmp #'D'
	bne @no3

	lda half_duplex
	eor #1
	sta half_duplex
	jmp config_loop
@no3:

; F: Firmware
	cmp #'F'
	bne @no4

	lda firmware_zimmers
	eor #1
	sta firmware_zimmers
	jmp config_loop
@no4:

; T: theme
	cmp #'T'
	bne @no5
	inc theme
	lda theme
	cmp #6
	bne :+
	lda #0
	sta theme
:	jsr themeroutine
	jmp config_loop
@no5:

; C: Config EF/Disk (EasyFlash only)
	cmp #'C'
	bne @no6
	lda easyflash_support
	beq @no6
	lda easyflash_use_disk
	eor #1
	sta easyflash_use_disk
	jmp config_loop
@no6:

; M: modem type
	cmp #'M'
	bne @no7

	inc modem_type
	lda modem_type
	pha
	lda easyflash_support
	beq @mod1
	pla
	cmp #2		; only 2 modems in easyflash mode
	bcc @incmod
	jmp @mod2
@mod1:	pla
	cmp #5		; max # of modems
	bcc @incmod
@mod2:	lda #0
	sta modem_type
	lda #BAUD_2400
	sta baud_rate
@incmod:
	jsr rsopen
	jmp config_loop
@no7:

; P: Protocol
	cmp #'P'
	bne @no8

	inc protoc
	lda protoc
	cmp #3
	bcc :+
	lda #0
	sta protoc
:	jmp config_loop
@no8:

; S: save
	cmp #'S'
	bne @no9
	jsr save_config
	jmp handle_f7_config
@no9:

; L: load
	cmp #'L'
	bne @no10
	jsr load_config
	jmp handle_f7_config
@no10:

; E: edit macros
	cmp #'E'
	bne @no11
	jsr edtmac
	jmp handle_f7_config
@no11:

; V: view message
	cmp #'V'
	bne @no12
	jsr show_instructions
	jmp handle_f7_config
@no12:

	cmp #CR
	jne f7chos

; return to terminal
	lda nicktemp	; [XXX no-op]
	beq *+2		; [XXX no-op]

	jsr enablemodem
	jmp term_entry

prmopt:
	.word op1txt
	.word op2txt
	.word op6txt
	.word op3txt
	.word op4txt
	.word op5txt

prmlen:
	.byte 4,18,8,10,20,19

SET_PETSCII
op1txt:
	.byte "Full"
	.byte "Half"

op2txt:
	.byte "User Port 300-2400"
	.byte "UP9600 / EZ232    "
	.byte "Swift / Turbo DE  "
	.byte "Swift / Turbo DF  "
	.byte "Swift / Turbo D7  "

op6txt:
	.byte "Standard"
	.byte "Zimodem "

op3txt:
	.byte "Punter    "
	.byte "Xmodem    "
	.byte "Xmodem-CRC"

op4txt:
	.byte "Classic CCGMS v5.5  "
	.byte "Iman / XPB v7.1     "
	.byte "Predator / FCC v8.1 "
	.byte "Ice theme v9.4      "
	.byte "Defcon/Unicess v17.2"
	.byte "Alwyz / CCGMS 2021  "

op5txt:
	.res 15,CSR_RIGHT
	.byte "EF  "
	.res 15,CSR_RIGHT
	.byte "Disk"
SET_ASCII

;----------------------------------------------------------------------
prmtab:
	lda #CR
	jsr chrout
	jsr chrout
	ldx #17
	jmp outspc

; display duplex, modem type, protocol
prmclc:
	tya
	asl a
	tax
	lda prmopt,x
	sta prmadr
	lda prmopt+1,x
	sta prmadr+1
	rts

prmprt:
	dex
	bmi prmpr2
	lda prmadr
	clc
	adc prmlen,y
	sta prmadr
	lda prmadr+1
	adc #0
	sta prmadr+1
	bne prmprt
prmpr2
	inx
prmadr=*+1
:	lda op1txt,x
	jsr chrout
	inx
	txa
	cmp prmlen,y
	bne :-
	jmp prmtab

;----------------------------------------------------------------------
f7parm:
	lda #HOME
	jsr chrout
	lda #1
	sta textcl
	ldy f7thob
:	jsr prmtab
	dey
	bne :-
	jsr prmclc
	lda baud_rate
	asl a
	tax
	lda baudrates+1,x
	pha
	lda baudrates,x
	tax
	pla
	jsr outnum
	lda #' '
	jsr chrout
	jsr chrout
	jsr prmtab
	ldy #0		; duplex
	jsr prmclc
	ldx half_duplex
	jsr prmprt
	iny
	jsr prmclc
	ldx modem_type
	jsr prmprt
	ldy #2
	jsr prmclc
	ldx firmware_zimmers
	jsr prmprt
	ldy #3
	jsr prmclc
	ldx protoc
	jsr prmprt
	ldy #4
	jsr prmclc
	ldx theme
	jsr prmprt
	lda easyflash_support
	beq :+
	ldy #5
	jsr prmclc
	ldx easyflash_use_disk
	jmp prmprt
:	rts

;----------------------------------------------------------------------
txt_cmd_scratch:
	.byte "S0:",0

SET_PETSCII
txt_filename:
	.byte CLR,CR,WHITE,"Filename: ",0

filename_config:
	.byte "ccgms-phone",0

f7thob:
	.byte 2

txt_settings_menu:
	.byte CLR,16,LOCASE,WHITE
	.byte "   Dialer/Parameters",CR
	.byte BLUE,"   "
	.res 17,$a3	; $A3: UPPER ONE EIGHTH BLOCK ('▔')
	.byte CR,WHITE,16
tcol27a	.byte WHITE
	.byte " ",HILITE,"auto-Dialer/Phonebook",CR,CR
	.byte " ",HILITE,"baud Rate   -",CR,CR
	.byte " ",HILITE,"duplex      -",CR,CR
	.byte " ",HILITE,"modem Type  -",CR,CR
	.byte " ",HILITE,"f"
tcol27b	.byte " "
	.byte "irmware    -",CR,CR
	.byte " ",HILITE,"protocol    -",CR,CR
	.byte " ",HILITE,"theme       -",CR,CR,0

txt_edit_macros:
	.byte " ",HILITE,"edit Macros",CR,CR,0
txt_edit_macros_cfg_device:
	.byte " ",HILITE,"edit Macros   ",HILITE,"cfg Device -",CR,CR,0

txt_load_save_config:
	.byte " ",HILITE,"load/",HILITE,"save Phone Book and Config.",CR,CR
	.byte " ",HILITE,"view Author's Message",CR,CR,0

txt_press_return_to_abort:
.ifdef BIN_2021
	.byte SETCSR,22,0,WHITE,cp,"ress <",YELLOW,RVSON,"R",e,t,u,cr,n,RVSOFF,WHITE,"> to abort.",CR,0
.else
	.byte SETCSR,22,0,WHITE,"Press <",YELLOW,RVSON,"RETURN",RVSOFF,WHITE,"> to abort.",CR,0
.endif

txt_return:
	.byte SETCSR,22,7,CYAN,"RETURN",CR,0
SET_ASCII

;----------------------------------------------------------------------
baudrates:
	.word 300
	.word 1200
	.word 2400
	.word 4800
	.word 9600
	.word 19200
	.word 38400

