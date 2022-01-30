;THEME ROUTINES

tc1	.byte 05,31,05,05,31,151;f1
tc2	.byte 150,150,31,151,151,156;Upload
tc3	.byte 05,154,05,05,156,152;f3
tc4	.byte 158,158,154,31,152,154;Download
tc5	.byte 05,159,05,05,154,155;f5
tc6	.byte 153,153,31,156,155,159;Disk
tc7	.byte 05,153,05,05,159,155;f7
tc8	.byte 30,159,154,154,155,153;Options
tc9	.byte 05,31,05,05,31,151;f2
tc10	.byte 150,150,31,31,151,156;send/rec
tc11	.byte 05,154,05,05,156,152;f4
tc12	.byte 158,158,154,156,152,154;Buffer menu
tc13	.byte 05,159,05,05,154,155;f6
tc14	.byte 153,153,31,154,155,159
tc15	.byte 05,153,05,05,159,155;f8
tc16	.byte 30,159,154,155,155,153;f8 text
tc17	.byte 31,31,159,151,151,31;C
tc18	.byte 05,158,05,05,155,152;cf1
tc19	.byte 159,154,31,155,152,158;cf1 text
tc20	.byte 05,158,05,05,155,152;f3
tc21	.byte 159,154,31,159,152,158;f3 txt
tc22	.byte 05,150,05,05,05,151;f5
tc23	.byte 154,31,154,159,151,150;f5txt
tc24	.byte 05,150,05,05,05,151;f7
tc25	.byte 154,31,154,158,151,150;f7txt
tc26	.byte 28,28,28,152,152,28;= sign
tc27	.byte 05,153,153,153,153,152;f7 menu color
tc28	.byte 159,150,150,150,150,154;phonebook color

themeroutine
	ldy theme
	lda tc1,y
	sta instxt
	lda tc2,y
	sta instxt+8
	lda tc9,y
	sta instxt+25
	lda tc10,y
	sta instxt+31
	lda tc3,y
	sta instxt+47
	lda tc4,y
	sta instxt+55
	lda tc11,y
	sta instxt+72
	lda tc12,y
	sta instxt+78
	lda tc5,y
	sta instxt+95
	lda tc6,y
	sta instxt+103
	lda tc13,y
	sta instxt+120
	lda tc14,y
	sta instxt+126
	lda tc7,y
	sta instxt+137
	lda tc8,y
	sta instxt+145
	lda tc15,y
	sta instxt+162
	lda tc16,y
	sta instxt+168
	lda tc17,y
	sta instx2
	sta instx2+25
	sta instx2+50
	sta instx2+75
	lda tc26,y
	sta instx2+2
	sta instx2+27
	sta instx2+52
	sta instx2+77
	lda tc18,y
	sta instx2+4
	lda tc20,y
	sta instx2+29
	lda tc22,y
	sta instx2+54
	lda tc24,y
	sta instx2+79
	lda tc19,y
	sta instx2+10
	lda tc21,y
	sta instx2+35
	lda tc23,y
	sta instx2+60
	lda tc25,y
	sta instx2+85
	lda tc27,y
	sta f7mtx1+1
	sta f7mtxpre+3
	lda tc28,y
	sta curbtx+3
	sta curbt3+3
	sta curbt2
	sta curbt4
	sta curunl+3
	sta prtunl+3
	rts

;END of THEME ROUTINE
