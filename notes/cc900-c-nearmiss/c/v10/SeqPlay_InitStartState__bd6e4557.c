/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-30-p6-r1)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near ram_2524;
extern unsigned char __near ram_1d5e;
extern unsigned char __near ram_e386;
extern unsigned int __near SEQ_START_MEASURE;
void SeqPlay_InitStartState(void)
{
  SEQ_CONTROL_FLAGS |= 0x10;
  SEQ_RTMCFG |= 0x04;
  ram_2524 = 1;
  if (SEQ_START_MEASURE != 1) { ram_1d5e = 250; SEQ_RTMCFG |= 0x08; }
  else {
    switch (CURRENT_TITLE) {
    case 0x85: case 0x86:
      if (SEQ_CYCLE_FLAGS & 0x02) ram_1d5e = 250; else ram_1d5e = 0;
      break;
    case 0x87: case 0x88:
      ram_1d5e = 0;
      break;
    default:
      if (SEQ_CYCLE_FLAGS & 0x01) ram_1d5e = 250; else ram_1d5e = 0;
    }
    SEQ_RTMCFG &= ~0x08;
  }
  ram_e386 = 1;
}
