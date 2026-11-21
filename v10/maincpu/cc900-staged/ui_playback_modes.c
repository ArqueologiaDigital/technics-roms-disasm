/* Functions of ui/ui_playback_modes.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near PLAYBACK_START_ARMED;

void DpMdlyDoc_DisarmStartCountdown(void)
{
  PLAYBACK_START_ARMED = 0;
}

extern unsigned char __near ram_1d4a;
extern int SeqState_GetFlags(void);
extern void CDlikeSwTtl_ShowDocTitle(void);
extern void CDlikeSwTtl_ShowPdTitle(void);
extern void SeqRecPlay_EnablePlayOnly(void);
extern void SeqRecPlay_DisableBoth(void);
extern void Song_AbortPlayback(void);
extern void Acc_StartFillIn(void);

void CDlikeSwTtl_DocConfirmStart(void)
{
  if (SeqState_GetFlags() & 2)
    ram_1d4a = 3;
  else if (SeqState_GetFlags() & 1)
    ram_1d4a = 2;
  else {
    ram_1d4a = 1;
    CDlikeSwTtl_ShowDocTitle();
    SeqRecPlay_EnablePlayOnly();
  }
  Acc_StartFillIn();
}

void CDlikeSwTtl_PdBitCheck(void)
{
  if (!(SeqState_GetFlags() & 2) && !(SeqState_GetFlags() & 1))
    CDlikeSwTtl_ShowPdTitle();
  else {
    SeqRecPlay_DisableBoth();
    Song_AbortPlayback();
  }
}

void DpMdlyPd_DisarmStartCountdown(void)
{
  PLAYBACK_START_ARMED = 0;
}

void PlayMode_ClearModeFlag(void)
{
  PLAYBACK_START_ARMED = 0;
}

extern void CDlikeSwTtl_ShowSongTitle(void);

void CDlikeSwTtl_DocBitCheck(void)
{
  if (!(SeqState_GetFlags() & 2) && !(SeqState_GetFlags() & 1))
    CDlikeSwTtl_ShowDocTitle();
  else {
    SeqRecPlay_DisableBoth();
    Song_AbortPlayback();
  }
}

void CDlikeSwTtl_PdConfirmStart(void)
{
  if (SeqState_GetFlags() & 2)
    ram_1d4a = 3;
  else if (SeqState_GetFlags() & 1)
    ram_1d4a = 2;
  else {
    ram_1d4a = 1;
    CDlikeSwTtl_ShowPdTitle();
    SeqRecPlay_EnablePlayOnly();
  }
  Acc_StartFillIn();
}

void CDlikeSwTtl_SongConfirmStart(void)
{
  if (SeqState_GetFlags() & 2)
    ram_1d4a = 3;
  else if (SeqState_GetFlags() & 1)
    ram_1d4a = 2;
  else {
    ram_1d4a = 1;
    CDlikeSwTtl_ShowSongTitle();
    SeqRecPlay_EnablePlayOnly();
  }
  Acc_StartFillIn();
}
