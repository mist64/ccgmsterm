	.segment "S5C00"

ampag1
	.byte 147,10,155,15,14,'',28,'   c',129,'c',158,'g',30,'m',31,'s',156
	.byte '! ',5,'tERM '
	.byte 'V2021 MODDED BY aLWYZ',13,13,18
	.byte 158,'cOMMANDS:',146,13,13,31,'c',28,'=   ',5,'stop'
	.byte '      ',159,'dISCONNECT.',154,' (dROP dtr)',13,5,'ctrl j/k'
	.byte '       ',153,'dEST/nON dEST cURSOR',13
	.byte 31,'c',28,'=   ',5,'ctrl'
	.byte ' 1-4  ',158,'tAKE A ',39,'SNAPSHOT',39,' OF THE',13,'              '
	.byte '  SCREEN INTO STORAGE 1-4',13
	.byte 5,'shft ctrl'
	.byte ' 1-4  ',158
	.byte 'rECALL sNAPSHOT 1-4',13,'               (sWAPS W/CURRENT SCREEN)',13
	.byte 31,'c',28,'=   ',5,'f7  '
	.byte '      ',158,'sTORES cURRENT sNAPSHOT',13,'                IN BUFFER'
	.byte 13,5,'ctrl f1/f3     ',156,'mACROS.',13
	.byte 5,'ctrl f5/f7     ',156,'sEND uSER id/pASSWORD.',13,13
	.byte 159,'aT DISK PROMPT, "#x" CHANGES TO DEV#X.',13
	.byte 'dEVICES 8-29 ARE VALID.',13
	.byte 'sd2iec: "CD/X" CHANGES TO SUBDIR X',13
	.byte 'and "CD:',$5f,'" CHANGES TO ROOT DIR.',13
	.byte 154,'aT THE'
	.byte ' BUFFER CMD PROMPT, ',5,'< ',154,'AND ',5,'>',13,154,'MOVES THE BUF'
	.byte 'FER POINTER.',13,153,'oN-LINE, ',5,'ctrl-b <COLOR-CODE> '
	.byte 153,'CHANGES',13,'THE BACKGROUND COLOR.',5,' ctrl-n',153,' MAKES ',13,'BACKGROUND BLACK.',5
	.byte ' ctrl-g',153,' BELL SOUND',13,5,'ctrl-v ',153,'SFX SOUND',5,'     pRESS A KEY...',0
ampag2
	.byte 147,10,155,15
	.byte 5,'   tHIS vERSION OF ccgms IS BASED ON',13
	.byte 14,'        ',28,'c',129,'c',158,'g',30,'m',31,'s',5,'! tERM '
	.byte '(C) 2016',13
	.byte ' BY cRAIG sMITH, aLL rIGHTS rESERVED.',13,13
	.byte 153,'tHIS PROGRAM IS OPEN SOURCE.',13
	.byte 'REDISTRIBUTION AND USE IN SOURCE AND',13
	.byte 'BINARY FORMS, WITH OR WITHOUT MODIFI-',13
	.byte 'CATION, ARE PERMITTED UNDER THE TERMS',13
	.byte 'OF THE bsd 3-CLAUSE LICENSE.',13
	.byte 'fOR DETAILS, OR TO CONTRIBUTE, VISIT:',13
	.byte 158,' HTTPS://GITHUB.COM/SPATHIWA/CCGMSTERM',13,13
	.byte $9c,'a',$9a,'L',$9f,'W',$99,'Y',$9e,'Z',152,' WOULD LIKE TO THANK '
	.byte 153,'THE cbm',13,'hACKERS mAILING lIST,',158,' irc #C64FRIENDS,',13
	.byte 129,'PCOLLINS/EXCESS, LARRY/ROLE, XLAR54,',13
	.byte 129,'AND THE USERS OF afterlife bbs WHO',13,'HELPED WITH '
	.byte 150,'TESTING, TIPS, AND BUGFIXES.',13,13
	.byte 154,'iT HAS BEEN MY PLEASURE TO MAINTAIN',13,'THIS PROGRAM FROM 2017-2020 - ',$9c,'a',$9a,'L',$9f,'W',$99,'Y',$9e,'Z',152,13,13
	.byte 13,153,5,'pRESS A KEY...',0,0
