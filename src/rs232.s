;----NEW RS232 Userport 300-2400 taken from Novaterm 9.6
;----cause everything else sucked

; user port serial drivers

rssetup

		sei

		jsr setbaud232

		lda #<nmi64
	ldy #>nmi64
	sta $0318
	sty $0319

	lda  #<rsout
	ldx  #>rsout
	sta  $326
	stx  $327

	lda  #<rsget
	ldx  #>rsget
	sta  $32a
	stx  $32b

		cli

		jmp clear232

bdloc
ntsc232	.word 3408,851,425    ; transmit times
	.word 4915,1090,459   ; startup bit times
	.word 3410,845,421    ; full bit times
pal232	.word 3283,820,409    ; transmit times for PAL
	.word 4735,1050,442   ; startup bit times for PAL
	.word 3285,814,406    ; full bit times for PAL

isbyte	.byte 0
lastring
	.byte 0

rsget		lda $99
	cmp #2                ; see if default input is modem
	beq jbgetrs
	jmp ogetin               ; nope, go back to original

jbgetrs	jsr rsgetxfer
		bcs  :+                ; if no character, then return 0 in a
	rts
:	clc
	lda #0
	rts

rsgetxfer
		ldx rhead
	cpx rtail
	beq :+                ; skip (empty buffer, return with carry set)
	lda ribuf,x
		pha
	inc rhead
	clc
		pla
:	rts


nmi64	pha             ; new nmi handler
	txa
	pha
	tya
	pha
nmi128	cld
	ldx $dd07       ; sample timer b hi byte
	lda #$7f        ; disable cia nmi's
	sta $dd0d
	lda $dd0d       ; read/clear flags
	;bpl notcia      ; (restore key)
nmi1	cpx $dd07
	ldy $dd01
	bcs mask
	ora #$02
	ora $dd0d
mask	and $02a1
	tax
	lsr
	bcc ckflag
	lda $dd00
	and #$fb
	ora $b5
	sta $dd00
ckflag	txa
	and #$10
	beq nmion
strtlo	lda #0
	sta $dd06
strthi	lda #0
	sta $dd07
	lda #$11
	sta $dd0f
	lda #$12
	eor $02a1
	sta $02a1
	sta $dd0d
fulllo	lda #0
	sta $dd06
fullhi	lda #0
	sta $dd07
	lda #$08
	sta $a8
	jmp chktxd
notcia	;ldy #$00
	;jmp rstkey      ; or jmp norest
nmion	lda $02a1          ;  receive a bit/byte
	sta $dd0d
	txa
	and #$02
	beq chktxd
	tya
	lsr
	ror $aa
	dec $a8
	bne txd
	    lda $aa
		ldx rtail         ;index to buffer
		sta ribuf,x     ;and store it
		inc rtail         ;move index to next slot
switch0	lda #$00
	sta $dd0f
	lda #$12
switch	ldy #$7f
	sty $dd0d
	sty $dd0d
	eor $02a1
	sta $02a1
	sta $dd0d
txd	txa
	lsr
chktxd	bcc nmiflow
	dec $b4
	bmi endbyte
	lda #$04
	ror $b6
	bcs store
low	lda #$00
store	sta $b5
nmiflow	lda $a8
		and #$08
		beq nmiexit
		clc
nmiexit	pla
	tay
	pla
	tax
	pla
	rti

endbyte	lda #0
	sta isbyte
txoff	ldx #$00            ;  turn transmit int off
	stx $dd0e
	lda #$01
	bne switch
		jmp disabl

rsout	pha             ; new bsout
	lda $9a
	cmp #02
	bne notmod
	pla
rsout5	sta $97
		stx $9e
		sty $9f
rsout2	lda $97
		sta $b6
	lda #0
	sta $b5
	lda #$09
	sta $b4
	lda #$ff
	sta isbyte
xmitlo	lda #0
	sta $dd04
xmithi	lda #0
	sta $dd05
	lda #$11
	sta $dd0e
	lda #$81
change	sta $dd0d
	php
	sei
	ldy #$7f
	sty $dd0d
	sty $dd0d
	ora $02a1
	sta $02a1
	sta $dd0d
	plp
rsout3	bit isbyte
	bmi rsout3
ret1	clc
		ldx $9e
		ldy $9f
		lda $97
		rts
notmod	pla
		jmp  oldout

disabl	pha
:	;lda $02a1;this fucks shit up... get rid of it...
	;and #$03
	;bne :-
	lda isbyte
	bne :-
	lda #$10
	sta $dd0d
	lda #$02
	and $02a1
	bne :-
	sta $02a1
	pla
	rts

inable	stx $9e         ; enable rs232 input
		sty $9f
	sta $97
		lda $02a1
	and #$12
	bne ret1
	sta $dd0f
	lda #$90
	jmp change

setbaud232
	lda baudrt
setbd0	asl
	clc
	adc ntsc
setbd1	tay
	lda bdloc,y
	sta xmitlo+1
	lda bdloc+1,y
	sta xmithi+1
	lda bdloc+6,y
	sta strtlo+1
	lda bdloc+7,y
	sta strthi+1
	lda bdloc+12,y
	sta fulllo+1
	lda bdloc+13,y
	sta fullhi+1
	rts

;----Swiftlink - Jeff Brown Adaptation of Novaterm version

stopsw	= 1
startsw	= 0

swift	= $de00               ; can be d to df00 or d700 depending

sw_data = swift                ; swiftlink registers
sw_stat = swift+1
sw_cmd  = swift+2
sw_ctrl = swift+3
sw_baud = swift+7

nmisw		pha
				txa
				pha
				tya
				pha
sm1				lda sw_stat
				and #%00001000	; mask out all but receive interrupt reg
				bne sm2 ; get outta here if interrupts are disabled (disk access etc)
				sec		; set carry upon return
				bcs recch1
sm2			lda         sw_cmd
				ora         #%00000010        ; disable receive interrupts
sm3			sta         sw_cmd
sm4				lda         sw_data
				ldx         rtail
				sta         ribuf,x
				inc         rtail
				inc         rfree
				lda rfree
				cmp         #200                ; check byte count against tolerance
				bcc         recch0            ; is it over the top?
				ldx         #stopsw
				stx paused ;x=1 for stop, by the way
				jsr         flow
recch0
sm5			lda         sw_cmd
				and         #%11111101        ; re-enable receive interrupt
sm6			sta         sw_cmd
recch2		clc
recch1		pla
				tay
				pla
				tax
				pla
				rti

flow
sm7		lda         sw_cmd
				and         #%11110011
				cpx         #stopsw
				beq         fl1
				ora         #%00001000
fl1
sm8		sta         sw_cmd
				rts

swwait
sm9			lda         sw_cmd
				ora         #%00001000        ; enable transmitter
sm10			sta         sw_cmd
sm11			lda         sw_stat
				and         #%00110000
				beq         swwait
				rts

disablsw
sm12		lda         sw_cmd
				ora #%00000010	; disable receive interrupt
sm13		sta         sw_cmd
			rts

inablesw
sm14				lda         sw_cmd
					and #%11111101	; enable receive interrupt
sm15				sta         sw_cmd
					rts

swsetup
				sei

;             .------------------------- parity control,
;             :.------------------------ bits 5-7
;             ::.----------------------- 000 = no parity
;             :::
;             :::.------------------- echo mode, 0 = normal (no echo)
;             ::::
;             :::: .----------- transmit interrupt control, bits 2-3
;             :::: :.---------- 10 = xmit interrupt off, RTS low
;             :::: ::
;             :::: ::.------ receive interrupt control, 0 = enabled
;             :::: :::
;             :::: :::.--- DTR control, 1=DTR low
	lda   #%00001001
sm16			sta   sw_cmd

;             .------------------------- 0 = one stop bit
;             :
;             :.-------------------- word length, bits 6-7
;             ::.------------------- 00 = eight-bit word
;             :::
;             :::.------------- clock source, 1 = internal generator
;             ::::
;             :::: .----- baud
;             :::: :.---- rate
;             :::: ::.--- bits   ;1010 == 4800 baud, changes later
;             :::: :::.-- 0-3
	lda   #%00010000
sm17			sta sw_ctrl

	lda         baudrt               ;0=300, 1=1200, 2=2400,3=4800,4=9600, 5=19200, 6=38400
setbaud		tax
sm18		lda         sw_ctrl
				and         #$f0
				ora         swbaud,x
sm19		sta         sw_ctrl

	lda        #<newout
	ldx        #>newout
	sta        $326
	stx        $327

	lda        #<newin
	ldx        #>newin
	sta        $32a
	stx        $32b

	lda        #<nmisw
	ldx        #>nmisw
	sta        $0318
	stx        $0319

	jsr clear232
		cli
	rts

newout		pha                        ;dupliciaton of original kernal routines
				lda         $9a                  ;test dfault output device for
				cmp         #$02                   ;screen, and...
		        beq         :+
				pla                        ;if so, go back to original rom routines
				jmp         oldout
:    			pla

rsoutsw
				sta $97
				stx $9e
				sty $9f
sm20		lda         sw_cmd
				sta         temp
				jsr         swwait
				lda         $97
sm21		sta         sw_data
				jsr         swwait
				lda         temp                ; restore rts state
sm22		sta         sw_cmd
				lda $97
				ldx $9e
				ldy $9f
				clc
				rts

dropdtr
sm23	lda sw_cmd
	and #%11111110
sm24	sta sw_cmd
	ldx #226
	stx $a2
wait30	bit $a2
	bmi wait30
	ora #%00000001
sm25	sta sw_cmd
	rts

newin	lda $99
	cmp #2                ; see if default input is modem
	beq jbgetsw
	jmp ogetin               ; nope, go back to original

jbgetsw	jsr swgetxfer
		bcs  :+                ; if no character, then return 0 in a
	rts
:	clc
	lda #0
	rts

swgetxfer
		ldx rhead
	cpx rtail
	beq @1                ; skip (empty buffer, return with carry set)
	lda ribuf,x
		pha
	inc rhead
		dec rfree
		ldx paused                ; are we stopped?
		beq :+                ; no, don't bother
		lda rfree                ; check buffer free
		cmp #50                ; against restart limit
		bcs :+                ; is it larger than 50?
		ldx #startsw          ;if no, then dont start yet
		stx paused
		jsr flow
:   clc
		pla
@1   rts

temp	.byte        0

paused	.byte $00

swbaud	.byte $15,$17,$18,$1a,$1c,$1e,$1f,$10,$10,$10

;--------------------------------------------------------------
UP9600

nmi_startbit:
	pha
		txa
		pha
		tya
		pha
	bit  $dd0d              ; check bit 7 (startbit ?)
	bpl  nv1                  ; no startbit received, then skip

	lda  #$13
	sta  $dd0f              ; start timer B (forced reload, signal at PB7)
	sta  $dd0d              ; disable timer and FLAG interrupts
	lda  #<nmi_bytrdy       ; on next NMI call nmi_bytrdy
	sta  $0318           ; (triggered by SDR full)
		lda  #>nmi_bytrdy       ; on next NMI call nmi_bytrdy
	sta  $0319           ; (triggered by SDR full)

nv1	pla	; ignore, if NMI was triggered by RESTORE-key
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
	bit  $dd0d              ; check bit 7 (SDR full ?)
	bpl  nv1                  ; SDR not full, then skip (eg. RESTORE-key)

	lda  #$92
	sta  $dd0f              ; stop timer B (keep signalling at PB7!)
	sta  $dd0d              ; enable FLAG (and timer) interrupts
	lda  #<nmi_startbit     ; on next NMI call nmi_startbit
	sta  $0318           ; (triggered by a startbit)
		lda  #>nmi_startbit     ; on next NMI call nmi_startbit
	sta  $0319           ; (triggered by a startbit)
	txa
	pha
	lda  $dd0c              ; read SDR (bit0=databit7,...,bit7=databit0)
	cmp  #128               ; move bit7 into carry-flag
	and  #127
	tax
	lda  revtabup,x           ; read databits 1-7 from lookup table
	adc  #0                 ; add databit0
	ldx  rtail            ; and write it into the receive buffer
	sta  ribuf,x
	inx
	stx  rtail
	sec
	txa
	sbc  rhead
	cmp  #200
	bcc  :+
	lda  $dd01              ; more than 200 bytes in the receive buffer
	and  #$fd               ; then disbale RTS
	sta  $dd01
:   pla
	tax
	jmp nv1

upsetup

	ldx  #0
@1   stx  outstat            ; outstat used as temporary variable
	ldy  #8
:   asl  outstat
	ror  a
	dey
	bne  :-
	sta  revtabup,x
	inx
	bpl  @1

	jsr clear232

		jsr setbaudup

	lda  #<newoutup
	ldx  #>newoutup
	sta  $326
	stx  $327

	lda  #<newinup
	ldx  #>newinup
	sta  $32a
	stx  $32b

	;; enable serial interface (IRQ+NMI)

enableup
	sei

	ldx  #<new_irq          ; install new IRQ-handler
	ldy  #>new_irq
	stx  $0314
	sty  $0315

	ldx  #<nmi_startbit     ; install new NMI-handler
	ldy  #>nmi_startbit
	stx  $0318
	sty  $0319

	ldx  ntsc               ; PAL or NTSC version ?
	lda  ilotab,x           ; (keyscan interrupt once every 1/64 second)
	sta  $dc06              ; (sorry this will break code, that uses
	lda  ihitab,x           ; the ti$ - variable)
	sta  $dc07              ; start value for timer B (of CIA1)
	txa
	asl  a

a7e0c	eor  #$00               ; ** time constant for sender **
a7e0e	ldx  #$00                 ; 51 or 55 depending on PAL/NTSC version
	sta  $dc04              ; start value for timerA (of CIA1)
	stx  $dc05              ; (time is around 1/(2*baudrate) )

a8e0c	lda  #$00
	    sta  $dd06              ; start value for timerB (of CIA2)
a8e0e	lda  #$00
		sta  $dd07              ; (time is around 1/baudrate )

	lda  #$41               ; start timerA of CIA1, SP1 used as output
	sta  $dc0e              ; generates the sender's bit clock
	lda  #1
	sta  outstat
	sta  $dc0d              ; disable timerA (CIA1) interrupt
	sta  $dc0f              ; start timerB of CIA1 (generates keyscan IRQ)
	lda  #$92               ; stop timerB of CIA2 (enable signal at PB7)
	sta  $dd0f
	lda  #$98
	bit  $dd0d              ; clear pending NMIs
	sta  $dd0d              ; enable NMI (SDR and FLAG) (CIA2)
	lda  #$8a
	sta  $dc0d              ; enable IRQ (timerB and SDR) (CIA1)
	lda  #$ff
	sta  $dd01              ; PB0-7 default to 1
	sta  $dc0c              ; SP1 defaults to 1
	lda  #2                 ; enable RTS
	sta  $dd03              ; (the RTS line is the only output)
		cli
	rts

		;; IRQ part

new_irq:
	    lda  $dc0d    ;cia1: cia interrupt control register
	lsr
	lsr
	and  #$02
	beq  b7d72
	ldx  $a9
	beq  b7d70
	dex
	stx  $a9;outstat
b7d70	bcc  b7da6
b7d72	cli
	jsr  $ffea ;$ffea - update jiffy clock
b7da3	jsr  $ea87 ;$ea87 (jmp) - scan keyboard
b7da6	jmp  $ea81

ilotab:
	.byte $95
	.byte $25
ihitab:
	.byte $42
	.byte $40

setbaudup
	lda baudrt
b7e56	asl
	ora ntsc
	tax
	lda f7e6c,x
	sta a7e0c+1
	lda f7e76,x
	sta a7e0e+1
		lda f8e6c,x
	sta a8e0c+1
		lda f8e76,x
	sta a8e0e+1
	rts

;recv
f7e6c		.byte $b0 ;0300
f7e6d		.byte $70
f7e6e	.byte $a8;1200
f7e6f	.byte $98
f7e70	.byte $d4;2400
f7e71	.byte $cc
f7e72	.byte $6a ;4800
f7e73	.byte $66
f7e74	.byte $35;9600 ntsc
f7e75	.byte $33;9600 pal
f7e76	.byte $06;300
f7e77	.byte $06
f7e78	.byte $01;1200
f7e79	.byte $01
f7e7a		.byte $00;2400
f7e7b		.byte $00
f7e7c		.byte $00;4800
f7e7d		.byte $00
f7e7e		.byte $00;9600 ntsc
f7e7f		.byte $00;9600 pal

;send (x2 of receive)
f8e6c		.byte $50 ;0300
f8e6d		.byte $d0
f8e6e	.byte $50;1200
f8e6f	.byte $30
f8e70	.byte $a8;2400
f8e71	.byte $98
f8e72	.byte $d4 ;4800
f8e73	.byte $cc
f8e74	.byte $6a;9600 ntsc
f8e75	.byte $66;9600 pal
f8e76	.byte $0d;300
f8e77	.byte $0c
f8e78	.byte $03;1200
f8e79	.byte $03
f8e7a		.byte $01;2400
f8e7b		.byte $01
f8e7c		.byte $00;4800
f8e7d		.byte $00
f8e7e		.byte $00;9600 ntsc
f8e7f		.byte $00;9600 pal

	;; get byte from serial interface

newinup	lda $99
	cmp #2                ; see if default input is modem
	beq jbgetup
	jmp ogetin               ; nope, go back to original

jbgetup	jsr upgetxfer
		bcs  :+                ; if no character, then return 0 in a
	rts
:	clc
	lda #0
	rts

upgetxfer
	; refer to this routine only if you wanna use it for protocols (xmodem.punter etc)
		ldx rhead
	cpx rtail
	beq @1                ; skip (empty buffer, return with carry set)
	lda ribuf,x
	inx
	stx rhead
	pha
	txa
	sec
	sbc rtail
	cmp #50
	bcc :+
	lda #2                 ; enable RTS if there are less than 50 bytes
	ora $dd01              ; in the receive buffer
	sta $dd01
:   clc
		pla
@1	rts

	;; put byte to serial interface

newoutup
	pha                        ;dupliciaton of original kernal routines
	lda  $9a                  ;test dfault output device for
	cmp  #$02                   ;screen, and...
	beq  :+
	pla                        ;if so, go back to original rom routines
	jmp  oldout
:
		pla
	sta $97
		stx $9e
		sty $9f
rsoutup	pha
		cmp  #$80
		and  #$7f
	tax
s7e80	cli
	lda #$fd
	sta $a2
b7e85	lda $a9
	beq b7e8d
	bit $a2
	bmi b7e85
b7e8d	lda  #$04
		ora  $dd00
		sta  $dd00
b7d3c	lda  $dd01    ;cia2: data port register b
	and  #$44
	eor  #$04
	beq  b7d3c
b7d45	lda  revtabup,x
	adc  #$00
	lsr
	sta  $dc0c    ;cia1: synchronous serial i/o data buffer
	lda  #$02
	sta  $a9
	ror
	ora  #$7f
	sta  $dc0c    ;cia1: synchronous serial i/o data buffer
		clc
	lda $97
		ldx $9e
		ldy $9f
		pla
	rts

	;; disable serial interface

disableup
		sei
	lda  #$7f
	sta  $dd0d              ; disable all CIA interrupts
	sta  $dc0d
	lda  #$41               ; quick (and dirty) hack to switch back
	sta  $dc05              ; to the default CIA1 configuration
	lda  #$81
	sta  $dc0d              ; enable timer1 (this is default)

	lda #<oldnmi    ; restore old NMI-handler
	sta $0318
	lda #>oldnmi
	sta $0319
	lda #<oldirq
	sta $0314     ;irq
	lda #>oldirq
	sta $0315     ;irq
	cli
	rts

;END UP9600

;reset modems here

enablemodem
	lda motype
	beq enablers1
	cmp #$01;up9600
	beq enableup1
	cmp #$02
	beq enablesw1
	cmp #$03
	beq enableswdf
	cmp #$04
	beq enableswd7
	rts

enableup1
	jmp upsetup
enablers1
	jmp rssetup
enablesw1
	lda #$de
	jmp swifttemp
enableswdf
	lda #$df
	jmp swifttemp
enableswd7
	lda #$d7

swifttemp
	sta sm1+2
	sta sm2+2
	sta sm3+2
	sta sm4+2
	sta sm5+2
	sta sm6+2
	sta sm7+2
	sta sm8+2
	sta sm9+2
	sta sm10+2
	sta sm11+2
	sta sm12+2
	sta sm13+2
	sta sm14+2
	sta sm15+2
	sta sm16+2
	sta sm17+2
	sta sm18+2
	sta sm19+2
	sta sm20+2
	sta sm21+2
	sta sm22+2
	sta sm23+2
	sta sm24+2
	sta sm25+2
	jmp swsetup

enablexfer
	pha
	txa
	pha
	tya
	pha
	lda motype
	beq enablersxfer
	cmp #$01;up9600
	beq enableupxfer

	jsr inablesw
	jmp xferout

enablersxfer
	jsr inable
	jmp xferout

enableupxfer
	jsr enableup
	jmp xferout

disablexfer
disablemodem
	pha
	txa
	pha
	tya
	pha
	lda motype
	beq disablers1
	cmp #$01;up9600
	beq disableup1

	jsr disablsw
	jmp xferout

disableup1
	jsr disableup
	jmp xferout

disablers1
	jsr disabl
	jmp xferout

xferout
	pla
	tay
	pla
	tax
	pla
	rts

modget

	lda motype
	beq modgetrs
	cmp #$01
	beq modgetup

	jmp swgetxfer

modgetup
	jmp upgetxfer

modgetrs
	jmp rsgetxfer

