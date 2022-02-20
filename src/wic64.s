; CCGMS Terminal
;
; Copyright (c) 2022, Michael Steil. All rights reserved.
; This project is licensed under the BSD 2-Clause License.
;
; WiC64 Driver
;  based on "Simple Telnet Demo" source by KiWi, 2-clause BSD
;

;DEBUG	= 1

zpcmd=$40

;----------------------------------------------------------------------
wic64_funcs:
	.word wic64_setup
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0

wic64_setup:
    ldy #0
:   lda bbs01,y
    sta xbuffer,y
    iny
    cmp #$00
    bne :-

    lda #<commandserver
    sta $fe
    lda #>commandserver
    sta $ff

    ldy #$04
:   iny
    lda ($fe),y
    cmp #$00
    bne :-
    tya
    ldy #$01
    sta ($fe),y

    jsr sendcommand

    jsr get_status
    cmp #$02
    bne getdata           ; Could not connect

:	inc $d020
	jmp :-

getdata:
    lda #<commandget
    sta $fe
    lda #>commandget
    sta $ff
    jsr sendcommand
    jsr getanswer

    jsr $ffe4
    beq nokey
    sta commandputbyte+4

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

get_status:
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
    cpx #$02
    beq :+
    jsr read_byte
    lda #$00
    rts
:   jsr read_byte
    jsr read_byte
    lda #$02
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
    cpy #0
    bne @check2
    cpx #0
    beq @nomsg
@check2:
    cpx #0
    bne :+
    dey
:
    jsr read_byte
    jsr $ffd2
    dex
    bne :-
    dey
    cpy #$ff
    bne :-
@nomsg:
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
xbuffer:            .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
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


inputsize:          .byte 0

