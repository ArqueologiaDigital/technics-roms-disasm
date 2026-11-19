/* lane_p6 helper N, round 6, form a: module 232 (sequencer/sequencer_engine.s), retry of p6_N_5m232a
   (p6-r47: +63).  SeqPlay_IncPunchCountIn: the listing is the ROM's code except the last store, which V4.23 made
   a memory-to-memory move (`ram_26ec = SEQ_START_MEASURE` right before the tail jump) where the ROM stores WA:
   the start measure assigned through a chained assignment.  Below it, three new functions of the module's
   bmdredit_routines.s part.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CheckAndAdvancePage BmDrEdit_LoadAlternateState BmDrEdit_RefreshDisplayState BmDrEdit_ScanChannelEvents BmDrEdit_SeekToPartVoice BmDrEdit_SelectChannelAndLoadPos BmDrEdit_SendMetronomeNoteOn BmDrEdit_SetupAndWalkToNote BmDrEdit_SkipToEventByCount BmDrEdit_SyncSeekCheck NoteEditSy_SendCompoundWidgetUpdate NoteEdit_SendScrollCmds NoteEdit_UpdateScrollAndDisplay SeqAcc_SetupRepeatCount SeqAcc_UpdateEndPosition */

extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26ec;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28c3;
extern void SeqAcc_UpdateEndPosition(void);
extern void SeqAcc_SetupRepeatCount(void);

void SeqPlay_IncPunchCountIn(void)
{
	unsigned int c;

	if ((SEQ_METRO_FLAGS & 0x01) && SEQ_PUNCH_IN_MEASURE <= 2)
		return;
	c = SEQ_COUNT_IN;
	if (c >= 997)
		SEQ_COUNT_IN = 997;
	else
		SEQ_COUNT_IN = c + 1;
	ram_28c3 = SEQ_PUNCH_IN_MEASURE - 1;
	SeqAcc_UpdateEndPosition();
	ram_26ec = SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
	SeqAcc_SetupRepeatCount();
}

/* New functions of sequencer/bmdredit_routines.s (siblings of the built BmDrEdit_* of module 232):
   - BmDrEdit_CalcTickPosition: after advancing the page, the tick position 0x279a = measure * 96 + beat tick.
   - BmDrEdit_ReloadChannelAndDisplay: reselects the edited channel (seeking the part's voice when that fails),
     skips to the event, and redraws the note editor; refreshes the display state instead when both fail.
     The last call sits inside an `if`, so it is the ROM's `calr; ret`, not a tail jump. */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_295f;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_2782;
extern unsigned char __near ram_2784;
extern void BmDrEdit_CheckAndAdvancePage(void);
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

void BmDrEdit_CalcTickPosition(void)
{
	BmDrEdit_CheckAndAdvancePage();
	ram_279a = ram_2782 * 0x60 + ram_2784;
}

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

/* NoteEdit_SendScrollCmds: the note editor's scroll / gate / velocity commands, melodic or drum (bit 0 of 0x2742),
   by whether a note is under the cursor (bit 0 of 0x295f).  The ROM keeps both tails (no cross jump). */
extern unsigned char __near ram_2742;
extern void NoteEditSy_SendScrollCmd0(void);
extern void NoteEditSy_SendScrollCmd1(void);
extern void NoteEditSy_SendScrollCmd2(void);
extern void NoteEditSy_SendScrollCmd3(void);
extern void NoteEditSy_SendScrollCmd5(void);
extern void NoteEditSy_SendScrollCmd8(void);
extern void NoteEditSy_SendGateCmd(void);
extern void NoteEditSy_SendVelocityCmd(void);
extern void NoteEditSy_SendModeScrollCmd(void);

void NoteEdit_SendScrollCmds(void)
{
	if (!(ram_2742 & 0x01)) {
		if (!(ram_295f & 0x01))
			NoteEditSy_SendScrollCmd8();
		else {
			NoteEditSy_SendScrollCmd3();
			NoteEditSy_SendGateCmd();
			NoteEditSy_SendScrollCmd5();
		}
		NoteEditSy_SendScrollCmd0();
		NoteEditSy_SendScrollCmd1();
		NoteEditSy_SendScrollCmd2();
		NoteEditSy_SendModeScrollCmd();
	} else {
		if (!(ram_295f & 0x01))
			NoteEditSy_SendVelocityCmd();
		else {
			NoteEditSy_SendScrollCmd3();
			NoteEditSy_SendGateCmd();
		}
		NoteEditSy_SendScrollCmd0();
		NoteEditSy_SendScrollCmd1();
		NoteEditSy_SendScrollCmd2();
		NoteEditSy_SendModeScrollCmd();
	}
}
