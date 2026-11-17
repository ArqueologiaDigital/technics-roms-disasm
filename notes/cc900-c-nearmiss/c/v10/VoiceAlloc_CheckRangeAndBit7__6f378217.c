/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char PartCtrl_TestBit7(unsigned int);
int VoiceAlloc_CheckRangeAndBit7(unsigned int n)
{
  if (n > 0x4d8 || n == 0 || PartCtrl_TestBit7(n) == 0) return -1;
  return 0;
}
