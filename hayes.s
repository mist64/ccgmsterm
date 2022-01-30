;CARRIER / BUSY / NO ANSWER DETECT

bustemp .byte $00

haybus
ldy #$00
sty bustemp
haybus2
jsr newgethayes
haybus3
jsr puthayes
cpy #$ff
jeq hayout;get out of routine. send data to terminal, and set connect!
jsr newgethayes
cmp #$62 ;b
bne haynocarr;move to check for no carrier
jsr puthayes
jsr newgethayes
cmp #$75 ;u
bne haybus3
jsr puthayes
jsr newgethayes
cmp #$73 ;s
bne haybus3
jsr puthayes
jsr newgethayes
cmp #$79 ;y
bne haybus3
ldy #$00
sty bustemp
jmp haybak ; busy!
;
haynocarr
cmp #$6e ;n
bne haybusand;move to next char
jsr puthayes
jsr newgethayes
cmp #$6f ;o
bne haybus3
jsr puthayes
jsr newgethayes
cmp #$20 ;' '
bne haybus3
jsr puthayes
jsr newgethayes
cmp #$63 ;c
jne haynoanswer
jsr puthayes
jsr newgethayes
cmp #$61 ;a
bne haybus3
jsr puthayes
jsr newgethayes
cmp #$72 ;r
bne haybus3
jsr puthayes
jsr newgethayes
cmp #$72 ;r
bne haybus3
ldy #$00
sty bustemp
jmp haynan ; no carrier!
;
haybusand
cmp #$42 ;b
bne haynocarrand;move to check for no carrier
jsr puthayes
jsr newgethayes
cmp #$55 ;u
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$53 ;s
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$59 ;y
jne haybus3
ldy #$00
sty bustemp
jmp haybak ; busy!
;
haynocarrand
cmp #$4e ;n
jne haybus3;move to next char
jsr puthayes
jsr newgethayes
cmp #$4f ;o
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$20 ;' '
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$43 ;c
bne haynoanswerand
jsr puthayes
jsr newgethayes
cmp #$41 ;a
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$52 ;r
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$52 ;r
jne haybus3
ldy #$00
sty bustemp
jmp haynan ; no carrier!

haynoanswerand
cmp #$41 ;a
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$4e ;n
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$53 ;s
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$57 ;w
jne haybus3
ldy #$00
sty bustemp
jmp haynan ; no carrier!

haynoanswer
cmp #$61 ;a
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$6e ;n
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$73 ;s
jne haybus3
jsr puthayes
jsr newgethayes
cmp #$77 ;w
jne haybus3
ldy #$00
sty bustemp
jmp haynan ; no carrier!

;
hayout
sty bustemp
jmp haycon
;
newgethayes
inc waittemp;timeout for no character loop so
ldx waittemp;so it doesn't lock up
cpx #$90;maybe change for various baud rates
beq newget2
ldx #$05
jsr chkin
jsr getin
beq newgethayes

newget2
ldx #$00
stx waittemp
 rts

puthayes
ldy bustemp
iny
sty bustemp
sta tempbuf,y
rts

waittemp .byte $00
