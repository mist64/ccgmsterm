; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; RS232 UP9600 Driver
;

; calls from outside code:
;  up9600_setup
;  up9600_enable
;  up9600_disable
;  up9600_getxfer

outstat	= $a9	; re-used KERNAL symbol RER/RINONE

;----------------------------------------------------------------------
nmi_startbit:
	pha
	txa
	pha
	tya
	pha
	bit $dd0d	; check bit 7 (startbit ?)
	bpl nv1		; no startbit received, then skip

	lda #$13
	sta $dd0f	; start timer B (forced reload, signal at PB7)
	sta $dd0d	; disable timer and FLAG interrupts
	lda #<nmi_bytrdy; on next NMI call nmi_bytrdy
	sta $0318	; (triggered by SDR full)
	lda #>nmi_bytrdy; on next NMI call nmi_bytrdy
	sta $0319	; (triggered by SDR full)

nv1	pla		; ignore, if NMI was triggered by RESTORE-key
	tay
	pla
	tax
	pla
	rti

nmi_bytrdy:
	pha
	txa
	pha
	tya
	pha
	bit $dd0d	; check bit 7 (SDR full ?)
	bpl nv1		; SDR not full, then skip (eg. RESTORE-key)

	lda #$92
	sta $dd0f	; stop timer B (keep signalling at PB7!)
	sta $dd0d	; enable FLAG (and timer) interrupts
	lda #<nmi_startbit ; on next NMI call nmi_startbit
	sta $0318	; (triggered by a startbit)
	lda #>nmi_startbit ; on next NMI call nmi_startbit
	sta $0319	; (triggered by a startbit)
	txa
	pha
	lda $dd0c	; read SDR (bit0=databit7,...,bit7=databit0)
	cmp #$80	; move bit7 into carry-flag
	and #$7f
	tax
	lda revtabup,x	; read databits 1-7 from lookup table
	adc #0		; add databit0
	ldx rtail	; and write it into the receive buffer
	sta ribuf,x
	inx
	stx rtail
	sec
	txa
	sbc rhead
	cmp #200
	bcc :+
	lda $dd01	; more than 200 bytes in the receive buffer
	and #$fd	; then disbale RTS
	sta $dd01
:	pla
	tax
	jmp nv1

;----------------------------------------------------------------------
up9600_setup:
	ldx #0
@1:	stx outstat	; outstat used as temporary variable
	ldy #8
:	asl outstat
	ror a
	dey
	bne :-
	sta revtabup,x
	inx
	bpl @1

	jsr clear232

	jsr setbaudup

	lda #<newoutup
	ldx #>newoutup
	sta $0326
	stx $0327

	lda #<newinup
	ldx #>newinup
	sta $032a
	stx $032b

;----------------------------------------------------------------------
; enable serial interface (IRQ+NMI)
up9600_enable:
	sei

	ldx #<new_irq	; install new IRQ-handler
	ldy #>new_irq
	stx $0314
	sty $0315

	ldx #<nmi_startbit; install new NMI-handler
	ldy #>nmi_startbit
	stx $0318
	sty $0319

	ldx is_pal_system; PAL or NTSC version ?
	lda ilotab,x	; (keyscan interrupt once every 1/64 second)
	sta $dc06	; (sorry this will break code, that uses
	lda ihitab,x	; the ti$ - variable)
	sta $dc07	; start value for timer B (of CIA1)
	txa
	asl a

rcvlo=*+1
	eor #$00	; ** time constant for sender **
rvchi=*+1
	ldx #$00
	sta $dc04	; start value for timerA (of CIA1)
	stx $dc05	; (time is around 1/(2*baudrate) )

sndlo=*+1
	lda #$00
	sta $dd06	; start value for timerB (of CIA2)
sndhi=*+1
	lda #$00
	sta $dd07	; (time is around 1/baudrate )

	lda #$41	; start timerA of CIA1, SP1 used as output
	sta $dc0e	; generates the sender's bit clock
	lda #1
	sta outstat
	sta $dc0d	; disable timerA (CIA1) interrupt
	sta $dc0f	; start timerB of CIA1 (generates keyscan IRQ)
	lda #$92	; stop timerB of CIA2 (enable signal at PB7)
	sta $dd0f
	lda #$98
	bit $dd0d	; clear pending NMIs
	sta $dd0d	; enable NMI (SDR and FLAG) (CIA2)
	lda #$8a
	sta $dc0d	; enable IRQ (timerB and SDR) (CIA1)
	lda #$ff
	sta $dd01	; PB0-7 default to 1
	sta $dc0c	; SP1 defaults to 1
	lda #2		; enable RTS
	sta $dd03	; (the RTS line is the only output)
	cli
	rts

;----------------------------------------------------------------------
; new IRQ handler
new_irq:
	lda $dc0d	; cia1: cia interrupt control register
	lsr
	lsr
	and #$02
	beq @2
	ldx outstat
	beq @1
	dex
	stx outstat
@1:	bcc @end
@2:	cli
	jsr $ffea	; update jiffy clock
	jsr $ea87	; (jmp) - scan keyboard
@end:	jmp $ea81

ilotab:
	.byte $95
	.byte $25
ihitab:
	.byte $42
	.byte $40

;----------------------------------------------------------------------
setbaudup:
	lda baud_rate
b7e56	asl
	ora is_pal_system
	tax
	lda rcvtab_lo,x
	sta rcvlo
	lda rcvtab_hi,x
	sta rvchi
	lda sndtab_lo,x
	sta sndlo
	lda sndtab_hi,x
	sta sndhi
	rts

;----------------------------------------------------------------------
rcvtab_lo:
	.byte $b0	; 300  NTSC
	.byte $70	; 300  PAL
	.byte $a8	; 1200 NTSC
	.byte $98	; 1200 PAL
	.byte $d4	; 2400 NTSC
	.byte $cc	; 2400 PAL
	.byte $6a	; 4800 NTSC
	.byte $66	; 4800 PAL
	.byte $35	; 9600 NTSC
	.byte $33	; 9600 PAL
rcvtab_hi:
	.byte $06	; 300  NTSC
	.byte $06	; 300  PAL
	.byte $01	; 1200 NTSC
	.byte $01	; 1200 PAL
	.byte $00	; 2400 NTSC
	.byte $00	; 2400 PAL
	.byte $00	; 4800 NTSC
	.byte $00	; 4800 PAL
	.byte $00	; 9600 NTSC
	.byte $00	; 9600 PAL

sndtab_lo: ; (x2 of receive)
	.byte $50	; 300  NTSC
	.byte $d0	; 300  PAL
	.byte $50	; 1200 NTSC
	.byte $30	; 1200 PAL
	.byte $a8	; 2400 NTSC
	.byte $98	; 2400 PAL
	.byte $d4	; 4800 NTSC
	.byte $cc	; 4800 PAL
	.byte $6a	; 9600 NTSC
	.byte $66	; 9600 PAL
sndtab_hi:
	.byte $0d	; 300  NTSC
	.byte $0c	; 300  PAL
	.byte $03	; 1200 NTSC
	.byte $03	; 1200 PAL
	.byte $01	; 2400 NTSC
	.byte $01	; 2400 PAL
	.byte $00	; 4800 NTSC
	.byte $00	; 4800 PAL
	.byte $00	; 9600 NTSC
	.byte $00	; 9600 PAL

;----------------------------------------------------------------------
; new GETIN
newinup:
	lda DFLTN
	cmp #2		; see if default input is modem
	beq :+
	jmp ogetin	; nope, go back to original

:	jsr up9600_getxfer
	bcs :+		; if no character, then return 0 in a
	rts
:	clc
	lda #0
	rts

;----------------------------------------------------------------------
; get byte from serial interface
;  refer to this routine only if you wanna use it for
;  protocols (xmodem, punter etc)
up9600_getxfer:
	ldx rhead
	cpx rtail
	beq @1		; skip (empty buffer, return with carry set)
	lda ribuf,x
	inx
	stx rhead
	pha
	txa
	sec
	sbc rtail
	cmp #50
	bcc :+
	lda #2		; enable RTS if there are less than 50 bytes
	ora $dd01	; in the receive buffer
	sta $dd01
:  	clc
	pla
@1	rts

;----------------------------------------------------------------------
; new BSOUT
newoutup:
	pha		;dupliciaton of original kernal routines
	lda DFLTO	;test dfault output device for
	cmp #2		;screen, and...
	beq :+
	pla		;if so, go back to original rom routines
	jmp oldout
:
	pla
	sta rsotm
	stx rsotx
	sty rsoty
	pha
	cmp #$80
	and #$7f
	tax
	cli
	lda #$100-3
	sta JIFFIES
:	lda outstat
	beq :+
	bit JIFFIES
	bmi :-
:	lda #$04
	ora $dd00
	sta $dd00
:	lda $dd01	; cia2: data port register b
	and #$44
	eor #$04
	beq :-
	lda revtabup,x
	adc #0
	lsr
	sta $dc0c	; cia1: synchronous serial i/o data buffer
	lda #2
	sta outstat
	ror
	ora #$7f
	sta $dc0c	; cia1: synchronous serial i/o data buffer
	clc
	lda rsotm
	ldx rsotx
	ldy rsoty
	pla
	rts

;----------------------------------------------------------------------
; disable serial interface
up9600_disable:
	sei
	lda #$7f
	sta $dd0d	; disable all CIA interrupts
	sta $dc0d
	lda #$41	; quick (and dirty) hack to switch back
	sta $dc05	; to the default CIA1 configuration
	lda #$81
	sta $dc0d	; enable timer1 (this is default)

	lda #<oldnmi	; restore old NMI-handler
	sta $0318
	lda #>oldnmi
	sta $0319
	lda #<oldirq
	sta $0314	; irq
	lda #>oldirq
	sta $0315	; irq
	cli
	rts
