/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m236.c (2026-11-16-68-p6-r12)
   sha256 10a1cbe7c0ae694c34e234c103998dd69024a1909d7eb7c7d788affb834ac770 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SeqVoice_InitReturnZero(void);
extern void SeqError_MapViaTableF(void);
extern unsigned char __near ram_285d;
extern unsigned char __near ram_2881;
void SeqPart_ByteBlockA95A_Code_Helper(void)
{
  SeqError_MapViaTableF();
  SeqVoice_InitReturnZero();
  ram_285d &= ~0x01;
  ram_285d &= ~0x02;
  ram_2881 &= ~0x01;
  ram_2881 &= ~0x04;
}
