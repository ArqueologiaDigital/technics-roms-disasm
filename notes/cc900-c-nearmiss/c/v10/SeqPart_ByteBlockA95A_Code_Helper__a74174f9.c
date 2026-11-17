/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m236.c (2026-11-16-68-p6-r12)
   sha256 a74174f9a0f0750c872a059b7166073bef5353e1a12db7a63499df86e524d102 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SeqVoice_InitReturnZero(void);
extern void SeqError_MapViaTableF(void);
extern unsigned char __near ram_2879;
extern unsigned char __near ram_289d;
void SeqPart_ByteBlockA95A_Code_Helper(void)
{
  SeqError_MapViaTableF();
  SeqVoice_InitReturnZero();
  ram_2879 &= ~0x01;
  ram_2879 &= ~0x02;
  ram_289d &= ~0x01;
  ram_289d &= ~0x04;
}
