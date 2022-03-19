# CCGMS Internals

Here are some details that will help with development.

## Memory Map

* Low

| Range       | Use                                      |
|-------------|------------------------------------------|
| $0380-$03FF | UP9600 byte reversal table               |
| $0400-$05FF | Punter buffers (screen RAM!)             |

* High

| Range       | Use                                      | Alt use               |
|-------------|------------------------------------------|-----------------------|
| $C800-$CAFF |                                          | XMODEM buffer         |
| $CB00-$CBFF | Multi-Punter buffer                      | XMODEM buffer (cont.) |
| $CC00-$CCFF | buffer to save return text from dialing  | CRC table lo          |
| $CD00-$CDFF | Punter temporary vars                    | CRC table hi          |
| $CE00-$CEFF | RS-232 input buffer                      |                       |
| $CF00-$CFFF | text input buffer                        |                       |

* 40 column mode:

| Range       | Use                                      |
|-------------|------------------------------------------|
| $D000-$DFFF | unused                                   |
| $E000-$FFCF | screen snapshots                         |

* 80 column mode:

| Range       | Use                                      |
|-------------|------------------------------------------|
| $D000-$D3FF | 4x8 charset                              |
| $D400-$D7E7 | 40x25 "screen memory" holding the colors |
| $D800-$DFCF | logical 80x25 screen RAM                 |
| $E000-$FE3F | bitmap                                   |

## Banking

CCGMS runs with $01 = $37. Whenever you want to turn off the KERNAL ROM, you need to store #$34 in $01. This is effectively the same as #$30, but allows the timing-critical UP9600 code to switch I/O on and off with `inc $01` and `dec $01`.