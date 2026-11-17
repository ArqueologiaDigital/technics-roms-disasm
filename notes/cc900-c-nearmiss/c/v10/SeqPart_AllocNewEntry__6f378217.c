/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -Xr */
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern unsigned char __near ram_2684;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
int SeqPart_AllocNewEntry(unsigned char a)
{
  unsigned int b = Part_ProcessAndDecrementVoice();
  if (b == 0xffff) return -1;
  SEQ_TRACK_ASSIGN[(unsigned char)(ram_2684 - 1)] = a;
  Part_SetClearVoiceBit7(0, ram_2684, 1);
  Part_WriteVoiceWord(0, ram_2684, b);
  SEQOP_PRIMARY_BLOCK = b;
  SEQOP_PRIMARY_OFFSET = 5;
  PartCtrl_WriteWord_Off1(b, 0);
  PartCtrl_WriteWord(b, 0xffff);
  return 0;
}
