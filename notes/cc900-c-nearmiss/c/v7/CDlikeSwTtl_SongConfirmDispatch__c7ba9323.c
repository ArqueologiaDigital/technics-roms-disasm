/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_playback_modes_m203_xr.c (2026-11-21-5-p6-r60)
   sha256 c7ba9323973217ebd346cc82e745f36b53c04c1cd90d5eb44909bd8f778f044c (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_1d4a;
extern void SeqRecPlay_EnablePlayOnly(void);
extern void SeqRecPlay_EnableRecordOnly(void);
extern void Acc_TransitionPlayMode(void);
extern void Acc_StopPlayMode(void);
void CDlikeSwTtl_SongConfirmDispatch(void)
{
  switch (ram_1d4a) {
  case 3:
  case 1:
    SeqRecPlay_EnablePlayOnly();
    Acc_TransitionPlayMode();
    break;
  case 2:
    SeqRecPlay_EnableRecordOnly();
    Acc_StopPlayMode();
    break;
  }
}
