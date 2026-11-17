/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -Xr */
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
void Part_ClearVoiceSlot(unsigned char a, unsigned char c)
{
  Part_WriteWord_Indexed(a, c, 0xffff);
  Part_WriteByte_Indexed(a, c, 5);
  Part_SetClearVoiceBit7(a, c, 0);
  Part_WriteVoiceWord(a, c, 0xffff);
  if (a == 0) Chan_SetActiveBit(c, 0);
}
