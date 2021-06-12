OUTPUT_FORMAT("elf32-bigmips")
OUTPUT_ARCH(mips)
ENTRY(__start)
 SEARCH_DIR(.);
/* Do we need any of these for elf?
   __DYNAMIC = 0;    */
SECTIONS
{
  /* Read-only sections, merged into text segment: */
  . = 0x1000;
  .init          : { *(.init)	} =0
  .reset     : { *(.reset) }
  .excep     : { *(.excep) }
  .text      :
  {
    _ftext = . ;
    *(.text)
    *(.stub)
    /* .gnu.warning sections are handled specially by elf32.em.  */
    *(.gnu.warning)
    *(.gnu.linkonce.t*)
    *(.mips16.fn.*)
    *(.mips16.call.*)
  } =0
  _etext = .;
  PROVIDE (etext = .);
  .fini      : { *(.fini)    } =0
  .rodata    : { _frdata = . ; *(.rodata) *(.gnu.linkonce.r*) }
  .rodata1   : { *(.rodata1) }
  _erdata = .;
  PROVIDE (erdata = .);
  .data    :
  {
    _fdata = . ;
    *(.data)
    *(.gnu.linkonce.d*)
    CONSTRUCTORS
  }
  .data1   : { *(.data1) }
  .ctors         : { *(.ctors)   }
  .dtors         : { *(.dtors)   }
  _gp = ALIGN(16) + 0x7ff0;
  .got           :
  {
    *(.got.plt) *(.got)
   }
  /* We want the small data sections together, so single-instruction offsets
     can access them all, and initialized data all before uninitialized, so
     we can shorten the on-disk segment size.  */
  .sdata     : { *(.sdata) }
  .lit8 : { *(.lit8) }
  .lit4 : { *(.lit4) }
  _edata  =  .;
  PROVIDE (edata = .);
  __bss_start = .;
  _fbss = .;
  .sbss      : { *(.sbss) *(.scommon) }
  .bss       :
  {
   *(.dynbss)
   *(.bss)
   *(COMMON)
  }
  _end = . ;
  PROVIDE (end = .);
  .reginfo       : { *(.reginfo) }
  /* These are needed for ELF backends which have not yet been
     converted to the new style linker.  */
  .stab 0 : { *(.stab) }
  .stabstr 0 : { *(.stabstr) }
  /* These must appear regardless of  .  */
  .gptab.sdata : { *(.gptab.data) *(.gptab.sdata) }
  .gptab.sbss : { *(.gptab.bss) *(.gptab.sbss) }
}
