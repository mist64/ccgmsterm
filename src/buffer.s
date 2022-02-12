; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Buffer manipulation functions
;

;----------------------------------------------------------------------
SET_PETSCII
txt_buffer:
	.byte WHITE,"Buffer ",0

txt_bufcmds:
	.byte " bytes free.  "
	.byte CR,HILITE
	.byte "open  "
	.byte HILITE
	.byte "close  "
	.byte HILITE
	.byte "erase  "
	.byte HILITE
	.byte "transfer"
	.byte CR,HILITE
	.byte "load  "
	.byte HILITE
	.byte "save   "
	.byte HILITE
	.byte "print  "
	.byte HILITE
	.byte "view: "
	.byte 0

txt_open:
	.byte "Open",0

txt_closed:
	.byte "Closed",0

txt_erase_buffer:
	.byte  "Erase Buffer! - "
	.byte HILITE
	.byte "yes or "
	.byte HILITE
	.byte "no?       "
	.byte CSR_LEFT,CSR_LEFT,CSR_LEFT,15
	.byte CSR_LEFT,CSR_LEFT,CSR_LEFT,0

txt_sending_buffer:
	.byte CR,CR
	.byte "Sending buffer..."
	.byte CR,CR,00

txt_done:
	.byte CR,CR,WHITE
	.byte "Done."
	.byte CR,0

txt_reu:
	.byte WHITE,"REU ",0
SET_ASCII

;----------------------------------------------------------------------
print_buffer_info:
	lda reu_enabled
	beq :+
	lda #<txt_reu
	ldy #>txt_reu
	jsr outstr
:	lda #<txt_buffer
	ldy #>txt_buffer
	jsr outstr
	lda buffer_open
	beq @1
	lda #<txt_open
	ldy #>txt_open
	clc
	bcc @2
@1:	lda #<txt_closed
	ldy #>txt_closed
@2:	jmp outstr

;----------------------------------------------------------------------
print_buffer_menu:
	lda #CR
	jsr chrout
	jsr print_buffer_info
	lda #' '
	jsr chrout
	lda #'-'
	jsr chrout
	lda #' '
	jsr chrout
	lda bufend
	sec
	sbc buffer_ptr
	tax
	lda bufend+1
	sbc buffer_ptr+1
	jsr outnum	; # of bytes free
	lda #<txt_bufcmds
	ldy #>txt_bufcmds
	jmp outstr

;----------------------------------------------------------------------
handle_f4_buffer:
	ldx SHFLAG
	cpx #SHFLAG_CBM
	jeq cf3_multi_receive

	jsr text_color_save
bufask
	lda #CR
	jsr chrout
	jsr print_buffer_menu
bufwat
	jsr invert_csr_char
:	jsr getin
	beq :-
	and #$7f
	pha
	jsr restore_csr_char
	pla
	cmp #CR
	bne bufcmd

return_to_term:
	lda #' '
	jsr chrout
	lda #CR
	jsr chrout
	jsr chrout
	jsr text_color_restore
	jsr enablexfer
	jmp term_mainloop

bufcmd:
; O: open
	cmp #'O'
	bne @no1
	ldx #1
	stx buffer_open
	bne bufex1
@no1:

; C: close
	cmp #'C'
	bne no2
	ldx #0
	stx buffer_open
bufex1
	ora #$80
bufexa
	jsr outcap
	lda #CR
	jsr chrout
	lda #CSR_UP
	ldx #4
:	jsr chrout
	dex
	bpl :-
	jmp bufask
no2

; E: erase
	cmp #'E'
	bne @no3
	ora #$80
	jsr outcap
	lda #CR
	jsr chrout
	lda #CSR_UP
	ldx #2
:	jsr chrout
	dex
	bpl :-
	lda #<txt_erase_buffer
	ldy #>txt_erase_buffer
	jsr outstr
	jsr invert_csr_char
:	jsr getin
	beq :-
	and #$7f
	cmp #'N'
	beq :+
	cmp #'Y'
	bne :-
	jsr bufclr
:	jsr restore_csr_char
	lda #CSR_UP
	jsr chrout
	jsr chrout
	jmp bufask
@no3

; P: print
	cmp #'P'
	bne @no4
	ora #$80
	jsr outcap
	jmp print_buffer
@no4

; V: view
	cmp #'V'
	bne no5
	lda #CLR
	jsr chrout
	lda #$80
	sta bufflg
	and #0
	sta buffl2
	jsr prtbuf
	jmp term_mainloop

;----------------------------------------------------------------------
; buf to screen
prtbuf:
	lda buffst
	pha
	lda buffst+1
	pha
	lda #$2f
	sta $00
	lda #$36	; disable BASIC ROM
	sta $01
	jsr dskout
	lda #$37	; enable BASIC ROM
	sta $01
	pla
	sta buffst+1
	pla
	sta buffst
	rts

;----------------------------------------------------------------------
get_memory_byte:
	ldx buffst
	cpx buffer_ptr
	bcc memok
	ldx buffst+1
	cpx buffer_ptr+1
	bcc memok
memgab	ldx #$40
	stx status
	rts

memok	ldy reu_enabled
	beq memok2
	jsr reuread
	jmp memok3
memok2
	ldy #0
	lda (buffst),y
memok3
	inc buffst
	bne memext
	inc buffst+1
memext
	ldx #0
	stx status
	rts

;----------------------------------------------------------------------
skpbuf
	lda buffst+1
	cmp buffer_ptr+1
	bcs memgab
	inc buffst+1
skpbf2
	lda buffst+1
	cmp buffer_ptr+1
	bcc memext
	lda buffst
	cmp buffer_ptr
	bcs memgab
	bcc memext
no5

; S: save
	cmp #'S'
	jne no6
	jsr solfil
	jmp savbuf
solfil
	ora #$80
	jsr outcap
	lda #CR
	jsr chrout
	jsr chrout
	jsr ui_get_filename
	bne solfok
	jmp ui_abort
solfok	rts
savbuf
	jsr disablexfer;to be save 5-13 fix?? worked without it, but this should be here
	lda #0
	sta mulcnt
	lda #2
	sta filetype
	jsr dowsfn
	lda #$36
	sta $01
	lda buffst;start of buffer
	sta $c1;I/O Start Address ($c1 $c2)
	lda buffst+1
	sta $c2
	lda buffer_ptr;end of buffer
	clc
	adc #1
	sta $ae;Tape End Addresses/End of Program ($ae / $af)
	lda buffer_ptr+1
	adc #0
	sta $af
	lda #$61
	sta $b9
	jsr $f3d5;open file on serial bus
	jsr $f68f;print saving and filename
	lda $ba
	jsr $ed0c;send listen to serial bus
	lda $b9
	jsr $edb9;LSTNSA. Send LISTEN secondary address to serial bus
	ldy #0
	jsr $fb8e;Move the Tape SAVE/LOAD Address into the Pointer at 172 ($ac)
	lda reu_enabled
	beq afuckit
	jsr af624
	lda #0
	sta buffst
	sta buffst+1
	jmp :+
afuckit	jsr $f624
:	php
	lda #$37
	sta $01
	plp
	bcc bsaved
	lda #CR
	jsr chrout
	jsr bell
	lda #0
	sta buffst
	sta buffst+1
	jmp ui_abort

;----------------------------------------------------------------------
;reu needs a special save routine cause craig decided to be all fancy with this one :)
af624	jsr $fcd1	; check the tape read/write pointer
	bcs @end
;	lda ($ac),y
	jsr reuread
	jsr $eddd	; send a byte to an i/o device over the serial bus
	jsr $ffe1	; stop. query stop key indicator, at memory address $0091; if pressed, call clrchn and clear keyboard buffer.
	bne :+
	jsr $f642
	lda #0
	sec
	rts
:	inc buffst
	lda buffst
	beq :+
	jsr $fcdb
	bne af624
:	inc buffst+1
	jsr $fcdb;advance tape pointer
	bne af624
@end:	jsr $edfe;UNLSTN.
	jmp $f642
;----------------------------------------------------------------------

bsaved
	jsr enablexfer
	jmp return_to_term
no6

; L: load
	cmp #'L'
	bne bufcm7
	jsr solfil
lodbuf
	jsr disablexfer;5-13 put in, didnt seem to need it, need to test with it. might crash with it cause the program does that sometimes....
	lda #2
	ldx device_disk
	tay
	jsr setlfs
	lda max
	ldx #<inpbuf
	ldy #>inpbuf
	jsr setnam
	jsr open
	ldx #LFN_FILE
	jsr chkin
lodbfl
	jsr getin
	ldx status
	bne lodbex
	ldx buffer_ptr
	cpx bufend
	bne lodbok
	ldx buffer_ptr+1
	cpx bufend+1
	beq lodbex
lodbok
	ldy reu_enabled
	beq lodbokram
	jsr reuwrite
	jmp lodbokreu
lodbokram
	ldy #0
	sta (buffer_ptr),y
lodbokreu
	inc buffer_ptr
	bne lodbfl
	inc buffer_ptr+1
	bne lodbfl
lodbex
	jsr clrchn
	lda #2
	jsr close
	jsr enablexfer
	jmp return_to_term
bufcm7

; T: transfer
	cmp #'T'
	beq send_buffer

; </>
	cmp #'<'
	beq :+
	cmp #'>'
	bne bufbak
:	jsr switch_buffer
	jmp bufexa

bufbak
	jmp bufwat


send_buffer:
	ora #$80
	jsr outcap
	lda #<txt_sending_buffer
	ldy #>txt_sending_buffer
	jsr outstr
	lda #$ff
	sta bufflg
	sta buffl2
	jsr prtbuf
	jsr text_color_save
	jsr clear232
	lda #<txt_done
	ldy #>txt_done
	jsr outstr
	jsr text_color_restore
	jsr enablexfer
	jmp term_mainloop

;----------------------------------------------------------------------
switch_buffer:
	pha
	cmp #'>'
	beq @3
	lda buffer_ptr+1
	cmp #>endprg
	bne @1
	lda buffer_ptr
	cmp #<endprg
	beq @end
@1:	lda buffer_ptr
	bne @2
	dec buffer_ptr+1
@2:	dec buffer_ptr
	jmp @end

@3:	lda buffer_ptr+1
	cmp bufend
	bne @4
	lda buffer_ptr
	cmp bufend+1
	beq @end
@4:	inc buffer_ptr
	bne @end
	inc buffer_ptr+1

@end:	ldx #1
	stx KOUNT
	pla
	rts

;----------------------------------------------------------------------
SET_PETSCII
txt_device:
	.byte CR,CR,"Device",0
txt_sec_addr:
	.byte CR,"SEC.A.: ",0
txt_printing:
	.byte CLR,CR,"PRINTING...",CR,0
SET_ASCII

;----------------------------------------------------------------------
print_buffer:
	lda #<txt_device
	ldy #>txt_device
	ldx #1
	jsr inpset
	lda #'4'
	jsr chrout
	jsr inputl
	bne @2
@1:	lda #CR
	jsr chrout
	jmp ui_abort

@2:	lda inpbuf
	cmp #'3'
	bcc @1
	cmp #'6'
	bcs @1
	and #$0f
	pha
	lda #<txt_sec_addr
	ldy #>txt_sec_addr
	ldx #1
	jsr inpset
	lda #'7'
	jsr chrout
	jsr inputl
	beq @1
	lda inpbuf
	cmp #'0'
	bcc @1
	cmp #'9'+1
	bcs @1
	and #$0f
	tay
	pla
	tax
	lda #LFN_PRINTER
	jsr setlfs
	lda #0
	jsr setnam
	lda #<txt_printing
	ldy #>txt_printing
	jsr outstr
	jsr open
	ldx status
	bne @3
	lda buffst
	pha
	lda buffst+1
	pha
	lda #$2f
	sta $00
	lda #$36	; disable BASIC ROM
	sta $01
	jsr print_buffer_bytes
	lda #$37	; enable BASIC ROM
	sta $01
	pla
	sta buffst+1
	pla
	sta buffst
@3:	lda #LFN_PRINTER
	jsr close
	lda #<txt_done
	ldy #>txt_done
	jsr outstr
	jsr text_color_restore
	jsr enablexfer
	jmp term_mainloop

;----------------------------------------------------------------------
print_buffer_bytes:
	jsr get_memory_byte
	bne @3
	pha
	and #$7f
	cmp #CR
	beq @1
	cmp #' '
	bcc @2
@1:	ldx #LFN_PRINTER
	jsr chkout
	pla
	jsr chrout
	ldx status
	bne @3
	jmp print_buffer_bytes
@2:	pla
	jmp print_buffer_bytes
@3:	jmp clrchn
