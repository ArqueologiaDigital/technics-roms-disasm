/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine.c (2026-11-16-36-p6-staged-r4)
   sha256 89407f0c2d25bb39cbeb834be9f9a659e995f5e65ab955bf65c63980fa1ea092 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near CURRENT_MODE;
extern unsigned int __near ram_232a;
extern unsigned int __near ram_232c;
unsigned char SeqPlay_CheckRepeatActive(void)
{
  unsigned char r = 0, m;
  unsigned int b, w;
  if (CURRENT_TITLE != 0x87 && CURRENT_TITLE != 0x88) {
    b = ram_232c; w = ram_232a; m = CURRENT_MODE;
    if (m == 0x0b) { if (SEQ_CYCLE_FLAGS & 0x02) { if (b <= w) r = 1; } }
    else if (m != 0x13) { if (SEQ_CYCLE_FLAGS & 0x01) { if (b <= w) r = 1; } }
  }
  return r;
}
