/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_SeekAndRead16BitValue NotePool_InsertEntry SeqAcc_InitPlayback_FreshStart SeqPlay_CheckDrumPartAndClearCounters SeqPlay_ProcessChannelsAndDrum SeqPlay_ReactivatePartsAndResume SeqPlay_RestartWithVoiceConfig */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ACTIVE_TITLE;
extern unsigned long __near SEQ_SCREEN_OBJECT;
extern void ApDeliveryEvent(long, long, long);
extern void SeqAccomp_SendStopNotify(void);

void SeqAccomp_SendStopNotify(void)
{
  if (ACTIVE_TITLE == 0x85 || ACTIVE_TITLE == 0x87)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, 0x1c0000fL, 2L);
}
