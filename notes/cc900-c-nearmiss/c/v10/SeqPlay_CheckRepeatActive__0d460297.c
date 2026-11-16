/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1a.c (2026-11-16-30-p6-r1)
   sha256 0d4602979081b19630e392a553f4b00a47f318a801919b0bcf1285f383535a70 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near ram_232a;
extern unsigned int __near ram_232c;
unsigned char SeqPlay_CheckRepeatActive(void)
{
  unsigned char r = 0, m;
  unsigned int b, w;
  if (CURRENT_TITLE == 0x87 || CURRENT_TITLE == 0x88) return r;
  b = ram_232c; w = ram_232a; m = CURRENT_MODE;
  if (m == 0x0b) {
    if (!(SEQ_CYCLE_FLAGS & 0x02)) return r;
    if (b <= w) r = 1;
  } else {
    if (m == 0x13) return r;
    if (!(SEQ_CYCLE_FLAGS & 0x01)) return r;
    if (b <= w) r = 1;
  }
  return r;
}
