; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Theming
;

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
	sta tcol1
	lda tc2,y
	sta tcol2
	lda tc9,y
	sta tcol9
	lda tc10,y
	sta tcol10
	lda tc3,y
	sta tcol3
	lda tc4,y
	sta tcol4
	lda tc11,y
	sta tcol11
	lda tc12,y
	sta tcol12
	lda tc5,y
	sta tcol5
	lda tc6,y
	sta tcol6
	lda tc13,y
	sta tcol13
	lda tc14,y
	sta tcol14
	lda tc7,y
	sta tcol7
	lda tc8,y
	sta tcol8
	lda tc15,y
	sta tcol15
	lda tc16,y
	sta tcol16
	lda tc17,y
	sta tcol17a
	sta tcol17b
	sta tcol17c
	sta tcol17d
	lda tc26,y
	sta tcol26a
	sta tcol26b
	sta tcol26c
	sta tcol26d
	lda tc18,y
	sta tcol18
	lda tc20,y
	sta tcol20
	lda tc22,y
	sta tcol22
	lda tc24,y
	sta tcol24
	lda tc19,y
	sta tcol19
	lda tc21,y
	sta tcol21
	lda tc23,y
	sta tcol23
	lda tc25,y
	sta tcol25
	lda tc27,y
	sta tcol27a
	sta tcol27b
	lda tc28,y
	sta tcol28a
	sta tcol28b
	sta tcol28c
	sta tcol28d
	sta tcol28e
	sta tcol28f
	rts
