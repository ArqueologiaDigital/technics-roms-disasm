/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4a.c (2026-11-16-40-p6-r8)
   sha256 51f33f7d2a542dcabaa0b35f2dc5bf07089f5d28b53e49e44f8cfe457d787e3c (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char SeqData_ReadNextByte(void);
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned char __near ram_2586;
extern unsigned char __near ram_2587[];
extern unsigned char __near ram_28a6;
extern unsigned char __near ram_437;
extern unsigned char __near ram_436;
int SeqData_ReadParamBlock(void)
{
  unsigned int n = 0;
  unsigned char c;
  c = SeqData_ReadNextByte();
  ram_2586 = c;
  if (c == 0x82 || c == 0x84) return 0;
  for (;;) {
    PartCtrl_RefreshWordPeriodic();
    c = SeqData_ReadNextByte();
    if (c & 0x80) break;
    if (n >= 5) continue;
    ram_2587[n] = c;
    n++;
    if (n >= 7) { ram_28a6 &= ~0x01; ram_437 = 0; ram_436 = 0; break; }
  }
  return n;
}
