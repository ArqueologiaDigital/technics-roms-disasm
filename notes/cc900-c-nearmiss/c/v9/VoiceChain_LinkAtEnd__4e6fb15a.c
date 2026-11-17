/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void Part_WriteWordBlock_OffsetAF(unsigned int);
void VoiceChain_LinkAtEnd(unsigned int n)
{
  unsigned int h = SEQ_FREE_LIST_HEAD;
  if (h == 0) PartCtrl_WriteWord(n, 0xffff);
  else { PartCtrl_WriteWord_Off1(h, n); PartCtrl_WriteWord(n, h); }
  PartCtrl_WriteWord_Off1(n, 0);
  Part_WriteWordBlock_OffsetAF(n);
}
