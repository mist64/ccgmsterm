; CCGMS Terminal
;
; This file is in the public domain.
;
; 4x8 PETSCII charset from "80COLUMNS" (freeware, author unknown)

.segment "CHARSET"	; purgeable

.global charset
.global charset_ascii_patches, charset_petscii_patches

.macro dnyb n
	.byte n | (n << 4)
.endmacro

charset:
; 0x00	0x0040	# COMMERCIAL AT
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0111
        dnyb %0111
        dnyb %0100
        dnyb %0011
        dnyb %0000
; 0x01	0x0061	# LATIN SMALL LETTER A
        dnyb %0000
        dnyb %0000
        dnyb %0110
        dnyb %0001
        dnyb %0011
        dnyb %0101
        dnyb %0011
        dnyb %0000
; 0x02	0x0062	# LATIN SMALL LETTER B
        dnyb %0000
        dnyb %0100
        dnyb %0100
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0110
        dnyb %0000
; 0x03	0x0063	# LATIN SMALL LETTER C
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0100
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x04	0x0064	# LATIN SMALL LETTER D
        dnyb %0000
        dnyb %0001
        dnyb %0001
        dnyb %0011
        dnyb %0101
        dnyb %0101
        dnyb %0011
        dnyb %0000
; 0x05	0x0065	# LATIN SMALL LETTER E
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0111
        dnyb %0100
        dnyb %0010
        dnyb %0000
; 0x06	0x0066	# LATIN SMALL LETTER F
        dnyb %0000
        dnyb %0010
        dnyb %0100
        dnyb %0110
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0000
; 0x07	0x0067	# LATIN SMALL LETTER G
        dnyb %0000
        dnyb %0000
        dnyb %0011
        dnyb %0101
        dnyb %0101
        dnyb %0011
        dnyb %0001
        dnyb %0110
; 0x08	0x0068	# LATIN SMALL LETTER H
        dnyb %0000
        dnyb %0100
        dnyb %0100
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x09	0x0069	# LATIN SMALL LETTER I
        dnyb %0000
        dnyb %0010
        dnyb %0000
        dnyb %0110
        dnyb %0010
        dnyb %0010
        dnyb %0111
        dnyb %0000
; 0x0A	0x006A	# LATIN SMALL LETTER J
        dnyb %0000
        dnyb %0001
        dnyb %0000
        dnyb %0011
        dnyb %0001
        dnyb %0001
        dnyb %0101
        dnyb %0010
; 0x0B	0x006B	# LATIN SMALL LETTER K
        dnyb %0000
        dnyb %0100
        dnyb %0100
        dnyb %0101
        dnyb %0110
        dnyb %0110
        dnyb %0101
        dnyb %0000
; 0x0C	0x006C	# LATIN SMALL LETTER L
        dnyb %0000
        dnyb %0110
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0111
        dnyb %0000
; 0x0D	0x006D	# LATIN SMALL LETTER M
        dnyb %0000
        dnyb %0000
        dnyb %0101
        dnyb %0111
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x0E	0x006E	# LATIN SMALL LETTER N
        dnyb %0000
        dnyb %0000
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x0F	0x006F	# LATIN SMALL LETTER O
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x10	0x0070	# LATIN SMALL LETTER P
        dnyb %0000
        dnyb %0000
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0110
        dnyb %0100
        dnyb %0100
; 0x11	0x0071	# LATIN SMALL LETTER Q
        dnyb %0000
        dnyb %0000
        dnyb %0011
        dnyb %0101
        dnyb %0101
        dnyb %0011
        dnyb %0001
        dnyb %0001
; 0x12	0x0072	# LATIN SMALL LETTER R
        dnyb %0000
        dnyb %0000
        dnyb %0110
        dnyb %0101
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0000
; 0x13	0x0073	# LATIN SMALL LETTER S
        dnyb %0000
        dnyb %0000
        dnyb %0011
        dnyb %0100
        dnyb %0010
        dnyb %0001
        dnyb %0110
        dnyb %0000
; 0x14	0x0074	# LATIN SMALL LETTER T
        dnyb %0000
        dnyb %0100
        dnyb %0110
        dnyb %0100
        dnyb %0100
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x15	0x0075	# LATIN SMALL LETTER U
        dnyb %0000
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0011
        dnyb %0000
; 0x16	0x0076	# LATIN SMALL LETTER V
        dnyb %0000
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x17	0x0077	# LATIN SMALL LETTER W
        dnyb %0000
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0111
        dnyb %0101
        dnyb %0000
; 0x18	0x0078	# LATIN SMALL LETTER X
        dnyb %0000
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x19	0x0079	# LATIN SMALL LETTER Y
        dnyb %0000
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0011
        dnyb %0001
        dnyb %0110
; 0x1A	0x007A	# LATIN SMALL LETTER Z
        dnyb %0000
        dnyb %0000
        dnyb %0111
        dnyb %0001
        dnyb %0010
        dnyb %0100
        dnyb %0111
        dnyb %0000
; 0x1B	0x005B	# LEFT SQUARE BRACKET
        dnyb %0000
        dnyb %0110
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0110
        dnyb %0000
; 0x1C	0x00A3	# POUND SIGN
        dnyb %0000
        dnyb %0011
        dnyb %0010
        dnyb %0111
        dnyb %0010
        dnyb %0010
        dnyb %0111
        dnyb %0000
; 0x1D	0x005D	# RIGHT SQUARE BRACKET
        dnyb %0000
        dnyb %0011
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0011
        dnyb %0000
; 0x1E	0x2191	# UPWARDS ARROW
        dnyb %0000
        dnyb %0010
        dnyb %0111
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0000
; 0x1F	0x2190	# LEFTWARDS ARROW
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0100
        dnyb %0111
        dnyb %0100
        dnyb %0010
        dnyb %0000
; 0x20	0x0020	# SPACE
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x21	0x0021	# EXCLAMATION MARK
        dnyb %0000
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0000
        dnyb %0010
        dnyb %0000
; 0x22	0x0022	# QUOTATION MARK
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x23	0x0023	# NUMBER SIGN
        dnyb %0000
        dnyb %0101
        dnyb %0111
        dnyb %0101
        dnyb %0111
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x24	0x0024	# DOLLAR SIGN
        dnyb %0000
        dnyb %0011
        dnyb %0110
        dnyb %0010
        dnyb %0011
        dnyb %0111
        dnyb %0010
        dnyb %0000
; 0x25	0x0025	# PERCENT SIGN
        dnyb %0000
        dnyb %0101
        dnyb %0001
        dnyb %0010
        dnyb %0010
        dnyb %0100
        dnyb %0101
        dnyb %0000
; 0x26	0x0026	# AMPERSAND
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0101
        dnyb %0111
        dnyb %0000
; 0x27	0x0027	# APOSTROPHE
        dnyb %0000
        dnyb %0001
        dnyb %0010
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x28	0x0028	# LEFT PARENTHESIS
        dnyb %0000
        dnyb %0010
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0010
        dnyb %0000
; 0x29	0x0029	# RIGHT PARENTHESIS
        dnyb %0000
        dnyb %0010
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0010
        dnyb %0000
; 0x2A	0x002A	# ASTERISK
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0101
        dnyb %0010
        dnyb %0101
        dnyb %0000
        dnyb %0000
; 0x2B	0x002B	# PLUS SIGN
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0010
        dnyb %0111
        dnyb %0010
        dnyb %0010
        dnyb %0000
; 0x2C	0x002C	# COMMA
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0100
        dnyb %0000
; 0x2D	0x002D	# HYPHEN-MINUS
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0111
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x2E	0x002E	# FULL STOP
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0000
; 0x2F	0x002F	# SOLIDUS
        dnyb %0000
        dnyb %0001
        dnyb %0001
        dnyb %0010
        dnyb %0010
        dnyb %0100
        dnyb %0100
        dnyb %0000
; 0x30	0x0030	# DIGIT ZERO
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x31	0x0031	# DIGIT ONE
        dnyb %0000
        dnyb %0010
        dnyb %0110
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0111
        dnyb %0000
; 0x32	0x0032	# DIGIT TWO
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0001
        dnyb %0010
        dnyb %0100
        dnyb %0111
        dnyb %0000
; 0x33	0x0033	# DIGIT THREE
        dnyb %0000
        dnyb %0110
        dnyb %0001
        dnyb %0010
        dnyb %0001
        dnyb %0001
        dnyb %0110
        dnyb %0000
; 0x34	0x0034	# DIGIT FOUR
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0111
        dnyb %0001
        dnyb %0001
        dnyb %0000
; 0x35	0x0035	# DIGIT FIVE
        dnyb %0000
        dnyb %0111
        dnyb %0100
        dnyb %0010
        dnyb %0001
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x36	0x0036	# DIGIT SIX
        dnyb %0000
        dnyb %0011
        dnyb %0100
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x37	0x0037	# DIGIT SEVEN
        dnyb %0000
        dnyb %0111
        dnyb %0101
        dnyb %0001
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0000
; 0x38	0x0038	# DIGIT EIGHT
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0010
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x39	0x0039	# DIGIT NINE
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0101
        dnyb %0011
        dnyb %0001
        dnyb %0110
        dnyb %0000
; 0x3A	0x003A	# COLON
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0000
        dnyb %0010
        dnyb %0000
        dnyb %0000
; 0x3B	0x003B	# SEMICOLON
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0000
        dnyb %0010
        dnyb %0100
        dnyb %0000
; 0x3C	0x003C	# LESS-THAN SIGN
        dnyb %0000
        dnyb %0001
        dnyb %0010
        dnyb %0100
        dnyb %0100
        dnyb %0010
        dnyb %0001
        dnyb %0000
; 0x3D	0x003D	# EQUALS SIGN
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0111
        dnyb %0000
        dnyb %0111
        dnyb %0000
        dnyb %0000
; 0x3E	0x003E	# GREATER-THAN SIGN
        dnyb %0000
        dnyb %0100
        dnyb %0010
        dnyb %0001
        dnyb %0001
        dnyb %0010
        dnyb %0100
        dnyb %0000
; 0x3F	0x003F	# QUESTION MARK
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0001
        dnyb %0010
        dnyb %0000
        dnyb %0010
        dnyb %0000
; 0x40	0x2500	# BOX DRAWINGS LIGHT HORIZONTAL
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1111
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x41	0x0041	# LATIN CAPITAL LETTER A
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0111
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x42	0x0042	# LATIN CAPITAL LETTER B
        dnyb %0000
        dnyb %0110
        dnyb %0101
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0110
        dnyb %0000
; 0x43	0x0043	# LATIN CAPITAL LETTER C
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0100
        dnyb %0100
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x44	0x0044	# LATIN CAPITAL LETTER D
        dnyb %0000
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0110
        dnyb %0000
; 0x45	0x0045	# LATIN CAPITAL LETTER E
        dnyb %0000
        dnyb %0111
        dnyb %0100
        dnyb %0111
        dnyb %0100
        dnyb %0100
        dnyb %0111
        dnyb %0000
; 0x46	0x0046	# LATIN CAPITAL LETTER F
        dnyb %0000
        dnyb %0111
        dnyb %0100
        dnyb %0110
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0000
; 0x47	0x0047	# LATIN CAPITAL LETTER G
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0100
        dnyb %0111
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x48	0x0048	# LATIN CAPITAL LETTER H
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0111
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x49	0x0049	# LATIN CAPITAL LETTER I
        dnyb %0000
        dnyb %0111
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0111
        dnyb %0000
; 0x4A	0x004A	# LATIN CAPITAL LETTER J
        dnyb %0000
        dnyb %0111
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x4B	0x004B	# LATIN CAPITAL LETTER K
        dnyb %0000
        dnyb %0100
        dnyb %0101
        dnyb %0110
        dnyb %0100
        dnyb %0110
        dnyb %0101
        dnyb %0000
; 0x4C	0x004C	# LATIN CAPITAL LETTER L
        dnyb %0000
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0100
        dnyb %0111
        dnyb %0000
; 0x4D	0x004D	# LATIN CAPITAL LETTER M
        dnyb %0000
        dnyb %0101
        dnyb %0111
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x4E	0x004E	# LATIN CAPITAL LETTER N
        dnyb %0000
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x4F	0x004F	# LATIN CAPITAL LETTER O
        dnyb %0000
        dnyb %0111
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0111
        dnyb %0000
; 0x50	0x0050	# LATIN CAPITAL LETTER P
        dnyb %0000
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0110
        dnyb %0100
        dnyb %0100
        dnyb %0000
; 0x51	0x0051	# LATIN CAPITAL LETTER Q
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0001
        dnyb %0000
; 0x52	0x0052	# LATIN CAPITAL LETTER R
        dnyb %0000
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0110
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x53	0x0053	# LATIN CAPITAL LETTER S
        dnyb %0000
        dnyb %0011
        dnyb %0100
        dnyb %0010
        dnyb %0001
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x54	0x0054	# LATIN CAPITAL LETTER T
        dnyb %0000
        dnyb %0111
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0000
; 0x55	0x0055	# LATIN CAPITAL LETTER U
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0111
        dnyb %0000
; 0x56	0x0056	# LATIN CAPITAL LETTER V
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0000
; 0x57	0x0057	# LATIN CAPITAL LETTER W
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0111
        dnyb %0101
        dnyb %0000
; 0x58	0x0058	# LATIN CAPITAL LETTER X
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0010
        dnyb %0101
        dnyb %0101
        dnyb %0000
; 0x59	0x0059	# LATIN CAPITAL LETTER Y
        dnyb %0000
        dnyb %0101
        dnyb %0101
        dnyb %0101
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0000
; 0x5A	0x005A	# LATIN CAPITAL LETTER Z
        dnyb %0000
        dnyb %0111
        dnyb %0001
        dnyb %0010
        dnyb %0010
        dnyb %0100
        dnyb %0111
        dnyb %0000
; 0x5B	0x253C	# BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %1111
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x5C	0x1FB8C	# LEFT HALF MEDIUM SHADE
        dnyb %1000
        dnyb %0100
        dnyb %1000
        dnyb %0100
        dnyb %1000
        dnyb %0100
        dnyb %1000
        dnyb %0100
; 0x5D	0x2502	# BOX DRAWINGS LIGHT VERTICAL
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x5E	0x1FB96	# INVERSE CHECKER BOARD FILL
        dnyb %0101
        dnyb %1010
        dnyb %0101
        dnyb %1010
        dnyb %0101
        dnyb %1010
        dnyb %0101
        dnyb %1010
; 0x5F	0x1FB98	# UPPER LEFT TO LOWER RIGHT FILL
        dnyb %0011
        dnyb %1001
        dnyb %1100
        dnyb %0110
        dnyb %0011
        dnyb %1001
        dnyb %1100
        dnyb %0110
; 0x60	0x00A0	# NO-BREAK SPACE
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x61	0x258C	# LEFT HALF BLOCK
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
; 0x62	0x2584	# LOWER HALF BLOCK
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1111
        dnyb %1111
        dnyb %1111
        dnyb %1111
; 0x63	0x2594	# UPPER ONE EIGHTH BLOCK
        dnyb %1111
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x64	0x2581	# LOWER ONE EIGHTH BLOCK
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1111
; 0x65	0x258F	# LEFT ONE EIGHTH BLOCK
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
; 0x66	0x2592	# MEDIUM SHADE
        dnyb %1010
        dnyb %0101
        dnyb %1010
        dnyb %0101
        dnyb %1010
        dnyb %0101
        dnyb %1010
        dnyb %0101
; 0x67	0x2595	# RIGHT ONE EIGHTH BLOCK
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
; 0x68	0x1FB8F	# LOWER HALF MEDIUM SHADE
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1010
        dnyb %0101
        dnyb %1010
        dnyb %0101
; 0x69	0x1FB99	# UPPER RIGHT TO LOWER LEFT FILL
        dnyb %1100
        dnyb %1001
        dnyb %0011
        dnyb %0110
        dnyb %1100
        dnyb %1001
        dnyb %0011
        dnyb %0110
; 0x6A	0x1FB87	# RIGHT ONE QUARTER BLOCK
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
        dnyb %0001
; 0x6B	0x251C	# BOX DRAWINGS LIGHT VERTICAL AND RIGHT
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0011
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x6C	0x2597	# QUADRANT LOWER RIGHT
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0011
; 0x6D	0x2514	# BOX DRAWINGS LIGHT UP AND RIGHT
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0011
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x6E	0x2510	# BOX DRAWINGS LIGHT DOWN AND LEFT
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1110
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x6F	0x2582	# LOWER ONE QUARTER BLOCK
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1111
        dnyb %1111
; 0x70	0x250C	# BOX DRAWINGS LIGHT DOWN AND RIGHT
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0011
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x71	0x2534	# BOX DRAWINGS LIGHT UP AND HORIZONTAL
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %1111
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x72	0x252C	# BOX DRAWINGS LIGHT DOWN AND HORIZONTAL
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1111
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x73	0x2524	# BOX DRAWINGS LIGHT VERTICAL AND LEFT
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %1110
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x74	0x258E	# LEFT ONE QUARTER BLOCK
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
        dnyb %1000
; 0x75	0x258D	# LEFT THREE EIGHTHS BLOCK
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
; 0x76	0x1FB88	# RIGHT THREE EIGHTHS BLOCK
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0011
; 0x77	0x1FB82	# UPPER ONE QUARTER BLOCK
        dnyb %1111
        dnyb %1111
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x78	0x1FB83	# UPPER THREE EIGHTHS BLOCK
        dnyb %1111
        dnyb %1111
        dnyb %1111
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x79	0x2583	# LOWER THREE EIGHTHS BLOCK
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1111
        dnyb %1111
        dnyb %1111
; 0x7A	0x2713	# CHECK MARK
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0001
        dnyb %1010
        dnyb %0100
        dnyb %0000
; 0x7B	0x2596	# QUADRANT LOWER LEFT
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
; 0x7C	0x259D	# QUADRANT UPPER RIGHT
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x7D	0x2518	# BOX DRAWINGS LIGHT UP AND LEFT
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %1110
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x7E	0x2598	# QUADRANT UPPER LEFT
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x7F	0x259A	# QUADRANT UPPER LEFT AND LOWER RIGHT
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %1100
        dnyb %0011
        dnyb %0011
        dnyb %0011
        dnyb %0011

.segment "CODE"	 ; not purgeable

; These characters will be patched into the character set above, so it
; becomes ASCII-compliant (after PETSCII/ASCII/screencode conversion).
charset_ascii_patches:
; 1C: \
        dnyb %0000
        dnyb %0001
        dnyb %0001
        dnyb %0010
        dnyb %0010
        dnyb %0100
        dnyb %0100
        dnyb %0000
; 1E: ^
        dnyb %0000
        dnyb %0010
        dnyb %0101
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 1F: _
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1111
; 40: `
        dnyb %0000
        dnyb %0100
        dnyb %0010
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 5B: {
        dnyb %0001
        dnyb %0010
        dnyb %0010
        dnyb %0100
        dnyb %0010
        dnyb %0010
        dnyb %0001
        dnyb %0000
; 5C: |
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 5D: }
        dnyb %0100
        dnyb %0010
        dnyb %0010
        dnyb %0001
        dnyb %0010
        dnyb %0010
        dnyb %0100
        dnyb %0000
; 5E: ~
        dnyb %0000
        dnyb %0101
        dnyb %1010
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 5F:
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000

; These characters undo the ASCII patch above to make it PETSCII again.
charset_petscii_patches:
; 0x1C	0x00A3	# POUND SIGN
        dnyb %0000
        dnyb %0011
        dnyb %0010
        dnyb %0111
        dnyb %0010
        dnyb %0010
        dnyb %0111
        dnyb %0000
; 0x1E	0x2191	# UPWARDS ARROW
        dnyb %0000
        dnyb %0010
        dnyb %0111
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0000
; 0x1F	0x2190	# LEFTWARDS ARROW
        dnyb %0000
        dnyb %0000
        dnyb %0010
        dnyb %0100
        dnyb %0111
        dnyb %0100
        dnyb %0010
        dnyb %0000
; 0x40	0x2500	# BOX DRAWINGS LIGHT HORIZONTAL
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %0000
        dnyb %1111
        dnyb %0000
        dnyb %0000
        dnyb %0000
; 0x5B	0x253C	# BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %1111
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x5C	0x1FB8C	# LEFT HALF MEDIUM SHADE
        dnyb %1000
        dnyb %0100
        dnyb %1000
        dnyb %0100
        dnyb %1000
        dnyb %0100
        dnyb %1000
        dnyb %0100
; 0x5D	0x2502	# BOX DRAWINGS LIGHT VERTICAL
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
        dnyb %0010
; 0x5E	0x1FB96	# INVERSE CHECKER BOARD FILL
        dnyb %0101
        dnyb %1010
        dnyb %0101
        dnyb %1010
        dnyb %0101
        dnyb %1010
        dnyb %0101
        dnyb %1010
; 0x5F	0x1FB98	# UPPER LEFT TO LOWER RIGHT FILL
        dnyb %0011
        dnyb %1001
        dnyb %1100
        dnyb %0110
        dnyb %0011
        dnyb %1001
        dnyb %1100
        dnyb %0110
