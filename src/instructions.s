; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Credits and instruction texts
;

SET_PETSCII
txt_instructions1:
	.byte CLR,10,LTGRAY,15,LOCASE,RED,"   C",ORANGE,"C",YELLOW,"G",GREEN,"M",BLUE,"S",PURPLE
	.byte "! ",WHITE,"Term "
	.byte "v2021 modded by Alwyz",CR,CR,RVSON
	.byte YELLOW,"Commands:",RVSOFF,CR,CR,BLUE,"C",RED,"=   ",WHITE,"STOP"
	.byte "      ",CYAN,"Disconnect.",LTBLUE," (Drop DTR)",CR,WHITE,"CTRL J/K"
	.byte "       ",LTGREEN,"Dest/Non Dest Cursor",CR
	.byte BLUE,"C",RED,"=   ",WHITE,"CTRL"
	.byte " 1-4  ",YELLOW,"Take a 'snapshot' of the",CR,"              "
	.byte "  screen into storage 1-4",CR
	.byte WHITE,"SHFT CTRL"
	.byte " 1-4  ",YELLOW
	.byte "Recall Snapshot 1-4",CR,"               (Swaps w/current screen)",CR
	.byte BLUE,"C",RED,"=   ",WHITE,"F7  "
	.byte "      ",YELLOW,"Stores Current Snapshot",CR,"                in buffer"
	.byte CR,WHITE,"CTRL F1/F3     ",PURPLE,"Macros.",CR
	.byte WHITE,"CTRL F5/F7     ",PURPLE,"Send User ID/Password.",CR,CR
	.byte CYAN,"At disk prompt, \"#X\" changes to dev#x.",CR
	.byte "Devices 8-29 are valid.",CR
	.byte "SD2IEC: \"cd/x\" changes to subdir x",CR
	.byte "AND \"cd:",$5f,"\" changes to root dir.",CR
	.byte LTBLUE,"At the"
	.byte " buffer cmd prompt, ",WHITE,"< ",LTBLUE,"and ",WHITE,">",CR,LTBLUE,"moves the buf"
	.byte "fer pointer.",CR,LTGREEN,"On-line, ",WHITE,"CTRL-B <color-code> "
	.byte LTGREEN,"changes",CR,"the background color.",WHITE," CTRL-N",LTGREEN," makes ",CR,"background black.",WHITE
	.byte " CTRL-G",LTGREEN," bell sound",CR,WHITE,"CTRL-V ",LTGREEN,"sfx sound",WHITE,"     Press a key...",0

txt_instructions2:
	.byte CLR,10,LTGRAY,15
	.byte WHITE,"   This Version of CCGMS is based on",CR
	.byte LOCASE,"        ",RED,"C",ORANGE,"C",YELLOW,"G",GREEN,"M",BLUE,"S",WHITE,"! Term "
	.byte "(c) 2016",CR
	.byte " by Craig Smith, All Rights Reserved.",CR,CR
	.byte LTGREEN,"This program is open source.",CR
	.byte "redistribution and use in source and",CR
	.byte "binary forms, with or without modifi-",CR
	.byte "cation, are permitted under the terms",CR
	.byte "of the BSD 3-clause license.",CR
	.byte "For details, or to contribute, visit:",CR
	.byte YELLOW," https://github.com/spathiwa/ccgmsterm",CR,CR
	.byte PURPLE,"A",LTBLUE,"l",CYAN,"w",LTGREEN,"y",YELLOW,"z",GRAY," would like to thank "
	.byte LTGREEN,"the CBM",CR,"Hackers Mailing List,",YELLOW," IRC #c64friends,",CR
	.byte ORANGE,"pcollins/excess, larry/role, xlar54,",CR
	.byte ORANGE,"and the users of AFTERLIFE BBS who",CR,"helped with "
	.byte LTRED,"testing, tips, and bugfixes.",CR,CR
	.byte LTBLUE,"It has been my pleasure to maintain",CR,"this program from 2017-2020 - ",PURPLE,"A",LTBLUE,"l",CYAN,"w",LTGREEN,"y",YELLOW,"z",GRAY,CR,CR
	.byte CR,LTGREEN,WHITE,"Press a key...",0
SET_ASCII

	.byte 0		; [XXX unused]
