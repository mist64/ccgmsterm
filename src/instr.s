; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Instructions and credits
;

SET_PETSCII
txt_instructions1:
	.byte CLR,10,LTGRAY,15,LOCASE,RED,"   C",ORANGE,"C",YELLOW,"G",GREEN,"M",BLUE,"S",PURPLE,"! ",WHITE,"Term FUTURE ",VERSION,CR,CR
	.byte RVSON,YELLOW,"Commands:",RVSOFF,CR,CR
	.byte BLUE,"C",RED,"=   ",WHITE,"STOP      ",CYAN,"Disconnect.",LTBLUE," (Drop DTR)",CR
	.byte WHITE,"CTRL J/K       ",LTGREEN,"Dest/Non Dest Cursor",CR
	.byte BLUE,"C",RED,"=   ",WHITE,"CTRL 1-4  ",YELLOW,"Take a 'snapshot' of the",CR
	.byte "                screen into storage 1-4",CR
	.byte WHITE,"SHFT CTRL 1-4  ",YELLOW,"Recall Snapshot 1-4",CR
	.byte "               (Swaps w/current screen)",CR
	.byte BLUE,"C",RED,"=   ",WHITE,"F7        ",YELLOW,"Stores Current Snapshot",CR
	.byte "                in buffer",CR
	.byte WHITE,"CTRL F1/F3     ",PURPLE,"Macros.",CR
	.byte WHITE,"CTRL F5/F7     ",PURPLE,"Send User ID/Password.",CR,CR
	.byte CYAN,"At disk prompt, \"#X\" changes to dev#x.",CR
	.byte "Devices 8-29 are valid.",CR
	.byte "SD2IEC: \"cd/x\" changes to subdir x",CR
	.byte "AND \"cd:",$5f,"\" changes to root dir.",CR
	.byte LTBLUE,"At the buffer cmd prompt, ",WHITE,"< ",LTBLUE,"and ",WHITE,">",CR
	.byte LTBLUE,"moves the buffer pointer.",CR
	.byte LTGREEN,"On-line, ",WHITE,"CTRL-B <color-code> ",LTGREEN,"changes",CR
	.byte "the background color.",WHITE," CTRL-N",LTGREEN," makes ",CR
	.byte "background black.",WHITE," CTRL-G",LTGREEN," bell sound",CR
	.byte WHITE,"CTRL-V ",LTGREEN,"sfx sound",WHITE,"     Press a key...",0

txt_instructions2:
	.byte CLR,10,LTGRAY,15,WHITE,"   This Version of CCGMS is based on",CR
	.byte LOCASE,"        ",RED,"C",ORANGE,"C",YELLOW,"G",GREEN,"M",BLUE,"S",WHITE,"! Term (c) 2016",CR
	.byte " by Craig Smith, All Rights Reserved.",CR,CR
	.byte LTGREEN,"This program is open source.",CR
	.byte "redistribution and use in source and",CR
	.byte "binary forms, with or without modifi-",CR
	.byte "cation, are permitted under the terms",CR
	.byte "of the BSD 3-clause license.",CR
	.byte "For details, or to contribute, visit:",CR
	.byte YELLOW," https://github.com/mist64/ccgmsterm",CR,CR
	.byte PURPLE,"A",LTBLUE,"l",CYAN,"w",LTGREEN,"y",YELLOW,"z",GRAY," would like to thank ",LTGREEN,"the CBM",CR
	.byte "Hackers Mailing List,",YELLOW," IRC #c64friends,",CR
	.byte ORANGE,"pcollins/excess, larry/role, xlar54,",CR
	.byte ORANGE,"and the users of AFTERLIFE BBS who",CR
	.byte "helped with ",LTRED,"testing, tips, and bugfixes.",CR,CR
	.byte LTGREEN,WHITE,"Press a key...",0
SET_ASCII

	.byte 0		; [XXX unused]
