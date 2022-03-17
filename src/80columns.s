; CCGMS Terminal
;
; This file is in the public domain.
;
; Software 80 columns driver for C64/VIC-II
;
; based on https://github.com/mist64/80columns
; * Original author unknown
; * Scrolling optimizations by İlker Fıçıcılar
; * Reverse-engineered and improved by Michael Steil
;
; TODO
; * REU support for fast memcpy is currently disabled.
; * There is some logic here, like quote mode, that is
;   unused in the CCGMS context and should be removed.

.export col80_init, col80_set_charset
.export col80_on, col80_off
.export col80_wait
.export col80_resume, col80_pause
.export col80_invert, col80_restore
.export col80_active, col80_bg_update
.export col80_read_scr_chr, col80_read_scr_col
.import clear_screens, col80_enabled
.importzp locat, nlocat

.import charset_ascii_patches, charset_petscii_patches

; KERNAL defines
R6510  = $01
DFLTO  = $9A   ; Default Output (CMD) Device (3)
RVS    = $C7   ; Flag: Print Reverse Chars. -1=Yes, 0=No Used
GDBLN  = $CE   ; Character Under Cursor
PNT    = $D1   ; Pointer: Current Screen Line Address
PNTR   = $D3   ; Cursor Column on Current Line
QTSW   = $D4   ; Flag: Editor in Quote Mode, $00 = NO
TBLX   = $D6   ; Current Cursor Physical Line Number
DATA   = $D7   ; Temp Data Area
INSRT  = $D8   ; Flag: Insert Mode, >0 = # INSTs
USER   = $F3   ; Pointer: Current Screen Color RAM loc.
COLOR  = $0286 ; Current Character Color Code
GDCOL  = $0287 ; Background Color Under Cursor
SHFLAG = $028D ; Flag: Keyb'rd SHIFT Key/CTRL Key/C= Key
MODE   = $0291 ; Flag: $00=Disable SHIFT Keys, $80 = Enable SHIFT Keys
IBSOUT = $0326
USRCMD = $032E

; new zero page defines
bitmap_ptr  = $DD	; these addresses are within the
charset_ptr = $DF	; 40col "Screen Line Link Table"
tmp_ptr     = $E1	; area, which is unused in 80col mode

; addresses
CHARSET	= $D000 ; $D000-$D3FF
VICCOL	= $D400 ; $D400-$D7FF
VICSCN	= $D800 ; NEW Video Matrix: 25 Lines X 80 Columns
BITMAP	= $E000

.ifndef USE_REU
USE_REU = 0
.endif

.if USE_REU

REU_STATUS      = $DF00                 ; Status register
REU_COMMAND     = $DF01                 ; Command register
REU_C64ADDR     = $DF02                 ; C64 base address register
REU_REUADDR     = $DF04                 ; REU base address register
REU_COUNT       = $DF07                 ; Transfer count register
REU_IRQMASK     = $DF09                 ; IRQ mask register
REU_CONTROL     = $DF0A                 ; Control register
REU_TRIGGER     = $FF00                 ; REU command trigger

OP_COPYFROM     = $ED
OP_COPYTO       = $EC
.macro REU_OP addr, len, op
	php
        lda R6510
        pha
        lda #$35
	sei
        sta R6510
        lda #0
        sta $DF0A ; hold neither address
        lda #<(addr)
        sta REU_C64ADDR
        lda #>(addr)
        sta REU_C64ADDR+1


        lda #<(len)
        sta REU_COUNT
        lda #>(len)
        sta REU_COUNT+1

        ldx #op
        jsr reu_op
        pla
        sta R6510
	plp
.endmacro

.macro REU_COPYFROM addr, len
        REU_OP addr, len, OP_COPYFROM
.endmacro

.macro REU_COPYTO addr, len
        REU_OP addr, len, OP_COPYTO
.endmacro

.macro REU_MEMMOVE addr1, addr2, len
        REU_COPYTO addr1, len
        REU_COPYFROM addr2, len
.endmacro
.endif

.macro ENABLE_RAM
	lda R6510
	pha
	lda #$30
	sta R6510
.endmacro
.macro DISABLE_RAM
	pla
	sta R6510
.endmacro

; constants
COLUMNS = 80
LINES   = 25

.import charset

zp80a = locat
zp80b = nlocat

col80_init:
	; install charset
	ENABLE_RAM
	lda #<charset
	sta zp80a
	lda #>charset
	sta zp80a+1
	lda #<CHARSET
	sta zp80b
	lda #>CHARSET
	sta zp80b+1
	ldx #8
	ldy #0
:	lda (zp80a),y
	sta (zp80b),y
	iny
	bne :-
	inc zp80a+1
	inc zp80b+1
	dex
	bne :-
	DISABLE_RAM

	lda #<new_bsout
	sta IBSOUT
	lda #>new_bsout
	sta IBSOUT + 1

	rts

col80_set_charset:
	beq @1
	ENABLE_RAM
	ldx #7
:	lda charset_ascii_patches+8*0,x
	sta CHARSET+8*$1c,x
	lda charset_ascii_patches+8*1,x
	sta CHARSET+8*$1e,x
	lda charset_ascii_patches+8*2,x
	sta CHARSET+8*$1f,x
	lda charset_ascii_patches+8*3,x
	sta CHARSET+8*$40,x
	lda charset_ascii_patches+8*4,x
	sta CHARSET+8*$5b,x
	lda charset_ascii_patches+8*5,x
	sta CHARSET+8*$5c,x
	lda charset_ascii_patches+8*6,x
	sta CHARSET+8*$5d,x
	lda charset_ascii_patches+8*7,x
	sta CHARSET+8*$5e,x
	lda charset_ascii_patches+8*8,x
	sta CHARSET+8*$5f,x
	dex
	bpl :-
	DISABLE_RAM
	rts
@1:	ENABLE_RAM
	ldx #7
:	lda charset_petscii_patches+8*0,x
	sta CHARSET+8*$1c,x
	lda charset_petscii_patches+8*1,x
	sta CHARSET+8*$1e,x
	lda charset_petscii_patches+8*2,x
	sta CHARSET+8*$1f,x
	lda charset_petscii_patches+8*3,x
	sta CHARSET+8*$40,x
	lda charset_petscii_patches+8*4,x
	sta CHARSET+8*$5b,x
	lda charset_petscii_patches+8*5,x
	sta CHARSET+8*$5c,x
	lda charset_petscii_patches+8*6,x
	sta CHARSET+8*$5d,x
	lda charset_petscii_patches+8*7,x
	sta CHARSET+8*$5e,x
	lda charset_petscii_patches+8*8,x
	sta CHARSET+8*$5f,x
	dex
	bpl :-
	DISABLE_RAM
	rts

col80_resume:
	bit col80_enabled
	bmi :+
	rts
:	jsr _col80_on
save_csr_x=*+1
	lda #0
	sta PNTR
save_csr_y=*+1
	lda #0
	sta TBLX
	rts

_col80_on:
	sec
	jsr MODE_enable_i ; allow switching charsets, returns A=#$00
	sta QTSW
	sta INSRT ; disable quote and insert mode
	lda #$3B ; bitmap mode
	sta $D011
	lda #$58
	sta $D018
	lda $DD00
	and #%11111100	; VIC bank $C000-$FFFF
	sta $DD00
	jsr cmd_graphics ; upper case
	lda $d021
	jsr set_bgcolor
	lda #$80
	sta col80_active
	rts

col80_pause:
	bit col80_enabled
	bmi :+
	rts
:	lda PNTR
	sta save_csr_x
	lda TBLX
	sta save_csr_y
; runs into _col80_off

_col80_off:
	lda #$1B
	sta $D011
	lda #$17
	sta $D018
	lda $DD00
	ora #%00000011	; VIC bank $0000-$3FFF
	sta $DD00
	lda #0
	sta col80_active
	lda #$93
	jmp $ffd2

col80_on:
	jsr cmd_clr ; clear screen
	jmp _col80_on

col80_off:
	jsr _col80_off
	jmp clear_screens

col80_wait:
	bit col80_enabled
	bpl :+
@loop:	jsr $ffe4	; getin
	beq @loop
:	rts


new_bsout:
	bit col80_active
	bmi :+
	jmp $f1ca
:
	sta DATA
	pha
	lda DFLTO
	cmp #3
	bne :+
	txa
	pha
	tya
	pha
	lda DATA
	jsr bsout_core
	pla
	tay
	pla
	tax
	pla
	clc
.if 0
	cli ; XXX user may have wanted interrupts off!
.endif
	rts
:	jmp $F1D5 ; original non-screen BSOUT

bsout_core:
	tax
	and #$60
	beq @2
	txa
	jsr $E684 ; if open quote toggle cursor quote flag
	jsr petscii_to_screencode
	clc
	adc RVS
	ldx COLOR
	jsr draw_move
	lda INSRT
	beq @1
	dec INSRT
@1:	rts
; special character
@2:	cpx #$0D ; CR
	beq special_char
	cpx #$8D ; LF
	beq special_char
	lda INSRT
	beq @3
	cpx #$94 ; INSERT
	beq special_char
	dec INSRT
	bpl @4
@3:	cpx #$14 ; DEL
	beq special_char
	lda QTSW
	beq special_char
; quote or insert mode
@4:	txa
	bpl @5
	sec
	sbc #$40
@5:	ora #$80
	ldx COLOR
draw_move:
	jsr _draw_char_with_col
	jmp move_csr_right

; interpret special character
special_char:
	txa
	bpl @1
	sec
	sbc #$60 ; fold $80-$9F -> $20-$3F
@1:	tay
	lda code_table,y
	clc
	adc #<rts0
	sta USRCMD
	lda #>rts0
	adc #0
	sta USRCMD + 1
	txa
	jmp (USRCMD)

.macro ADDR addr
	.byte addr - rts0
.endmacro

code_table:
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR set_col_white   ; $05: WHITE
	ADDR rts0
	ADDR rts0
	ADDR MODE_disable    ; $08: SHIFT DISABLE
	ADDR MODE_enable     ; $09: SHIFT ENABLE
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR cmd_cr          ; $0D: CR
	ADDR cmd_text        ; $0E: TEXT MODE
	ADDR rts0
	ADDR rts0
	ADDR move_csr_down   ; $11: CURSOR DOWN
	ADDR set_rvs_on      ; $12: REVERSE ON
	ADDR cmd_home        ; $13: HOME
	ADDR cmd_del         ; $14: DEL
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR set_col_red     ; $1C: RED
	ADDR move_csr_right  ; $1D: CURSOR RIGHT
	ADDR set_col_green   ; $1E: GREEN
	ADDR set_col_blue    ; $1F: BLUE
	ADDR rts0
	ADDR set_col_orange  ; $81: ORANGE
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR rts0
	ADDR cmd_cr          ; $8D: LF
	ADDR cmd_graphics    ; $8E: GRAPHICS
	ADDR rts0
	ADDR set_col_black   ; $90: BLACK
	ADDR move_csr_up     ; $91: CURSOR UP
	ADDR set_rvs_off     ; $92: REVERSE OFF
	ADDR cmd_clr         ; $93: CLR
	ADDR cmd_inst        ; $94: INSERT
	ADDR set_col_brown   ; $95: BROWN
	ADDR set_col_ltred   ; $96: LIGHT RED
	ADDR set_col_dkgray  ; $97: DARK GRAY
	ADDR set_col_gray    ; $98: MIDDLE GRAY
	ADDR set_col_ltgreen ; $99: LIGHT GREEN
	ADDR set_col_ltblue  ; $9A: LIGHT BLUE
	ADDR set_col_ltgray  ; $9B: LIGHT GRAY
	ADDR set_col_purple  ; $9C: PURPLE
	ADDR move_csr_left   ; $9D: CURSOR LEFT
	ADDR set_col_yellow  ; $9E: YELLOW
	ADDR set_col_cyan    ; $9F: CYAN

rts0:	rts

set_col_black:
	lda #0
	.byte $2c
set_col_white:
	lda #1
	.byte $2c
set_col_red:
	lda #2
	.byte $2c
set_col_cyan:
	lda #3
	.byte $2c
set_col_purple:
	lda #4
	.byte $2c
set_col_green:
	lda #5
	.byte $2c
set_col_blue:
	lda #6
	.byte $2c
set_col_yellow:
	lda #7
	.byte $2c
set_col_orange:
	lda #8
	.byte $2c
set_col_brown:
	lda #9
	.byte $2c
set_col_ltred:
	lda #$0A
	.byte $2c
set_col_dkgray:
	lda #$0B
	.byte $2c
set_col_gray:
	lda #$0C
	.byte $2c
set_col_ltgreen:
	lda #$0D
	.byte $2c
set_col_ltblue:
	lda #$0E
	.byte $2c
set_col_ltgray:
	lda #$0F
set_col:
	sta COLOR
	lda bgcolor
	ora COLOR
	sta COLOR
	rts

MODE_disable:
MODE_enable:
	lsr
MODE_enable_i:
	lda #0
	ror
	eor #$80
	sta MODE
	rts

cmd_cr:
	lda #0
	sta INSRT
	sta QTSW
	sta RVS
move_csr_down_pntr:
	sta PNTR
move_csr_down:
	inc TBLX
	lda TBLX
	cmp #LINES
	bne calc_pnt_user
	dec TBLX
	jsr _scroll_up ;returns Z clear
	jmp calc_pnt_user ;always

move_csr_right:
	inc PNTR
	lda PNTR
	sec
	sbc #COLUMNS
	beq move_csr_down_pntr
	rts ;returns Z clear

cmd_text:
cmd_graphics:
.if 0
	asl
	lda $D018
	and #<~2
	bcs store_d018
	ora #2
store_d018:
	sta $D018
.endif
	rts

set_rvs_on:
set_rvs_off:
	asl
	lda #0
	ror
	eor #$80
	sta RVS
	rts

move_csr_up:
	lda TBLX
	beq calc_pnt_user
	dec TBLX
	bpl calc_pnt_user ;always

cmd_clr:
	lda #LINES - 1
	sta TBLX
:	jsr _clr_curline
	dec TBLX
	bpl :-

cmd_home:
	lda #0
	sta PNTR
	sta TBLX
calc_pnt_user:
	jsr calc_pnt

calc_user:
	lda TBLX
	asl a ;clear carry
	tax
	lda mul_40_tab,x
	sta USER
	lda mul_40_tab + 1,x
	adc #>VICCOL
	sta USER + 1
	rts ;returns Z clear because of LDA

cmd_del:
	lda PNTR
	beq move_csr_left
	pha
	dec PNTR
	ENABLE_RAM
@1:	lda #' '
	ldy PNTR
	cpy #COLUMNS - 1
	php
	beq @2
	iny
	lda (PNT),y
@2:	ldx COLOR
	jsr _draw_char_with_col
	inc PNTR
	plp
	bne @1
	DISABLE_RAM
	pla
	sta PNTR

move_csr_left:
	dec PNTR
	bpl @2
	lda TBLX
	beq @1
	jsr move_csr_up
	lda #COLUMNS - 1
@1:	sta PNTR
@2:	rts

cmd_inst:
	lda PNTR
	sta pntr2
	lda #COLUMNS
	sta PNTR
@1:	dec PNTR
	lda #' '
	ldy PNTR
	cpy pntr2
	php
	beq @2
	dey
	lda (PNT),y
@2:	ldx COLOR
	jsr _draw_char_with_col
	plp
	bne @1
	inc INSRT
	rts

clr_curline:
	jsr calc_pnt
	ldy #COLUMNS - 1
	lda #' '
:	sta (PNT),y
	dey
	bpl :-
	jsr calc_user
	ldy #40
	sty PNTR
	dey
	lda COLOR
:	sta (USER),y
	dey
	bpl :-
	jsr calc_bitmap_ptr
	tya
	ldy #160
:	dey
	sta (bitmap_ptr),y
	bne :-
	sty PNTR
	jsr calc_bitmap_ptr
	ldy #160
	lda #$FF
:	dey
	sta (bitmap_ptr),y
	bne :-
	rts

mul_40_tab:
	.repeat 25, i
	.word i*40
	.endrep

calc_bitmap_ptr:
	lda TBLX
	asl a ;clear carry
	tax
	lda PNTR
	and #$FE
	adc mul_80_tab,x
	sta bitmap_ptr
	lda mul_80_tab + 1,x
	adc #0
	asl bitmap_ptr
	rol
	asl bitmap_ptr
	rol
	adc #>BITMAP
	sta bitmap_ptr + 1
	rts

calc_pnt:
	lda TBLX
	asl a ;clear carry
	tax
	lda mul_80_tab,x
	sta PNT
	lda mul_80_tab + 1,x
	adc #>VICSCN
	sta PNT + 1
	rts

mul_80_tab:
	.repeat 25, i
	.word i*80
	.endrep

scroll_up:
	ldy PNTR
	sty pntr2
	lda (PNT),y
	jsr _draw_char ; draw character under cursor again XXX ???
; delay if CBM pressed
	lda SHFLAG
	and #4
	tay
	beq @2
; ***START*** identical to $E94B in KERNAL
	ldy #0
@1:	nop
	dex
	bne @1
	dey
	bne @1
@2:
        ; note that Y is now 0
; ***END*** identical to $E94B in KERNAL
; scroll screen up
.if USE_REU
        ; move bitmap RAM (starting at BITMAP) up by 320 bytes
        REU_MEMMOVE BITMAP+320, BITMAP, 24*40*8
        ; move character RAM (starting at VICSCN) up by 80 bytes
        REU_MEMMOVE VICSCN+80, VICSCN, 24*80
.else
	lda #COLUMNS
	sta PNT
	lda #>VICSCN
	sta PNT + 1
	sty tmp_ptr
	sta tmp_ptr + 1
:	lda (PNT),y
	sta (tmp_ptr),y
	iny
	bne :-
	inc PNT + 1
	inc tmp_ptr + 1
	lda PNT + 1
	cmp #200
	bcc :-
:	.repeat 48, i
	lda BITMAP + i * 160 + 320,y
	sta BITMAP + i * 160,y
	.endrepeat
	iny
	cpy #$a0
	beq :+
	jmp :-
:
.endif
	ldy #40
	lda #>VICCOL
	sty USER
	sta USER + 1
	ldy #0
	sty tmp_ptr
	sta tmp_ptr + 1
:	lda (USER),y
	sta (tmp_ptr),y
	iny
	bne :-
	inc USER + 1
	inc tmp_ptr + 1
	lda tmp_ptr + 1
	cmp #>(VICCOL+$0300)
	bcc :-
:	lda VICCOL + 807,y
	sta VICCOL + 807 - 40,y
	iny
	cpy #$C0
	bcc :-
	lda #LINES - 1
	sta TBLX
	jsr clr_curline
	lda pntr2
	sta PNTR
	rts ;returns Z clear because of LDA

petscii_to_screencode:
	cmp #$FF ; PI
	bne @1
	lda #$7E ; screencode for PI
@1:	pha
	and #$E0
	ldx #6
@2:	cmp tab1-1,x
	beq @3
	dex
	bne @2
@3:	pla
	and #$1F
	ora tab2-1,x
	rts

tab1:	.byte $E0,$C0,$A0,$60,$40,$20
tab2:	.byte $60,$40,$60,$40,$00,$20

draw_char_with_col:
	stx DATA
	jsr draw_char
	lda PNTR
	lsr a
	tay
	lda DATA
	sta (USER),y
	rts

draw_char:
	ldy PNTR
	sta (PNT),y
	ldy #$FF
	asl
	bcc @1
	clc
	iny
@1:	sty rvs_mask
	ldy is_text
	beq @2
	sec
@2:	sta charset_ptr
	lda #(>CHARSET) >> 3
	rol
	asl charset_ptr
	rol
	asl charset_ptr
	rol
	sta charset_ptr + 1
	jsr calc_bitmap_ptr
	lda PNTR
	and #1
	bne @3
	ldy #7
	.repeat 8
	lda (charset_ptr),y
	eor rvs_mask
	eor (bitmap_ptr),y
	and #$F0
	eor (bitmap_ptr),y
	sta (bitmap_ptr),y
	dey
	.endrepeat
	rts
@3:	ldy #7
	.repeat 8
	lda (charset_ptr),y
	eor rvs_mask
	eor (bitmap_ptr),y
	and #$0F
	eor (bitmap_ptr),y
	sta (bitmap_ptr),y
	dey
	.endrepeat
	rts

; change background color
col80_bg_update:
	jsr set_bgcolor
	cmp color2
	bne @5
	rts
@5:	sta color2
	lda TBLX
	pha
	lda #LINES - 1
	sta TBLX
	ENABLE_RAM
@3:	jsr calc_user
	ldy #40 - 1
@4:	lda (USER),y
	and #$0F
	ora color2
	sta (USER),y
	dey
	bpl @4
	dec TBLX
	bpl @3
	DISABLE_RAM
	lda COLOR
	and #$0F
	ora color2
	sta COLOR
	lda GDCOL
	and #$0F
	ora color2
	sta GDCOL
	pla
	sta TBLX
	jmp calc_user

set_bgcolor:
	asl
	asl
	asl
	asl
	sta bgcolor
	rts

; redraw screen in charset change [XXX unused]
col80_update_charset:
	lda $D018
	and #2
	cmp is_text
	bne @a6
	rts
@a6:	sta is_text
	lda PNTR
	pha
	lda TBLX
	pha
	jsr cmd_home
@a1:	ldy PNTR
	lda (PNT),y
	and #$7F
	cmp #$20
	beq @a3
@a2:	lda (PNT),y
	jsr _draw_char ; re-draw character
@a3:	lda PNTR
	cmp #COLUMNS - 1
	bne @a4
	lda TBLX
	cmp #LINES - 1
	beq @a5
@a4:	jsr move_csr_right
	bne @a1 ;always
@a5:	pla
	sta TBLX
	pla
	sta PNTR
	jsr calc_pnt
	jmp calc_user

col80_read_scr_chr:
	ENABLE_RAM
	tya
	asl
	tay
	lda mul_80_tab,y
	sta bitmap_ptr
	lda mul_80_tab + 1,y
	adc #>VICSCN
	sta bitmap_ptr+1
	txa
	tay
	lda (bitmap_ptr),y
	tax
	DISABLE_RAM
	txa
	rts

col80_read_scr_col:
	ENABLE_RAM
	tya
	asl
	tay
	lda mul_40_tab,y
	sta bitmap_ptr
	lda mul_40_tab + 1,y
	adc #>VICCOL
	sta bitmap_ptr+1
	txa
	lsr
	tay
	lda (bitmap_ptr),y
	and #$0f
	tax
	DISABLE_RAM
	txa
	rts

; Cursor Blinking
; If the cursor is on top of a space character, it will be drawn in the
; current cursor color, so with a 50% chance, this will change the
; color of the previous character if it's different. (Otherwise, the
; cursor will be drawn in the color of the character under it, which
; has no side effects.)
col80_invert:
	ENABLE_RAM
	lda PNTR	; current line
	lsr a
	tay
	lda (USER),y	; get color of cell
	sta GDCOL	; save
	ldy PNTR	; current line
	lda (PNT),y	; read char
	sta GDBLN
	eor #$80	; invert
	ldx COLOR	; current cursor color
	cmp #$a0
	beq col80_draw2
col80_draw:
	ldx GDCOL	; color of char under cursor
col80_draw2:
	jsr _draw_char_with_col
	DISABLE_RAM
	rts
col80_restore:
	ENABLE_RAM
	lda GDBLN
	jmp col80_draw

.if USE_REU
reu_op:
        lda #0
        sta REU_REUADDR
        sta REU_REUADDR+1
        sta REU_REUADDR+2

        stx REU_COMMAND

        lda REU_TRIGGER
        sta REU_TRIGGER

        rts
.endif

.macro exec0 addr, save_y
.ifnblank save_y
	tay
.endif
	ENABLE_RAM
.ifnblank save_y
	tya
.endif
	jsr addr
	DISABLE_RAM
	rts
.endmacro

_draw_char_with_col:
	exec0 draw_char_with_col, Y

_clr_curline:
	exec0 clr_curline

_draw_char:
	exec0 draw_char, Y

_scroll_up:
	exec0 scroll_up

bgcolor:
	.byte 0
pntr2:
	.byte 0
rvs_mask:
	.byte 0
color2:
	.byte 0
is_text:
	.byte 0

col80_active:
	.byte 0
