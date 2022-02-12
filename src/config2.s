; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Config loading and saving
;

;----------------------------------------------------------------------
losvco:
	jsr disablexfer
	jsr ercopn
	lda #<txt_filename
	ldy #>txt_filename
	ldx #16
	jsr inpset
	lda #<filename_config
	ldy #>filename_config
	jsr outstr
	jsr inputl
	beq :+
	txa
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	lda #2
	ldx device_disk
	ldy #0
	jsr setlfs
	ldx $b7
:	rts

;----------------------------------------------------------------------
save_config:
	lda easyflash_support
	beq :+
	lda diskoref
	beq save_config_easyflash
:	jsr losvco
	bne *+2		; [XXX]
	ldx #LFN_DISK_CMD
	jsr chkout
	ldx #0
:	lda txt_cmd_scratch,x
	beq :+
	jsr chrout
	inx
	bne :-
:	ldx #0
:	lda inpbuf,x
	jsr chrout
	inx
	cpx max
	bcc :-
	lda #CR
	jsr chrout
	jsr clrchn
	lda #<config_data
	sta nlocat
	lda #>config_data
	sta nlocat+1
	lda #nlocat
	ldx #<config_data_end
	ldy #>config_data_end
	jsr save
	jsr losver
losvab	rts

;----------------------------------------------------------------------
save_config_easyflash:
	jmp easyflash_write_config

;----------------------------------------------------------------------
load_config:
	lda easyflash_support
	beq :+
	lda diskoref
	beq load_config_easyflash
:	jsr losvco
	beq losvab

;----------------------------------------------------------------------
load_config_file:
	ldx #<config_data
	ldy #>config_data
	lda #0		; load
	jsr $ffd5
	jsr losver
load_config_done:
	jsr themeroutine
	jsr rsopen	; [XXX jmp]
	rts

;----------------------------------------------------------------------
load_config_easyflash:
	jsr easyflash_read_config
	jmp load_config_done

;----------------------------------------------------------------------
losver:
	jsr disablemodem
	ldx #LFN_DISK_CMD
	jsr chkin
:	jsr getin
	cmp #CR
	bne :-
	jmp clrchn
