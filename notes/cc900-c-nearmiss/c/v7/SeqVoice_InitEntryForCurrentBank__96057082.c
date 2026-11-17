/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m234.c (2026-11-16-111-p6-r22-staged)
   sha256 96057082564aad4810f639161de48cb27e23aab7d0acecc00e114ba0cea9b669 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near SEQ_SONG;
extern void SeqVoice_InitEntry(void);
void SeqVoice_InitEntryForCurrentBank(void)
{
  unsigned char s = SEQ_SONG;
  SEQ_SONG = SEQ_CURRENT_SONG;
  SeqVoice_InitEntry();
  SEQ_SONG = s;
}
