/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
unsigned int PartCtrl_CheckOwnerAndToggle(unsigned int n, unsigned int o, unsigned int m)
{
  unsigned int r = 0;
  if (PartCtrl_ReadWord_Off1(n) != o) r |= 0x10;
  else if (m == 0 && PartCtrl_TestBit7(n) != 0) { PartCtrl_SetClearBit7(n, 0); r |= 0x02; }
  else if (m == 1 && PartCtrl_TestBit7(n) == 0) { PartCtrl_SetClearBit7(n, 1); r |= 0x04; }
  return r;
}
