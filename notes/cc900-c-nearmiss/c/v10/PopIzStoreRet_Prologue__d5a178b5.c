/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_36r1m299a.c (2026-11-22-25-p6-r92)
   sha256 d5a178b535f1d95434a7786d98b59ae32a9b23fcacb908af38c627e96d29628f (tar-sha256); compiled at -Xr */
extern unsigned char __near AUDIO_STATE[];
extern unsigned char __near AUDIO_STATE_SENT[];
extern void NoteMap_AssignVoiceParams();
extern void NoteMap_AllocateVoice();
void PopIzStoreRet_Prologue(unsigned char a, unsigned char c, unsigned char e)
{
  if (c == 0xff && e != 0xff)
    NoteMap_AssignVoiceParams(AUDIO_STATE_SENT, a);
  else if (c != 0xff && e != 0xff) {
    NoteMap_AssignVoiceParams(AUDIO_STATE_SENT, a);
    NoteMap_AllocateVoice(AUDIO_STATE, a);
  } else
    NoteMap_AllocateVoice(AUDIO_STATE, a);
}
