/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CheckAndAdvancePage BmDrEdit_LoadAlternateState BmDrEdit_RefreshDisplayState BmDrEdit_ScanChannelEvents BmDrEdit_SeekToPartVoice BmDrEdit_SelectChannelAndLoadPos BmDrEdit_SendMetronomeNoteOn BmDrEdit_SetupAndWalkToNote BmDrEdit_SkipToEventByCount BmDrEdit_SyncSeekCheck NoteEditSy_SendCompoundWidgetUpdate NoteEdit_SendScrollCmds NoteEdit_UpdateScrollAndDisplay SeqAcc_SetupRepeatCount SeqAcc_UpdateEndPosition */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_295f;
extern void BmDrEdit_SelectChannelAndLoadPos(void);
extern void BmDrEdit_SeekToPartVoice(void);
extern void BmDrEdit_LoadAlternateState(void);
extern void BmDrEdit_SkipToEventByCount(void);
extern void BmDrEdit_RefreshDisplayState(void);
extern void BmDrEdit_ScanChannelEvents(void);
extern void BmDrEdit_SyncSeekCheck(void);
extern void BmDrEdit_SetupAndWalkToNote(void);
extern void NoteEditSy_SendCompoundWidgetUpdate(void);
extern void NoteEdit_UpdateScrollAndDisplay(void);
extern void NoteEditSy_SendWidgetCmd0(void);
extern void NoteEdit_SendScrollCmds(void);
extern void BmDrEdit_SendMetronomeNoteOn(void);
extern void BmDrEdit_ReloadChannelAndDisplay(void);

void BmDrEdit_ReloadChannelAndDisplay(void)
{
	BmDrEdit_SelectChannelAndLoadPos();
	if (SEQ_ERROR_CODE != 0) {
		BmDrEdit_SeekToPartVoice();
		if (SEQ_ERROR_CODE != 0)
			goto refresh;
		BmDrEdit_SelectChannelAndLoadPos();
	}
	BmDrEdit_LoadAlternateState();
	BmDrEdit_SkipToEventByCount();
	if (SEQ_ERROR_CODE != 0) {
		BmDrEdit_SeekToPartVoice();
		if (SEQ_ERROR_CODE != 0) {
refresh:
			BmDrEdit_RefreshDisplayState();
			return;
		}
	}
	BmDrEdit_LoadAlternateState();
	BmDrEdit_ScanChannelEvents();
	BmDrEdit_SyncSeekCheck();
	BmDrEdit_SetupAndWalkToNote();
	NoteEditSy_SendCompoundWidgetUpdate();
	NoteEdit_UpdateScrollAndDisplay();
	NoteEditSy_SendWidgetCmd0();
	NoteEdit_SendScrollCmds();
	if (ram_295f & 0x01)
		BmDrEdit_SendMetronomeNoteOn();
}

/* cc900-module: BmDrEdit_DecrementVelocity BmDrEdit_IncrementVelocity BmDrEdit_NullReturn BmDrEdit_UpdateVelocityDisplay */
extern unsigned char __near ram_295c;
extern unsigned char __near ram_295d;
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2786;
extern void BmDrEdit_DrumVoiceDown(void);
extern void BmDrEdit_UpdateVelocityDisplay(void);
extern void NoteEditSy_SendScrollCmd3(void);
extern void BmDrEdit_NullReturn(void);
extern void BmDrEdit_DecrementVelocity(void);
extern void BmDrEdit_DrumVoiceUp(void);
extern void BmDrEdit_IncrementVelocity(void);

void BmDrEdit_DecrementVelocity(void)
{
  unsigned char v;

  v = ram_2786;
  if (v == 1)
    return;
  ram_2786 = v - 1;
  if (ram_2742 & 1)
    BmDrEdit_DrumVoiceDown();
  BmDrEdit_UpdateVelocityDisplay();
  NoteEditSy_SendScrollCmd3();
  BmDrEdit_NullReturn();
  ram_295c = 0x83;
  ram_295d = 2;
}
void BmDrEdit_IncrementVelocity(void)
{
  unsigned char v;

  v = ram_2786;
  if (v >= 0x7f)
    return;
  ram_2786 = v + 1;
  if (ram_2742 & 1)
    BmDrEdit_DrumVoiceUp();
  BmDrEdit_UpdateVelocityDisplay();
  NoteEditSy_SendScrollCmd3();
  BmDrEdit_NullReturn();
  ram_295c = 0x83;
  ram_295d = 2;
}
