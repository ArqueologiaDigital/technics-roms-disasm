/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2a.c (2026-11-16-35-p6-r3)
   sha256 c97b2399af5c6580229970cea088ec622459e83731fa38d6c7f60b660d01c853 (tar-sha256); compiled at -Xr */
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near SEQ_CYCLE_FLAGS;
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
