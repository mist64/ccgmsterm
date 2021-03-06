; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; EasyFlash config loading and saving
;

;----------------------------------------------------------------------
easyflash_write_config:
	jsr easyflash_init

	lda #$30      ; bank $30 (this is where the config is going to be stored).
	ldy #$80      ; lorom
	jsr $df83     ; erase sector (banks 30:0, 31:0, 32:0, 33:0, 34:0, 35:0, 36:0 and 37:0 are set to $ff)
	jsr delay_1500ms     ; delay 1.5 seconds after erase to let c64 physically finish its job for compatibility.
	lda #$30      ; set bank $30 for the next read/write command.
	jsr $df86
	lda #$b0      ; set bank mode to llll (continue to next lo bank after current lo bank is full)
	ldx #<$8000   ; set address to $8000,
	ldy #>$8000   ; this is the position in the bank where the config is being stored, ie top of bank)
	jsr $df8c
	ldx #0
efaddr1=*+1
:	lda $5100,x   ; this is where the config is positioned.
	jsr $df95     ; write byte to ef, $0305 to $8000, $0306 to $8001, etc.
	inx
	bne :-
	inc efaddr1+1
	lda efaddr1+1
	cmp #$5c
	bne :-
	lda #$51
	sta efaddr1+1

	lda #$04      ; cart off.
	sta $de02
	rts

;----------------------------------------------------------------------
delay_500ms:
	ldy #0
	ldx #0
:	inx
	bne :-
	dey
	bne :-
	rts
delay_1500ms:
	jsr delay_500ms    ; delay 0.5 seconds
	jsr delay_500ms    ; delay 0.5 seconds
	jsr delay_500ms    ; delay 0.5 seconds
	rts

;----------------------------------------------------------------------
easyflash_read_config:
	jsr easyflash_init

;	lda #$30      ; bank $30 (this is where the config is going to be stored).
;	ldy #$80      ; lorom
;	jsr $df83     ; erase sector (banks 30:0, 31:0, 32:0, 33:0, 34:0, 35:0, 36:0 and 37:0 are set to $ff)
;	jsr delay_1500ms     ; delay 1.5 seconds after erase to let c64 physically finish its job for compatibility.

	lda #$30      ; set bank $30 for the next read/write command.
	jsr $df86
	lda #$b0      ; set bank mode to llll (continue to next lo bank after current lo bank is full)
	ldx #$00      ; set address to $8000,
	ldy #$80      ; this is the position in the bank where the config is being stored, ie top of bank)
	jsr $df8c
	ldx #$00

:	jsr $df92; read byte to ef, $0305 to $8000, $0306 to $8001, etc.
efaddr2=*+1
	sta $5100,x   ; this is where the config is positioned.
	inx
	bne :-
	inc efaddr2+1
	lda efaddr2+1
	cmp #$5c
	bne :-
	lda #$51
	sta efaddr2+1

	lda #$04      ; cart off.
	sta $de02
	rts

;----------------------------------------------------------------------
easyflash_init:
	lda #$07      ; cart on. banks visible from $8000-$bfff
	sta $de02
	lda #$00      ; select bank 0.
	sta $de00
	ldx #$00      ; copy eapi driver from bank 0 to ram at $1800. (eapi is always at $b800 in bank 0).
:	lda $b800,x
	sta $cb00,x
	lda $b900,x
	sta $cc00,x
	lda $ba00,x
	sta $cd00,x
	inx
	bne :-
	jsr $cb14     ; init eapi driver. (routines copied to extra cart ram $df80-dfff)
	rts

