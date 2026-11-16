/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m236.c (2026-11-16-68-p6-r12)
   sha256 10a1cbe7c0ae694c34e234c103998dd69024a1909d7eb7c7d788affb834ac770 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void Part_SetClearVoiceBit7(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern unsigned char __near ram_266a;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
int SeqPart_AllocNewEntry(unsigned char a)
{
  unsigned int b = Part_ProcessAndDecrementVoice();
  if (b == 0xffff) return -1;
  SEQ_TRACK_ASSIGN[(unsigned char)(ram_266a - 1)] = a;
  Part_SetClearVoiceBit7(0, ram_266a, 1);
  Part_WriteVoiceWord(0, ram_266a, b);
  SEQOP_PRIMARY_BLOCK = b;
  SEQOP_PRIMARY_OFFSET = 5;
  PartCtrl_WriteWord_Off1(b, 0);
  PartCtrl_WriteWord(b, 0xffff);
  return 0;
}
