;EASYFLASH

;EF WRITE CONFIG

writeconfigef

jsr eapiinit

lda #$30      ; bank $30 (this is where the config is going to be stored).
ldy #$80      ; lorom
jsr $df83     ; erase sector (banks 30:0, 31:0, 32:0, 33:0, 34:0, 35:0, 36:0 and 37:0 are set to $ff)
jsr eapi2     ; delay 1.5 seconds after erase to let c64 physically finish its job for compatibility.
lda #$30      ; set bank $30 for the next read/write command.
jsr $df86
lda #$b0      ; set bank mode to llll (continue to next lo bank after current lo bank is full)
ldx #$00      ; set address to $8000,
ldy #$80      ; this is the position in the bank where the config is being stored, ie top of bank)
jsr $df8c
ldx #$00

f1080 lda $5100,x   ; this is where the config is positioned.
jsr $df95     ; write byte to ef, $0305 to $8000, $0306 to $8001, etc.
inx
bne f1080
inc f1080+2
lda f1080+2
cmp #$5c
bne f1080
lda #$51
sta f1080+2

lda #$04      ; cart off.
sta $de02
rts

f10b0   ldy #$00
ldx #$00
eapi3  inx
bne eapi3
dey
bne eapi3
rts
eapi2 jsr f10b0    ; delay 0,5 seconds
jsr f10b0    ; delay 0,5 seconds
jsr f10b0    ; delay 0,5 seconds
rts

;EF READ CONFIG

readconfigef

jsr eapiinit

;lda #$30      ; bank $30 (this is where the config is going to be stored).
;ldy #$80      ; lorom
;jsr $df83     ; erase sector (banks 30:0, 31:0, 32:0, 33:0, 34:0, 35:0, 36:0 and 37:0 are set to $ff)
;jsr eapi2     ; delay 1.5 seconds after erase to let c64 physically finish its job for compatibility.
lda #$30      ; set bank $30 for the next read/write command.
jsr $df86
lda #$b0      ; set bank mode to llll (continue to next lo bank after current lo bank is full)
ldx #$00      ; set address to $8000,
ldy #$80      ; this is the position in the bank where the config is being stored, ie top of bank)
jsr $df8c
ldx #$00

f1080r jsr $df92; read byte to ef, $0305 to $8000, $0306 to $8001, etc.
f1080rs sta $5100,x   ; this is where the config is positioned.
inx
bne f1080r
inc f1080rs+2
lda f1080rs+2
cmp #$5c
bne f1080r
lda #$51
sta f1080rs+2

lda #$04      ; cart off.
sta $de02
rts

eapiinit

lda #$07      ; cart on. banks visible from $8000-$bfff
sta $de02
lda #$00      ; select bank 0.
sta $de00
ldx #$00      ; copy eapi driver from bank 0 to ram at $1800. (eapi is always at $b800 in bank 0).
eapi1   lda $b800,x
sta $cb00,x
lda $b900,x
sta $cc00,x
lda $ba00,x
sta $cd00,x
inx
bne eapi1
jsr $cb14     ; init eapi driver. (routines copied to extra cart ram $df80-dfff)
rts

;END EF
