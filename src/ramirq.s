; CCGMS Terminal
;
; Copyright (c) 2016,2022, Craig Smith, alwyz, Michael Steil. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; RAM->ROM IRQ and NMI Forward
;

;----------------------------------------------------------------------
setup_ram_irq_nmi:
	lda #<ramnmi
	sta $fffa
	lda #>ramnmi
	sta $fffb
	lda #<ramirq
	sta $fffe
	lda #>ramirq
	sta $ffff
	rts

;----------------------------------------------------------------------
ramnmi:
	pha
	lda $01
	pha
	lda #$37
	sta $01
	lda #>ramnm2
	pha
	lda #<ramnm2
	pha
	pha		; P
	lda tempch
	jmp $fe43
ramnm2:
	pla
	sta $01
	pla
	rti

ramirq:
	pha
	lda $01
	pha
	lda #$37
	sta $01
	lda #>ramirq2
	pha
	lda #<ramirq2
	pha
	lda #0		; P: B flag clear
	pha
	lda tempch
	jmp $ff48
ramirq2:
	pla
	sta $01
	pla
	rti

