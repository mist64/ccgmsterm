
start:
    lda #$00                ; Black fore and background
    sta $d020
    sta $d021
    lda #$01                ; White text color
    sta $0286
    jsr $e544               ; Clr screen

    lda #<text
    sta $fe
    lda #>text
    sta $ff
    jsr printtext

loop:
    jsr $ffe4               ; Keyboard input
    ldy #$00
key1:
    cmp #'1'
    bne key2
    jmp doserver01         ; jmp anstatt beq - offsets zu groß
key2:
    cmp #'2'
    bne key3
    jmp doserver02
key3:
    cmp #'3'
    bne key4
    jmp doserver03
key4:
    cmp #'4'
    bne key5
    jmp doserver04
key5:
    cmp #'5'
    bne key9
    jmp doserver05
key9:
    cmp #'9'
    bne loop
    jmp owninput

doserver01:
    lda bbs01,y
    sta buffer,y
    iny
    cmp #$00
    bne doserver01
    jmp connect

doserver02:
    lda bbs02,y
    sta buffer,y
    iny
    cmp #$00
    bne doserver02
    jmp connect

doserver03:
    lda bbs03,y
    sta buffer,y
    iny
    cmp #$00
    bne doserver03
    jmp connect

doserver04:
    lda bbs04,y
    sta buffer,y
    iny
    cmp #$00
    bne doserver04
    jmp connect

doserver05:
    lda bbs05,y
    sta buffer,y
    iny
    cmp #$00
    bne doserver05
    jmp connect


owninput:
    ldy #$00
doservername:
    lda servername,y
    jsr $ffd2
    iny
    cmp #$00
    bne doservername

DoInput:
    ldy #$00
    lda #$00
clearbuff:
    sta buffer,y
    iny
    cpy #100
    bne clearbuff

    jsr $A560
    lda $0200
    cmp #$00        ; Eingabebuffer leer
    beq inp1done

    ldx #$00
    ldy #$00
inp1:
    lda $0200,y
    cmp #$00
    beq inp1done
    jsr charconvert
    sta buffer,x
    inx
    iny
    bne inp1
inp1done:


connect:

    lda #<commandserver
    sta $fe
    lda #>commandserver
    sta $ff
    jsr fixsting
    jsr sendcommand

    lda #$0d
    jsr $ffd2

    jsr getanswer
    cmp #$02
    bne getdata           ; Could not connect
    jmp start

getdata:
    lda #<commandget
    sta $fe
    lda #>commandget
    sta $ff
    jsr sendcommand

    jsr getanswer
    cmp #$01
    bne getdata       ; Es sind noch Daten abzuholen - so lange loopen und ausgeben !
    cmp #$02
    bne inputchar
    jmp start

inputchar:
    jsr $ffe4
    beq nokey
    sta commandputbyte+4
    cmp #$85
    beq f1
    cmp #$86
    beq f3
    cmp #$88
    beq f7
    jmp putbyte

f1:
    jmp start
f3:

    ldy #$00
    lda #$00
clearbuff2:
    sta stringbuffer,y
    iny
    cpy #100
    bne clearbuff2

    jsr $A560
    lda $0200
    cmp #$00        ; Eingabebuffer leer
    beq inp2done

    ldx #$00
    ldy #$00
inp2:
    lda $0200,y
    cmp #$00
    beq inp2done
    jsr charconvert
    sta stringbuffer,x
    inx
    iny
    bne inp2
inp2done:

    lda #<commandputstring
    sta $fe
    lda #>commandputstring
    sta $ff
    jsr fixsting
    jsr sendcommand
    jsr getanswer
    cmp #$02              ; disconnected
    bne loopdata
    jmp start             ; disconnected
loopdata:
    jmp getdata

f7:
    lda #$0a
    sta commandputbyte+4
    jmp putbyte

putbyte:
    lda #<commandputbyte
    sta $fe
    lda #>commandputbyte
    sta $ff
    jsr sendcommand

    jsr getanswer
    cmp #$02              ; disconnected
    bne nokey
    jmp start
nokey:
    jmp getdata



end:
    lda #$ff      ; Datenrichtung Port B Ausgang
    sta $dd03

    lda $dd00
    ora #$04      ; PA2 auf HIGH = ESP im Empfangsmodus
    sta $dd00



    cli
    lda #$00
    rts

fixsting:
    ldy #$04
countstring:
    iny
    lda ($fe),y
    cmp #$00
    bne countstring
    tya
    ldy #$01
    sta ($fe),y
    rts

sendcommand:

    lda $dd02
    ora #$04
    sta $dd02               ; Datenrichtung Port A PA2 auf Ausgang
    lda #$ff                ; Datenrichtung Port B Ausgang
    sta $dd03
    lda $dd00
    ora #$04                ; PA2 auf HIGH = ESP im Empfangsmodus
    sta $dd00

    ldy #$01
    lda ($fe),y             ; Länge des Kommandos holen
    sec
    sbc #$01
    sta stringexit+1        ; Als Exit speichern

    ldy #$ff
string_next:
    iny
    lda ($fe),y
    jsr write_byte
stringexit:
    cpy #$00                ; Selbstmodifizierender Code - Hier wird die länge des Kommandos eingetragen -> Siehe Ende von send_string
    bne string_next
    rts

getanswer:
    lda #$00      ; Datenrichtung Port B Eingang
    sta $dd03
    lda $dd00
    and #251      ; PA2 auf LOW = ESP im Sendemodus
    sta $dd00


    jsr read_byte   ;; Dummy Byte -


    jsr read_byte
    tay
    jsr read_byte
    sta inputsize
    tax
    cpy #$00      ; Mehr als $0100 bytes als Rückgabe
    bne check2
    cpx #$00      ; Mehr als 1 bytes als Rückgabe
    beq nomsg     ; Keine Sendedaten vorhanden (Antwort $00 $00)
    cpx #$01
    beq noerrorcode
    cpx #$02
    beq errorcode
    jmp check2
noerrorcode:
    jsr read_byte
    cmp #$30
    bne printit
    lda #$00
    rts
errorcode:
    jsr read_byte
    cmp #$21
    bne printit
    jsr read_byte
    lda #$02
    rts

check2:
    cpx #$00
    bne goread
    dey

goread:
    jsr read_byte
printit:
    jsr $ffd2
    dex
    bne goread
    dey
    cpy #$ff
    bne goread
    lda #$00
    rts
nomsg:
    lda #$01
    rts


write_byte:

    sta $dd01       ; Bit 0..7: Userport Daten PB 0-7 schreiben

dowrite:
    lda $dd0d
    and #$10        ; Warten auf NMI FLAG2 = Byte wurde gelesen vom ESP
    beq dowrite
    rts

read_byte:

doread:
    lda $dd0d
    and #$10        ; Warten auf NMI FLAG2 = Byte wurde gelesen vom ESP
    beq doread

    lda $dd01
    rts

charconvert:
    rts
    cmp #$c0
    bcs con2
    cmp #$40
    bcs con1
    rts
con1:
    clc
    adc #$20
    rts
con2:
    sec
    sbc #$80
    rts


printtext:
    ldy #$00
printloop:
    lda ($fe),y
    cmp #$00
    beq printdone
    jsr $ffd2
    iny
    bne printloop
    inc $ff
    jmp printtext
printdone:
    rts

servername:                .byte $0d,$0a,$0d,$0a,$0e,"server:port->",$00
prefdata:                   .byte "data: ",$00

commandget:                 .byte "W",$04,$00,34
commandputbyte:             .byte "W",$05,$00,35,$00
commandputstring:           .byte "W",$00,$00,35
stringbuffer:               .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                            .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                            .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


commandserver:           .byte "W",$00,$00,33
buffer:            .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                   .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                   .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

text:               .byte $0e,"  wIc64 simple telnet demo 1.1 by kIwI",$0d
                    .byte "----------------------------------------",$0d,$0d
                    .byte " 1: 13th.hoyvision.com:6400",$0d,$0a
                    .byte " 2: cib.dyndns.org:6405",$0d,$0a
                    .byte " 3: darklevel.hopto.org:64128",$0d,$0a
                    .byte " 4: rapidfire.hopto.org:64128",$0d,$0a
                    .byte " 5: raveolution.hopto.org:64128",$0d,$0a
                    .byte " 9: ENTER YOUR OWN SERVER",$0d,$0a,$0d,$0a,$0d,$0a
                    .byte " wHILE RUNNING:",$0d,$0a,$0d,$0a
                    .byte " f1=mAIN MENU",$0d,$0a
                    .byte " f3=iNPUT STRING & SEND DATA",$0d,$0a,$00


bbs01:
	.byte "192.168.176.104:25232",0
    ;.byte "13th.hoyvision.com:6400",0
bbs02:       .byte "cib.dyndns.org:6405",0
bbs03:       .byte "darklevel.hopto.org:64128",0
bbs04:       .byte "rapidfire.hopto.org:64128",0
bbs05:       .byte "raveolution.hopto.org:64128",0

inputsize:          .byte 0
inputbuffer:        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0



