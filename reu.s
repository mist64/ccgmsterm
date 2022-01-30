;REU ROUTINES - 17XX REU. Only uses first bank regardless. 64k is more than enough memory

bufreu .byte $00;0-ram 1-reu

; detect REU

detectreu
		 ;jmp noreu;temp byte to default to no reu, for troubleshooting if needed

         ldx #2
loop1    txa
         sta $df00,x
         inx
         cpx #6
         bne loop1

         ldx #2
loop2    txa
         cmp $df00,x
         bne noreu
         inx
         cpx #6
         bne loop2

         lda #1
		 sta bufreu
		 lda #$00   ;set buffer start
         sta newbuf
		 sta newbuf+1
		 sta buffst
		 sta buffst+1
		 sta bufptr
		 sta bufptr+1
		 lda #$ff
		 sta bufend
		 sta bufend+1
         rts

noreu    lda #0
         sta bufreu
		 lda #<endprg   ;set buffer start
         sta buffst
         lda #>endprg
         sta buffst+1
		 lda #<buftop
		 sta bufend
		 lda #>buftop
		 sta bufend+1
         rts

bufend .byte $00,$00

;read/write to from reu

length   = 0001;one byte at a time

reuwrite
         sta bufptrreu
         pha
         lda #<bufptrreu
         sta $df02
         lda #>bufptrreu
         sta $df03
         lda bufptr
         sta $df04
         lda bufptr+1
         sta $df05
         lda #0
         sta $df06
         lda #<length
         sta $df07
         lda #>length
         sta $df08
         lda #0
         sta $df0a
c64toreu
         lda #$b0
         sta $df01
		 pla
		 rts

reuread
         lda #<buffstreu
         sta $df02
         lda #>buffstreu
         sta $df03
         lda buffst
         sta $df04
         lda buffst+1
         sta $df05
         lda #0
         sta $df06
         lda #<length
         sta $df07
         lda #>length
         sta $df08
         lda #0
         sta $df0a
reutoc64 lda #$b1
         sta $df01
		 lda buffstreu
		 rts

;END REU
