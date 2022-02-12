; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Credits and instruction texts
;

txt_instructions1:
	.byte CLR,10,LTGRAY,15,LOCASE,RED,"   c",ORANGE,"c",YELLOW,"g",GREEN,"m",BLUE,"s",PURPLE
	.byte "! ",WHITE,"tERM "
	.byte "V2021 MODDED BY aLWYZ",CR,CR,RVSON
	.byte YELLOW,"cOMMANDS:",RVSOFF,CR,CR,BLUE,"c",RED,"=   ",WHITE,"stop"
	.byte "      ",CYAN,"dISCONNECT.",LTBLUE," (dROP dtr)",CR,WHITE,"ctrl j/k"
	.byte "       ",LTGREEN,"dEST/nON dEST cURSOR",CR
	.byte BLUE,"c",RED,"=   ",WHITE,"ctrl"
	.byte " 1-4  ",YELLOW,"tAKE A 'SNAPSHOT' OF THE",CR,"              "
	.byte "  SCREEN INTO STORAGE 1-4",CR
	.byte WHITE,"shft ctrl"
	.byte " 1-4  ",YELLOW
	.byte "rECALL sNAPSHOT 1-4",CR,"               (sWAPS W/CURRENT SCREEN)",CR
	.byte BLUE,"c",RED,"=   ",WHITE,"f7  "
	.byte "      ",YELLOW,"sTORES cURRENT sNAPSHOT",CR,"                IN BUFFER"
	.byte CR,WHITE,"ctrl f1/f3     ",PURPLE,"mACROS.",CR
	.byte WHITE,"ctrl f5/f7     ",PURPLE,"sEND uSER id/pASSWORD.",CR,CR
	.byte CYAN,"aT DISK PROMPT, \"#x\" CHANGES TO DEV#X.",CR
	.byte "dEVICES 8-29 ARE VALID.",CR
	.byte "sd2iec: \"CD/X\" CHANGES TO SUBDIR X",CR
	.byte "and \"CD:_\" CHANGES TO ROOT DIR.",CR
	.byte LTBLUE,"aT THE"
	.byte " BUFFER CMD PROMPT, ",WHITE,"< ",LTBLUE,"AND ",WHITE,">",CR,LTBLUE,"MOVES THE BUF"
	.byte "FER POINTER.",CR,LTGREEN,"oN-LINE, ",WHITE,"ctrl-b <COLOR-CODE> "
	.byte LTGREEN,"CHANGES",CR,"THE BACKGROUND COLOR.",WHITE," ctrl-n",LTGREEN," MAKES ",CR,"BACKGROUND BLACK.",WHITE
	.byte " ctrl-g",LTGREEN," BELL SOUND",CR,WHITE,"ctrl-v ",LTGREEN,"SFX SOUND",WHITE,"     pRESS A KEY...",0

txt_instructions2:
	.byte CLR,10,LTGRAY,15
	.byte WHITE,"   tHIS vERSION OF ccgms IS BASED ON",CR
	.byte LOCASE,"        ",RED,"c",ORANGE,"c",YELLOW,"g",GREEN,"m",BLUE,"s",WHITE,"! tERM "
	.byte "(C) 2016",CR
	.byte " BY cRAIG sMITH, aLL rIGHTS rESERVED.",CR,CR
	.byte LTGREEN,"tHIS PROGRAM IS OPEN SOURCE.",CR
	.byte "REDISTRIBUTION AND USE IN SOURCE AND",CR
	.byte "BINARY FORMS, WITH OR WITHOUT MODIFI-",CR
	.byte "CATION, ARE PERMITTED UNDER THE TERMS",CR
	.byte "OF THE bsd 3-CLAUSE LICENSE.",CR
	.byte "fOR DETAILS, OR TO CONTRIBUTE, VISIT:",CR
	.byte YELLOW," HTTPS://GITHUB.COM/SPATHIWA/CCGMSTERM",CR,CR
	.byte PURPLE,"a",LTBLUE,"L",CYAN,"W",LTGREEN,"Y",YELLOW,"Z",GRAY," WOULD LIKE TO THANK "
	.byte LTGREEN,"THE cbm",CR,"hACKERS mAILING lIST,",YELLOW," irc #C64FRIENDS,",CR
	.byte ORANGE,"PCOLLINS/EXCESS, LARRY/ROLE, XLAR54,",CR
	.byte ORANGE,"AND THE USERS OF afterlife bbs WHO",CR,"HELPED WITH "
	.byte LTRED,"TESTING, TIPS, AND BUGFIXES.",CR,CR
	.byte LTBLUE,"iT HAS BEEN MY PLEASURE TO MAINTAIN",CR,"THIS PROGRAM FROM 2017-2020 - ",PURPLE,"a",LTBLUE,"L",CYAN,"W",LTGREEN,"Y",YELLOW,"Z",GRAY,CR,CR
	.byte CR,LTGREEN,WHITE,"pRESS A KEY...",0

	.byte 0		; [XXX unused]