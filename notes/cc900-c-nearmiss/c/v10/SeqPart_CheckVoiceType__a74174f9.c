/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m236.c (2026-11-16-68-p6-r12)
   sha256 a74174f9a0f0750c872a059b7166073bef5353e1a12db7a63499df86e524d102 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);
unsigned char SeqPart_CheckVoiceType(unsigned char a)
{
  unsigned char t;
  a--;
  t = SEQ_TRACK_ASSIGN[a];
  if (t != 15 && t != 16 && t != 13) return t;
  SEQ_ERROR_CODE = 9;
  SeqError_MapViaTableA();
  SeqVoice_InitReturnZero();
  return 0xff;
}
