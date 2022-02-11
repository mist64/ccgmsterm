;THEME ROUTINES

tc1:	.byte WHITE,BLUE,WHITE,WHITE,BLUE,DKGRAY	; f1
tc2:	.byte LTRED,LTRED,BLUE,DKGRAY,DKGRAY,PURPLE	; Upload
tc3:	.byte WHITE,LTBLUE,WHITE,WHITE,PURPLE,GRAY	; f3
tc4:	.byte YELLOW,YELLOW,LTBLUE,BLUE,GRAY,LTBLUE	; Download
tc5:	.byte WHITE,CYAN,WHITE,WHITE,LTBLUE,LTGRAY	; f5
tc6:	.byte LTGREEN,LTGREEN,BLUE,PURPLE,LTGRAY,CYAN	; Disk
tc7:	.byte WHITE,LTGREEN,WHITE,WHITE,CYAN,LTGRAY	; f7
tc8:	.byte GREEN,CYAN,LTBLUE,LTBLUE,LTGRAY,LTGREEN	; Options
tc9:	.byte WHITE,BLUE,WHITE,WHITE,BLUE,DKGRAY	; f2
tc10:	.byte LTRED,LTRED,BLUE,BLUE,DKGRAY,PURPLE	; send/rec
tc11:	.byte WHITE,LTBLUE,WHITE,WHITE,PURPLE,GRAY	; f4
tc12:	.byte YELLOW,YELLOW,LTBLUE,PURPLE,GRAY,LTBLUE	; Buffer menu
tc13:	.byte WHITE,CYAN,WHITE,WHITE,LTBLUE,LTGRAY	; f6
tc14:	.byte LTGREEN,LTGREEN,BLUE,LTBLUE,LTGRAY,CYAN
tc15:	.byte WHITE,LTGREEN,WHITE,WHITE,CYAN,LTGRAY	; f8
tc16:	.byte GREEN,CYAN,LTBLUE,LTGRAY,LTGRAY,LTGREEN	; f8 text
tc17:	.byte BLUE,BLUE,CYAN,DKGRAY,DKGRAY,BLUE		; C
tc18:	.byte WHITE,YELLOW,WHITE,WHITE,LTGRAY,GRAY	; cf1
tc19:	.byte CYAN,LTBLUE,BLUE,LTGRAY,GRAY,YELLOW	; cf1 text
tc20:	.byte WHITE,YELLOW,WHITE,WHITE,LTGRAY,GRAY	; f3
tc21:	.byte CYAN,LTBLUE,BLUE,CYAN,GRAY,YELLOW		; f3 txt
tc22:	.byte WHITE,LTRED,WHITE,WHITE,WHITE,DKGRAY	; f5
tc23:	.byte LTBLUE,BLUE,LTBLUE,CYAN,DKGRAY,LTRED	; f5txt
tc24:	.byte WHITE,LTRED,WHITE,WHITE,WHITE,DKGRAY	; f7
tc25:	.byte LTBLUE,BLUE,LTBLUE,YELLOW,DKGRAY,LTRED	; f7txt
tc26:	.byte RED,RED,RED,GRAY,GRAY,RED			; = sign
tc27:	.byte WHITE,LTGREEN,LTGREEN,LTGREEN,LTGREEN,GRAY; f7 menu color
tc28:	.byte CYAN,LTRED,LTRED,LTRED,LTRED,LTBLUE	; phonebook color

themeroutine:
	ldy theme
	lda tc1,y
	sta txt_instructions1
	lda tc2,y
	sta txt_instructions1+8
	lda tc9,y
	sta txt_instructions1+25
	lda tc10,y
	sta txt_instructions1+31
	lda tc3,y
	sta txt_instructions1+47
	lda tc4,y
	sta txt_instructions1+55
	lda tc11,y
	sta txt_instructions1+72
	lda tc12,y
	sta txt_instructions1+78
	lda tc5,y
	sta txt_instructions1+95
	lda tc6,y
	sta txt_instructions1+103
	lda tc13,y
	sta txt_instructions1+120
	lda tc14,y
	sta txt_instructions1+126
	lda tc7,y
	sta txt_instructions1+137
	lda tc8,y
	sta txt_instructions1+145
	lda tc15,y
	sta txt_instructions1+162
	lda tc16,y
	sta txt_instructions1+168
	lda tc17,y
	sta txt_instructions2
	sta txt_instructions2+25
	sta txt_instructions2+50
	sta txt_instructions2+75
	lda tc26,y
	sta txt_instructions2+2
	sta txt_instructions2+27
	sta txt_instructions2+52
	sta txt_instructions2+77
	lda tc18,y
	sta txt_instructions2+4
	lda tc20,y
	sta txt_instructions2+29
	lda tc22,y
	sta txt_instructions2+54
	lda tc24,y
	sta txt_instructions2+79
	lda tc19,y
	sta txt_instructions2+10
	lda tc21,y
	sta txt_instructions2+35
	lda tc23,y
	sta txt_instructions2+60
	lda tc25,y
	sta txt_instructions2+85
	lda tc27,y
	sta f7mtx1
	sta f7mtxpre
	lda tc28,y
	sta curbtx+3
	sta curbt3+3
	sta curbt2
	sta curbt4
	sta curunl+3
	sta prtunl+3
	rts
