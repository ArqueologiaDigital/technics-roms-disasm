/* Functions of ui/ui_playback_modes.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
