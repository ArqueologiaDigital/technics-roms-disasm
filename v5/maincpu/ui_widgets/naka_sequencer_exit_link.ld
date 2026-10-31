/* naka_sequencer_exit_link.ld — Linker script for naka_sequencer_exit.c  * v7 addresses where v7's own bytes agree:
 * scripts/generators/generate_v7_naka_link_scripts.py
 */

ENTRY(0)

SECTIONS {
    .text : { *(.text*) *(.rodata*) }
    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}

/* Linked widget descriptors */
NakaDesc_FuncTtlNo_B     = 0x00E270A6;
NakaDesc_Empty_C          = 0x00E270C2;
NakaDesc_Empty_D          = 0x00E270C8;
NakaDesc_FuncIndex        = 0x00E270CE;
NakaDesc_Mode             = 0x00E270F0;
NakaDesc_ColorFontPageFunc = 0x00E27100; /* v6's address: nothing in v5 places it */ /* v7's address: nothing in v6 places it */
ClassProps_IvPnlWrExit              = 0x00E27124;
NakaDesc_Empty_E          = 0x00E27142;
NakaDesc_Empty_F          = 0x00E27148;
NakaDesc_Empty_G          = 0x00E2714E;
NakaDesc_Empty_H          = 0x00E27154;
NakaDesc_Empty_I          = 0x00E2715A;
NakaDesc_StyleFunc        = 0x00E27160;
NakaDesc_Empty_J          = 0x00E2717A;

/* Proc handler functions */
EqOnOffFuncToggleProc     = 0x00F34326;
MsgToTtlProc              = 0x00F2ED3C;
AcIndexWideToggleProc     = 0x00F2EA33;
IvPlayExitProc            = 0x00F2E8B8;
HelpTtlProc               = 0x00F2E5E6;
IvPnlWrExitProc           = 0x00F30719;
IvSdrevProc               = 0x00F2E6C0;
IvSddspProc               = 0x00F2E75F;
IvSdaccProc               = 0x00F2E81A;
IvPunchExitProc           = 0x00F2E941;
IvAutoPunchExitProc       = 0x00F2E9B6;
AcPanicEditSwProc         = 0x00F2E274;
IvRealRecExitProc         = 0x00F2E1D2;
