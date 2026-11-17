/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4b.c (2026-11-16-40-p6-r8)
   sha256 0376a2964c573ce15297eb22e016ddee3a48777d9bcdc1cb9292bc07c50265c4 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void Part_WriteWordBlock_OffsetAF(unsigned int);
void VoiceChain_LinkAtEnd(unsigned int n)
{
  unsigned int h = SEQ_FREE_LIST_HEAD, v;
  if (h == 0) v = 0xffff;
  else { PartCtrl_WriteWord_Off1(h, n); v = h; }
  PartCtrl_WriteWord(n, v);
  PartCtrl_WriteWord_Off1(n, 0);
  Part_WriteWordBlock_OffsetAF(n);
}
