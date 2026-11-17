/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4b.c (2026-11-16-40-p6-r8)
   sha256 0376a2964c573ce15297eb22e016ddee3a48777d9bcdc1cb9292bc07c50265c4 (tar-sha256); compiled at -O3 -XS -Xr */
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
  do {
    PartCtrl_RefreshWordPeriodic();
    c = SeqData_ReadNextByte();
    if (c & 0x80) break;
    if (n < 5) {
      ram_2587[n] = c;
      n++;
      if (n >= 7) { ram_28a6 &= ~0x01; ram_437 = 0; ram_436 = 0; break; }
    }
  } while (1);
  return n;
}
