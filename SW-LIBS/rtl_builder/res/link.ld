OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x0000000000000200;
  .text.init : { *(.text.init) }
  .text : { *(.text) }
  .data ALIGN(0x0400) : { *(.data) }
  .bss : { *(.bss) }
  .statuses : { *(.statuses) }
  _end = .;
}
