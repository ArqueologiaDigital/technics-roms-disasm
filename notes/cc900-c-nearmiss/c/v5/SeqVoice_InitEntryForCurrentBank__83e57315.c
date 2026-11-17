/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-16-111-p6-r22-staged)
   sha256 83e57315c375c1c940336c1fd470f4631a66d0a489ca456b1c516c63985f9806 (tar-sha256); compiled at -O3 -Xr
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
