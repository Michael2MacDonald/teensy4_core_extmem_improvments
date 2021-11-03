# teensy4 core with extmem improvments

Added more EXTRAM options and compatible devices

### NOTE: THIS HAS NOT BEEN TESTED. It might not work as advertized. It might not work at all. IDK. I am planning on testing it but it might be a while.

- Added support for AS3008204, AS3004204, AS3001204 MRAM chips
- Built to be scalable easy to add more compatible chips
- Added support for using 2 ram chips seperatly using the `EXTRAM` and `EXTRAM2` keywords or 2 ram chips together by just using `EXTRAM` (They must be identical chips though but I have never tested it so maybe not)

By default it should work just like the origanal teensy core. You can install 1-2 compatible PSRAM chips and use them with `EXTMEM`. The `EXTMEM` section in memory is still 16MB long and the `EXTMEM2` section defaults to a length of 0 bytes.

With the new system the there are 2 memory sections. Section 1 is accessable using the `EXTRAM` keyword and section 2 is accessable using the `EXTRAM2` keyword.

#### 1 memory chip or 2 of the same chip in one memory section

To use one memory chip or two chips combined, set `ERAMLEN` in the makefile to the size of your memory chip or if you are using two chips then set it to the combined size of your chips. In your program set `RAM1_CONF` to `0` for teensy PSRAM chips and `1` for AS300\*204 chips. Then set `RAM1_SIZE` to the size of your chip in MB. Do the same for `RAM2_CONF` and `RAM2_SIZE` if you have a second chip. When using two chips together under one memory section the chips must be identical (same model/size). You can now access your chip(s) with the `EXTRAM` keyword.

#### 2 different memory chips or 2 of the same chips in seperate memory sections

To use two different memory chips (ex: psram a& mram) or to use two of the same memory chip (ex: 2 psram chips) but independently, set `ERAMLEN` in the makefile to the size of your first memory chip (smaller pads on the T41) and set `ERAM2LEN` to the size of your second memory chip (larger pads on the T41). In your program set `RAM1_CONF` to `0` for teensy PSRAM chips and `1` for AS300\*204 chips. Then set `RAM1_SIZE` to the size of your chip in MB. Do the same for `RAM2_CONF` and `RAM2_SIZE` for your second chip. You can now access your first chip with the `EXTRAM` keyword and your second chip with the `EXTRAM2` keyword.

#### Arduino

If you are using the arduino IDE you can set a memory configuration in the arduino tools dropdown menu. Just select the size of the first and second memory sections like you would with `ERAMLEN` and `ERAM2LEN` in the makefile. If you are only using one memory section (one memory chip or two chips merged) then set the second section size to zero.
