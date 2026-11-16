/* Phase 6, lane_p6 helper D, round 17, module 232 (v10 sequencer/bmdredit_routines.s), form b (see
   p6_D_17m232.c): PrepareSecondaryNoteDisplay with the sum written v + w * 0x60; AdjustScrollToView computing the
   new key into the row's local after the test; InsertMultiSongSteps with an inner for (;;) and break / goto;
   SetRowOffsetFromDelta with the difference in a local. */
/* cc900-module: BmDrEdit_CheckAndSelectChannel BmDrEdit_InsertStepEntry BmDrEdit_ProcessVoiceSection BmDrEdit_RestoreEditState BmDrEdit_SaveEditState BmDrEdit_SetupScrollRegion EditChannel_LoadVoiceParams */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void NoteEditSy_SendWidgetCmdC(void);
extern void NoteEditSy_UpdateChordDisplay(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_SetupScrollRegion(unsigned char *, unsigned char *);
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern unsigned char BmDrEdit_ProcessVoiceSection(unsigned int, unsigned int *, unsigned int *);
extern void EditChannel_LoadVoiceParams(void);
extern void BmDrEdit_InsertStepEntry(void);

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_295f;
extern unsigned int __near ram_280c;
extern unsigned int __near ram_276a;
extern unsigned int __near ram_280e;
extern unsigned char __near ram_276c;
extern unsigned int __near ram_2810;
extern unsigned int __near ram_276e;
extern unsigned int __near ram_2812;
extern unsigned char __near ram_2770;
extern unsigned int __near ram_2814;
extern unsigned int __near ram_275e;
extern unsigned int __near ram_2816;
extern unsigned char __near ram_2760;
extern unsigned int __near ram_2818;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_281a;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near ram_281c;
extern unsigned char __near ram_2826;
extern unsigned char __near ram_2828;
extern unsigned int __near ram_2820;
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2962;
extern unsigned char __near ram_27ca;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned int __near ram_ce3;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2744;
extern unsigned char __near ram_27cc;

void BmDrEdit_PrepareSecondaryNoteDisplay(void)
{
	unsigned char lo, hi;
	unsigned int v, w;

	if (!(ram_295f & 1)) return;
	BmDrEdit_SaveEditState();
	ram_280c = ram_276a;
	ram_280e = ram_276c;
	ram_2810 = ram_276e;
	ram_2812 = ram_2770;
	ram_2814 = ram_275e;
	ram_2816 = ram_2760;
	ram_2818 = SEQ_DATA_BLOCK;
	ram_281a = SEQ_DATA_OFFSET;
	if ((SeqData_ReadNextByte() & 0xf0) == 0x90) {
		SeqData_AdvancePosition();
		ram_2816 = SeqData_ReadNextByte();
		SeqData_AdvancePosition();
		ram_281c = SeqData_ReadNextByte();
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		if (ram_281c >= lo && ram_281c <= hi) {
			ram_2826 = lo;
			ram_2828 = hi;
			SeqData_AdvancePosition();
			SeqData_AdvancePosition();
			v = SeqData_ReadNextByte();
			SeqData_AdvancePosition();
			w = SeqData_ReadNextByte();
			v &= 0x7f;
			w &= 0x7f;
			ram_2820 = v + w * 0x60;
			NoteEditSy_SendWidgetCmdC();
		}
	}
	BmDrEdit_RestoreEditState();
}

void BmDrEdit_AdjustScrollToView(void)
{
	unsigned char lo, hi;
	unsigned char c, k;

	if (ram_2742 & 1) return;
	ram_27ca = NOTEEDIT_BASE_KEY;
	for (;;) {
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		c = ram_2962;
		k = NOTEEDIT_BASE_KEY;
		if (c < lo) {
			if (k == 0) return;
			c = k - 1;
			NOTEEDIT_BASE_KEY = c;
			continue;
		}
		if (c <= hi) break;
		if (k >= 9) return;
		c = k + 1;
		NOTEEDIT_BASE_KEY = c;
	}
	if (ram_27ca != NOTEEDIT_BASE_KEY) {
		NoteEditSy_UpdateChordDisplay();
		return;
	}
}

void BmDrEdit_InsertMultiSongSteps(void)
{
	unsigned int a, b;
	unsigned char r;

	ram_ce3 = ram_2772;
	ram_275e = ram_2772;
	for (;;) {
		r = BmDrEdit_ProcessVoiceSection(BmDrEdit_CheckAndSelectChannel(), &a, &b);
		if (ram_2744 == a) break;
		if (b != 0) r -= b;
		ram_2772 = r;
		for (;;) {
			EditChannel_LoadVoiceParams();
			BmDrEdit_InsertStepEntry();
			if (SEQ_ERROR_CODE != 0) goto out;
			ram_275e++;
			if (--ram_2772 == 0) break;
		}
		ram_ce3 = ram_275e;
	}
out:
	;
}

void BmDrEdit_SetRowOffsetFromDelta(unsigned char a, unsigned char c)
{
	unsigned char d;

	d = a - c;
	if (ram_2742 & 1) {
		ram_27cc = 11 - d;
		return;
	}
	c = d;
	ram_27cc = d;
	if (NOTEEDIT_BASE_KEY != 0) return;
	c += 3;
	ram_27cc = c;
}
