/** 
 * CONVERSION:
 * 1 KByte = 1024 Bytes = 0x400
 * 1 Mbit = 128 KBytes = 128000 Bytes = 0x1F400
 * 4 Mbit = 512 KBytes = 512000 Bytes = 0x7D000
 * 1 Mbyte = 1024 KBytes = 1048576 Bytes = 0x100000
 * 2 Mbytes = 2048 KBytes = 2097152 Bytes = 0x200000
 * 4 Mbytes = 4096 KBytes = 4194304 Bytes = 0x400000
 * 8 Mbytes = 8192 KBytes = 8388608 Bytes = 0x800000
 * 16 Mbytes = 16384 KBytes = 16777216 Bytes = 0x1000000
 */
__ERAM_ORIGIN = 0x70000000;
/* __ERAM1_LENGTH  = DEFINED(__ERAM1_LENGTH) ? __ERAM1_LENGTH  : 8192K; */
__ERAM_LENGTH  = DEFINED(__ERAM_LENGTH) ? __ERAM_LENGTH  : 16384K; /* Default to 16MBytes for Teensy PSRAM backwards compatibility */
__ERAM2_ORIGIN = DEFINED(__ERAM2_ORIGIN) ? __ERAM2_ORIGIN : __ERAM_ORIGIN + LENGTH(ERAM) + 1;
__ERAM2_LENGTH = DEFINED(__ERAM2_LENGTH) ? __ERAM2_LENGTH : 0; /* Default to 0 Bytes */

MEMORY
{
	ITCM (rwx):  ORIGIN = 0x00000000, LENGTH = 512K
	DTCM (rwx):  ORIGIN = 0x20000000, LENGTH = 512K
	RAM (rwx):   ORIGIN = 0x20200000, LENGTH = 512K
	FLASH (rwx): ORIGIN = 0x60000000, LENGTH = 7936K
	ERAM (rwx):  ORIGIN = __ERAM_ORIGIN, LENGTH = __ERAM_LENGTH
	/* ERAM1 (rwx):  ORIGIN = __ERAM_ORIGIN, LENGTH = __ERAM1_LENGTH */
	ERAM2 (rwx):  ORIGIN = __ERAM2_ORIGIN, LENGTH = __ERAM2_LENGTH
}

ENTRY(ImageVectorTable)

SECTIONS
{
	.text.headers : {
		KEEP(*(.flashconfig))
		FILL(0xFF)
		. = ORIGIN(FLASH) + 0x1000;
		KEEP(*(.ivt))
		KEEP(*(.bootdata))
		. = ALIGN(1024);
	} > FLASH

	.text.code : {
		KEEP(*(.startup))
		*(.flashmem*)
		. = ALIGN(4);
		KEEP(*(.init))
		__preinit_array_start = .;
		KEEP (*(.preinit_array))
		__preinit_array_end = .;
		__init_array_start = .;
		KEEP (*(.init_array))
		__init_array_end = .;
		. = ALIGN(4);
	} > FLASH

	.text.progmem : {
		*(.progmem*)
		. = ALIGN(4);
	} > FLASH

	.text.itcm : {
		. = . + 32; /* MPU to trap NULL pointer deref */
		*(.fastrun)
		*(.text*)
		. = ALIGN(16);
	} > ITCM  AT> FLASH

	.ARM.exidx : {
		__exidx_start = .;
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
		__exidx_end = .;
	} > ITCM  AT> FLASH

	.data : {
		*(.rodata*)
		*(.data*)
	} > DTCM  AT> FLASH

	.bss ALIGN(4) : {
		*(.bss*)
		*(COMMON)
		. = ALIGN(32);
		. = . + 32; /* MPU to trap stack overflow */
	} > DTCM

	.bss.dma (NOLOAD) : {
		*(.hab_log)
		*(.dmabuffers)
		. = ALIGN(32);
	} > RAM

	.bss.extram (NOLOAD) : {
		*(.externalram)
		. = ALIGN(32);
	} > ERAM

	/* .bss.extram1 (NOLOAD) : {
		*(.externalram1)
		. = ALIGN(32);
	} > ERAM1 */

	.bss.extram2 (NOLOAD) : {
		*(.externalram2)
		. = ALIGN(32);
	} > ERAM2

	.text.csf : {
		FILL(0xFF)
		. = ALIGN(1024);
		KEEP(*(.csf))
		__text_csf_end = .;
	} > FLASH

	_stext = ADDR(.text.itcm);
	_etext = ADDR(.text.itcm) + SIZEOF(.text.itcm) + SIZEOF(.ARM.exidx);
	_stextload = LOADADDR(.text.itcm);

	_sdata = ADDR(.data);
	_edata = ADDR(.data) + SIZEOF(.data);
	_sdataload = LOADADDR(.data);

	_sbss = ADDR(.bss);
	_ebss = ADDR(.bss) + SIZEOF(.bss);

	_heap_start = ADDR(.bss.dma) + SIZEOF(.bss.dma);
	_heap_end = ORIGIN(RAM) + LENGTH(RAM);

	_extram_start = ADDR(.bss.extram);
	_extram_end = ADDR(.bss.extram) + SIZEOF(.bss.extram);

	_itcm_block_count = (SIZEOF(.text.itcm) + SIZEOF(.ARM.exidx) + 0x7FFF) >> 15;
	_flexram_bank_config = 0xAAAAAAAA | ((1 << (_itcm_block_count * 2)) - 1);
	_estack = ORIGIN(DTCM) + ((16 - _itcm_block_count) << 15);

	_flashimagelen = __text_csf_end - ORIGIN(FLASH);
	_teensy_model_identifier = 0x25;

	.debug_info     0 : { *(.debug_info) }
	.debug_abbrev   0 : { *(.debug_abbrev) }
	.debug_line     0 : { *(.debug_line) }
	.debug_frame    0 : { *(.debug_frame) }
	.debug_str      0 : { *(.debug_str) }
	.debug_loc      0 : { *(.debug_loc) }

}
