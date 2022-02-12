; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Text encoding macros
;

.ifdef BIN_2021
; just swaps uppercase and lowercase
.macro SET_PETSCII
	.repeat 26, i
		.charmap i+$41, i+$61
	.endrepeat
	.repeat 26, i
		.charmap i+$61, i+$41
	.endrepeat
.endmacro
.else
; correct mapping for [A-Za-z]; no other mappings (unlike ca65 -t c64)
.macro SET_PETSCII
	.repeat 26, i
		.charmap i+$41, i+$c1
	.endrepeat
	.repeat 26, i
		.charmap i+$61, i+$41
	.endrepeat
.endmacro
.endif

; 1:1 mapping
.macro SET_ASCII
	.repeat $100, i
		.charmap i, i
	.endrepeat
.endmacro
