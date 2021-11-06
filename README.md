# Improved External Ram functionality For Teensy4 Core

Expaned the configurability of the external ram and added suport for more ram chips.

### NOTE: THIS HAS NOT BEEN TESTED. It might not work as intended or at all.

I am planning on testing it but it might be a while before I get around to doing that. If anyone tests it or has sugestion/improvments then please share them with me so I can fix and improve this added functionality!

This is also a temporary repository. I plan on moving this code to a new repository when I get arround to implementing it into a library or possibly a pull request for the official Teensy core repository.

### Overview:

- Added support for AS3008204, AS3004204, AS3001204 MRAM chips
- Built to be scalable and easy to add compatiblity for more chips
- Added support for using two ram chips independently with the `EXTRAM` and `EXTRAM2` keywords or two ram chips together (just like the current teensy core) by just using `EXTRAM` (To use the chips together they must be identical chips. I have never tested it before though so maybe it will work with some hacks)

I designed the modifications to be 100% backwards compatible with the original Teensy4 core. It defaults to the Teensy PSRAM chip instructions sets and sets the `EXTMEM` section to 16MB just like the original Teensy4 core. The `EXTMEM2` section defaults to a length of 0 bytes.

### RAM Size

You have to tell the MCU the size of the RAM chips you are adding. With the old core this was hard coded to 8MB for both chips. You now have the option to change this using the `RAM1_SIZE` and `RAM2_SIZE` variables. They default to 8MB for backwards compatibility. The MCU will map an address range to each chip using the size you give it. It starts at `0x7000_0000` and maps the first chip before mapping the second chip right after the first.

```
Setting RAM Size Example.
  #define RAM1_SIZE 4 // 8MB
  #define RAM2_SIZE (128/1024) // 128KB

Address Map Example:
If you had 2 ram chips and the first one was 1 MBytes (0x100000) and the second one was 8 MBytes (0x800000) then your memory would look like this:
RAM Chip 1
  0x7000_0000 - 0x7010_0000
RAM Chip 2
  0x7010_0000 - 0x7090_0000
```

### Memory Sections

With the new system the there are 2 memory sections. Section 1 is accessable using the `EXTRAM` keyword and section 2 is accessable using the `EXTRAM2` keyword. 

**Memory Section 1:**
```
Linker Section: .externalram
Section Length Var (Linker): __ERAM_LENGTH (Note: This is a linker variable and can only be modified in the linker file or by options in the makefile. You can read it from your c/c++ program using `extern`)
Section Length Var (Makefile): `ERAMLEN` (Note: This variable simply modifies the `__ERAM2_LENGTH` variable in the linker. If this variable is not set then the linker will default to the default value specified below)
Default Length: 16M
Keyword: EXTMEM
```
**Memory Section 2:**
```
Linker Section: .externalram2
Section Length Var (Linker): __ERAM2_LENGTH (Note: This is a linker variable and can only be modified in the linker file or by options in the makefile. You can read it from your c/c++ program using `extern`)
Section Length Var (Makefile):    `ERAM2LEN` (Note: This variable simply modifies the `__ERAM2_LENGTH` variable in the linker. If this variable is not set then the linker will default to the default value specified below)
Default Length: 0
Keyword: EXTMEM2 (Note: Keywork is not defined when `__ERAM2_LENGTH` == 0)
```
To set your own keywords for the sections, just define a keyword equal to `__attribute__((section(".SECTION_NAME")))`

Ex: `#define FRAM_MEM __attribute__((section(".externalram2")))`

### Using One Memory Section

#### Using One RAM Chip

To use one RAM chip, set `ERAMLEN` in the makefile to the size of your memory chip. You can use MB or KB but you must add a `M` (MBytes) or a `K` (KBytes) after the number to spesify the unit (Ex. `8M` or `128K`). In your program set `RAM1_CONF` to the index of your first RAM chip (See [RAM Configuration](#ram-configuration)). Then set `RAM1_SIZE` to the size of your chip in MB. You can now access your chip with the `EXTRAM` keyword.

#### Using Two Of The Same Chip

To use two RAM chips combined, set `ERAMLEN` in the makefile to the combined size of your chips. You can use MB or KB but you must add a `M` (MBytes) or a `K` (KBytes) after the number to spesify the unit (Ex. `8M` or `128K`). In your program set `RAM1_CONF` to the index of your first RAM chip and `RAM2_CONF` to the index of your second RAM chip (See [RAM Configuration](#ram-configuration)). Then set `RAM1_SIZE` to the size of your chip in MB. Do the same for `RAM2_CONF` and `RAM2_SIZE` for your second chip. When using two chips together under one memory section the chips must be identical (same model/size). You can now access your chip(s) with the `EXTRAM` keyword.

### Using Both Memory Sections

#### Using Two Of The Same Chips

To use two of the same RAM chip (ex: two PSRAM chips) independently, set `ERAMLEN` in the makefile to the size of your first RAM chip (smaller pads on the T41) and set `ERAM2LEN` to the size of your second RAM chip (larger pads on the T41). You can use MB or KB but you must add a `M` (MBytes) or a `K` (KBytes) after the number to spesify the unit (Ex. `8M` or `128K`). In your program set `RAM1_CONF` to the index of your first RAM chip (See [RAM Configuration](#ram-configuration)). Then set `RAM1_SIZE` and `RAM2_SIZE` to the size of your chips in MB. You can now access your first chip with the `EXTRAM` keyword and your second chip with the `EXTRAM2` keyword.

#### Using Two Different RAM Chips

To use two different RAM chips (ex: PSRAM & MRAM) set `ERAMLEN` in the makefile to the size of your first RAM chip (smaller pads on the T41) and set `ERAM2LEN` to the size of your second RAM chip (larger pads on the T41). You can use MB or KB but you must add a `M` (MBytes) or a `K` (KBytes) after the number to spesify the unit (Ex. `8M` or `128K`). In your program set `RAM1_CONF` to the index of your first RAM chip (See [RAM Configuration](#ram-configuration)). Then set `RAM1_SIZE` to the size of your first chip in MB. Do the same for `RAM2_CONF` and `RAM2_SIZE` for your second chip. You can now access your first chip with the `EXTRAM` keyword and your second chip with the `EXTRAM2` keyword.

### Arduino

If you are using the arduino IDE you can set a memory configuration in the arduino tools dropdown menu. Just select the size of the first and second memory sections like you would with `ERAMLEN` and `ERAM2LEN` in the makefile. If you are only using one memory section (one memory chip or two chips merged) then set the second section size to zero.

### RAM Configuration

`RAM1_CONF` and `RAM2_CONF` set the type of ram chip you have. Currently these are the supported options:

**PSRAM:**

Teensy PSRAM: `0`. Find compatible chips or buy one [here](https://www.pjrc.com/store/psram.html)

**MRAM:**

AS3001204, AS3004204, AS3008204: `1`

