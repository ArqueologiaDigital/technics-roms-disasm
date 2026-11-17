/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char PartCtrl_TestBit7(unsigned int);
int VoiceAlloc_CheckRangeAndBit7(unsigned int n)
{
  if (n > 0x4d8 || n == 0 || PartCtrl_TestBit7(n) == 0) return -1;
  return 0;
}
