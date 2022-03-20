# CCGMS Future Documentation

## Terminal Mode

| Shortcut                | Description                      |
|-------------------------|----------------------------------|
| `F1`                    | [Upload file](#upload-file)      |
| `F2`                    | [Send/Read file](#sendread-file) |
| `F3`                    | [Download file](#download-file)  |
| `F4`                    | [Buffer commands](#buffer-commands) |
| `F5`                    | [Disk command](#disk-command)    |
| `F6`                    | [Directory](#directory)          |
| `F7`                    | [Settings/Dialer](#settingsdialer) |
| `F8`                    | [Cycle terminal mode](#cycle-terminal-mode) |
| `C=` `F1`               | [Multi-Upload](#multi-upload)|
| `C=` `F3`               | [Multi-Download](#multi-download)|
| `C=` `F5`               | [Send directory](#send-directory)|
| `C=` `F7`               | [Screen to buffer](#screen-to-buffer)|
| `CTRL` `F1`/`F3`        | [Send Macro Text](#macros)                |
| `CTRL` `F5`/`F7`        | [Send User ID/Password](#send-user-idpassword)|
| `C=` `CTRL` [`1`-`4`]   | [Take screen snapshot](#screen-snapshot)|
| `SHFT` `CTRL` [`1`-`4`] | [Recall screen snapshot](#screen-snapshot)|
| `C=` `STOP`             | [Disconnect](#disconnect)        |

## Upload File

`F1` will upload a single file from current drive to the BBS. It will ask for the source filename.

## Send/Read File

`F2` will ask whether you want to send (`S`) or read (`R`) a file.

* "Send" reads a file from the current drive and sends it to the BBS, byte by byte, as if it has been typed in. This is meant for text-only data, and does not do any error detection/correction.
* "Read" reads a file from the current drive and prints it to the screen. No data is sent to the BBS.

## Download File

`F3` will download a single file from the BBS to the current drive. First, it will ask for the destination filename.  If the [protocol](#protocol) is XMODEM, it will also ask what file type the new file should be: PRG, SEQ or USR.

## Buffer Commands

`F4` will show the buffer menu with following options:

        Open  Close  Erase  Transfer
        Load  Save   Print  View

* **Open**: Open the buffer. If the buffer is open, all text received from the BBS in terminal mode will be appended to the buffer.
* **Close**: Close the buffer. This stops appending text to the buffer.
* **Erase**: Erase the buffer. This clears the buffer.
* **Load**: This loads an SEQ file from the current drive into the buffer.
* **Save**: This saves the buffer into an SEQ file on the current drive.
* **Print**: This sends the buffer to the printer. It will ask for the device number and the secondary address. By convention, secondary address 0 will pick the upper/graphics character set, and 7 will pick the upper/lower character set.
* **View**: This prints the buffer contents to the screen. During printing, STOP cancels, and any other key pauses/unpauses.

In addition, `<` and `>` will move the buffer pointer.

The RETURN key will exit the buffer menu.

## Disk Command

`F5` allows sending a command to the current drive, like `S:FOO,S` or `CD/FOO`/`CD:←` (sd2iec).

* `#8`, `#9` etc. changes the current drive globally.
* An empty command will print the drive status.

## Directory

`F6` will show the directory of the current drive. STOP cancels, and any other key pauses/unpauses.

## Settings/Dialer

`F7` will show the following menu:

        Auto-Dialer/Phonebook
        Baud Rate   - 2400
        Duplex      - Full
        Modem Type  - User Port 300-2400
        Firmware    - Standard
        Protocol    - XMODEM
        Theme       - Classic CCGMS v5.5
        Edit Macros
        Load/Save Phone Book and Config.
        View Instructions

The first character of each option will invoke it.

### Auto-Dialer/Phonebook

CCGMS can auto-dial phonebook entries. It will send the `ATDT` command and parse the status returned by the modem (e.g. `CONNECT` or `NO ANSWER`). After connecting to the BBS, the key combinations Ctrl+F5 and Ctrl+F7 will send the username and password of the current phonebook entry.

The phonebook has 30 entries, consisting of

* **name**: name in the phone book
* **ip**: DNS name or IP address
* **port**: IP port
* **id**: username
* **pw**: password

Use the cursor keys to navigate the entries. SPACE or RETURN selects/deselects an entry, which allows any subset of the entries to be selected.

#### Dial Unlisted # (`D`)

This allows connecting to a BBS that is not listed in the phonebook. CCGMS will ask for the DNS name or IP and the port.

#### Edit Current # (`E`)

This allows editing the currently highlighted entry.

#### Call Current # (`C`)

This dials the currently highlighted entry.

#### Dial Selected (`A`)

This dials the currently selected entries, one by one, until one answers.

#### Reverse Call (`R`)

Invert the current selection of entries.

#### Return To Menu (`X`)

This will return to the settings menu.


### Baud Rate

This will cycle through the legal baud rates for the current [modem type](#modem-type).

| Driver             | 300 | 1200 | 2400 | 4800 | 9600 | 19200 | 3400 |
|--------------------|-----|------|------|------|------|-------|------|
| User Port          | ✅  |  ✅  |  ✅  | ❌  | ❌   | ❌   | ❌   |
| UP9600             | ✅  |  ✅  |  ✅  | ✅  | ✅   | ❌   | ❌   |
| SwiftLink/Turbo232 | ✅  |  ✅  |  ✅  | ✅  | ✅   | ✅   | ✅   |

### Duplex

Switches between half and full duplex.

### Modem Type

Cycles through the RS-232 drivers:

* User Port: This uses is the original Commodore RS-232 specification for modems on the user port. This can be used with classic modems like the Commodore 1670 (Modem/1200), or when connecting any TTL RS-232 device to the user port's RX and TX pins.
* The [UP9600](https://www.pagetable.com/?p=1656) driver requires an alternate wiring on the user port. It allows higher speeds, and is backwards compatible with the original user port wiring. UP9600 does not work with the C128.
* SwiftLink/Turbo232: This requires cartridge with an external 6551 ACIA, like SwiftLink, Turbo232 or GLINK232T. The cart has to be configured to use NMI (not IRQ) and to be located at either $DE00 (setting `DE`), $DF00 (`DF`) or $D700 (`D7`).

### Firmware

This configures the syntax used by the auto-dialer. The ZiModem firmware requires the address after `ATDT` in quotes, standard firmwares (WiModem, StrikeLink, ...) do not accept quotes.

### Protocol

This configures the protocol to be used for file transmissions. It cycles between Punter and three variants of XMODEM.

* Punter: This is the "NEW" Punter a.k.a. Punter C1 protocol, which is the standard on many BBSes with a Commodore background.
* XMODEM: This is a family of protocols mostly used on PC BBSes.
	* XMODEM:
		* Upload: force 128B blocks, accept checksum or CRC
		* Download: force checksum, accept 128B or 1K blocks
	* XMODEM-CRC:
		* Upload: force 128B blocks, accept checksum or CRC
		* Download: force CRC, accept 128B or 1K blocks
	* XMODEM-1K:
		* Upload: force 1K blocks, accept checksum or CRC
		* Download: force CRC, accept 128B or 1K blocks

### Theme

This cycles through several color themes in the menus.

### Edit Macros

This allows editing the two macros that can be invoked with Ctrl+F1 and Ctrl+F3.

### Load/Save Phone Book and Configuration

This allows loading or saving the configuration and the phonebook contents. The EasyFlash version saves it in the EasyFlash ROM, the regular version saves it to disk. The file on disk is compatible between CCGMS versions.

### View Instructions

Prints some additional keyboard commands as well as the license of the software.

## Cycle Terminal Mode

`F8` cycles between 80/40 columns mode and PETSCII/ASCII encoding.

### Columns

* 40 columns mode uses the VIC-II hardware text mode and the built-in character set.
* 80 columns mode uses a software library to emulate 80 characters in bitmap mode. A limitation of this mode is that every two adjacent characters have to share a foreground color. In PETSCII mode, the character set is equivalent to the C64 built-in one, and in 80 columns mode, the charset is changed to be identical to ASCII (<tt>\^_`{|}~</tt>)

### Encoding

* PETSCII (a.k.a "C/G") mode uses the Commodore character encoding and supports all [PETSCII control characters](https://www.pagetable.com/c64ref/charset/). It adds the following control codes, which can be sent by the BBS (or typed in by the user if the BBS has remote echo):

| Keyboard            | Code | Description                          |
|---------------------|------|--------------------------------------|
| CTRL B <color-code> | $02  | Change background color              |
| CTRL N              | $0e  | Set background to black              |
| CTRL G              | $07  | Bell sound                           |
| CTRL V              | $17  | Gong sound                           |
| CTRL J              | $0a  | Cursor on                            |
| CTRL K              | $0b  | Cursor off                           |

* ASCII mode uses the standard-ASCII character encoding and supports *some* ANSI control sequences.

## Multi-Upload

`C=` `F1` uploads one or more file using the Multi-Punter procotol. It will print the directory of the current drive entry by entry and ask for one of the following:

* **Yes**: Upload this file.
* **No**: Do not upload this file.
* **Quit**: Stop uploading.
* **Skip8**: Do not upload the next 8 files.
* **Done**: Stop uploading.
* **All**: Upload all files from here on.

Multi-Punter will also send the name and type of each file.

## Multi-Download

`C=` `F3`  downloads one or more files. For each file, the BBS will send the name, type and file contents, and CCGMS will write the data to the current drive.

## Send directory

`C=` `F5` will read the current drive's directory listing and send it to the BBS.

## Screen to buffer

`C=` `F7` will convert the contents of the screen to a (minimal) sequence of PETSCII characters and codes and store it in the buffer.

If the `SHIFT` key is pressed in addition, the contents of the buffer will be cleared first.

> Note that in 80 columns mode, every two adjacent characters share a foreground color, so having the BBS show PETSCII graphics in 80 columns mode and saving the screen contents is lossy. For this use case, open the buffer before having the graphics printed instead.

## Screen Snapshots

* `C=` `CTRL` and the keys `1`-`4` will copy the current screen contents into one of the four buffers.
* `SHFT` `CTRL` and `1`-`4` will swap the current screen with one of the four buffers.

Note that this feature is disabled in 80 columns mode, and switching into 80 columns mode will clear all four buffers.

## Macros

`CTRL` `F1` and `CTRL` `F3` will send the contents of one of the two macros.

## Send User ID/Password

`CTRL` `F5` will send the username and `CTRL` `F7` the password of the current phonebook entry, as if it were typed in.

## Disconnect

This will drop the DTR line, which signals the modem that it should disconnect.
