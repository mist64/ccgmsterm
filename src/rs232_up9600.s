; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz, Michael Steil. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; RS232 UP9600 Driver
;  based on source from "the UP9600 email", Nov 23 1997 by Daniel Dallmann
;  Message-Id: <199711301621.RAA01078@dosbuster.home.dd>
;

; calls from outside code:
;  up9600_setup
;  up9600_enable
;  up9600_disable
;  up9600_getxfer

outstat	= $a9	; re-used KERNAL symbol RER/RINONE

;----------------------------------------------------------------------
up9600_nmi:
	bit $dd0d	; check bit 7 (startbit ?)
nmi_bmi=*+1
	bmi nmi_startbit; IRQ caused by CIA
	rti		; ignore if NMI was triggered by RESTORE-key

nmi_startbit:
	pha
	lda #$13
	sta $dd0f	; start timer B (forced reload, signal at PB7)
	sta $dd0d	; disable timer and FLAG interrupts
	lda #nmi_bytrdy-nmi_bmi-1; on next NMI call nmi_bytrdy
	sta nmi_bmi	; (triggered by SDR full)
	pla
	rti

nmi_bytrdy:
	pha
	txa
	pha
	lda #$92
	sta $dd0f	; stop timer B (keep signalling at PB7!)
	sta $dd0d	; enable FLAG (and timer) interrupts
	lda #nmi_startbit-nmi_bmi-1; on next NMI call nmi_startbit
	sta nmi_bmi	; (triggered by a startbit)
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
	pla
	rti

;----------------------------------------------------------------------
up9600_setup:
; generate lookup table
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

	lda #nmi_startbit-nmi_bmi-1
	sta nmi_bmi
	ldx #<up9600_nmi; install new NMI-handler
	ldy #>up9600_nmi
	stx $0318
	sty $0319

	ldx is_pal_system; PAL or NTSC version ?
	lda ilotab,x	; (keyscan interrupt once every 1/64 second)
	sta $dc06	; (sorry this will break code, that uses
	lda ihitab,x	; the ti$ - variable)
	sta $dc07	; start value for timer B (of CIA1)

	lda sndlo	; ** time constant for sender **
	lsr
	sta $dc04	; start value for timerA (of CIA1)
	lda sndhi
	ror
	sta $dc05	; (time is around 1/(2*baudrate) )

sndlo=*+1
	lda #$00	; ** time constant for receiver **
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
	lda $dc0d	; read IRQ-mask
	lsr
	lsr		; move bit1 into carry-flag (timer B - flag)
	and #2		; test bit3 (SDR - flag)
	beq @2		; SDR not empty, then skip the first part
	ldx outstat
	beq @1		; skip, if we're not waiting for an empty SDR
	dex
	stx outstat
@1:	bcc @end	; skip if there was no timer-B-underflow
@2:	cli
	jsr $ffea	; update jiffy clock
	jsr $ea87	; (jmp) - scan keyboard
@end:	jmp $ea81

;----------------------------------------------------------------------
CLOCK_PAL	= 4433619 * 4 / 18	;   985,249 Hz
CLOCK_NTSC	= 3579545 * 4 / 14	; 1,022,727 Hz
TIMER_FREQ	= 60
ITIMER_NTSC	= (CLOCK_NTSC * 10 / TIMER_FREQ + 5) / 10	; $4295
ITIMER_PAL	= (CLOCK_PAL * 10 / TIMER_FREQ + 5) / 10	; $4025

.define itab ITIMER_NTSC, ITIMER_PAL
ilotab:	.lobytes itab
ihitab:	.hibytes itab

;----------------------------------------------------------------------
MIN_BAUD	= 300
TIMER_PAL	= CLOCK_PAL / MIN_BAUD
TIMER_NTSC	= CLOCK_NTSC / MIN_BAUD

setbaudup:
	lda #<TIMER_NTSC	; NTSC
	ldx #>TIMER_NTSC
	ldy is_pal_system
	beq :+
	lda #<TIMER_PAL
	ldx #>TIMER_PAL
:	sta sndlo
	stx sndhi

	ldx baud_rate	; 0=300, 1=2400, 2=4800 etc.
	beq :+
	inx		; -> 0=300, 2=400, 3=4800 etc.
:	txa
	beq @skip
@loop:	lsr sndhi	; divide by 2 repeatedly
	ror sndlo
	dex
	bne @loop
@skip:	rts

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
	cmp #$80	; move bit7 into carry-flag
	and #$7f	; get bits 1-7 from lookup table
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
:	lda $dd01	; check DTR/CTS line from RS232 interface
	and #$44
	eor #$04
	beq :-
	lda revtabup,x
	adc #0		; add bit0
	lsr
	sta $dc0c	; send startbit (=0) and the first 7 databits
	lda #2		; (2 IRQs per byte sent)
	sta outstat
	ror
	ora #$7f	; then send databit7 and 7 stopbits (=1)
	sta $dc0c	; (and wait for 2 SDR-empty IRQs or a timeout
	clc		; before sending the next databyte)
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
