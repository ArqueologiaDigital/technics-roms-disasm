/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 4e6fb15a9dcef11c657d923eaf017b50a32c6776dde159610f29f481be75a22a (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
