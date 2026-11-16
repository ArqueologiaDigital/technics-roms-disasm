/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CheckAndSelectChannel BmDrEdit_InsertStepEntry BmDrEdit_ProcessVoiceSection BmDrEdit_RestoreEditState BmDrEdit_SaveEditState BmDrEdit_SetupScrollRegion EditChannel_LoadVoiceParams */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern unsigned char BmDrEdit_ProcessVoiceSection(unsigned int, unsigned int *, unsigned int *);
extern void EditChannel_LoadVoiceParams(void);
extern void BmDrEdit_InsertStepEntry(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2744;
extern unsigned int __near ram_ce3;
extern unsigned int __near ram_2758;
extern unsigned int __near ram_272a;
extern void BmDrEdit_InsertMultiSongSteps(void);
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void NoteEditSy_SendWidgetCmdC(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_SetupScrollRegion(unsigned char *, unsigned char *);
extern unsigned char __near ram_2943;
extern unsigned int __near ram_27f2;
extern unsigned int __near ram_2750;
extern unsigned int __near ram_27f4;
extern unsigned char __near ram_2752;
extern unsigned int __near ram_27f6;
extern unsigned int __near ram_2754;
extern unsigned int __near ram_27f8;
extern unsigned char __near ram_2756;
extern unsigned int __near ram_27fa;
extern unsigned int __near ram_27fc;
extern unsigned char __near ram_2746;
extern unsigned int __near ram_27fe;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_2800;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near ram_2802;
extern unsigned char __near ram_280c;
extern unsigned char __near ram_280e;
extern unsigned int __near ram_2806;
extern void BmDrEdit_PrepareSecondaryNoteDisplay(void);

void BmDrEdit_InsertMultiSongSteps(void)
{
	unsigned int a, b;
	unsigned char r;

	ram_ce3 = ram_2758;
	ram_2744 = ram_2758;
	for (;;) {
		r = BmDrEdit_ProcessVoiceSection(BmDrEdit_CheckAndSelectChannel(), &a, &b);
		if (ram_272a == a) goto out;
		if (b != 0) r -= b;
		ram_2758 = r;
		do {
			EditChannel_LoadVoiceParams();
			BmDrEdit_InsertStepEntry();
			if (SEQ_ERROR_CODE != 0) goto out;
			ram_2744++;
		} while (--ram_2758 != 0);
		ram_ce3 = ram_2744;
	}
out:
	;
}

void BmDrEdit_PrepareSecondaryNoteDisplay(void)
{
	unsigned char lo, hi;
	unsigned int v, w;

	if (!(ram_2943 & 1)) return;
	BmDrEdit_SaveEditState();
	ram_27f2 = ram_2750;
	ram_27f4 = ram_2752;
	ram_27f6 = ram_2754;
	ram_27f8 = ram_2756;
	ram_27fa = ram_2744;
	ram_27fc = ram_2746;
	ram_27fe = SEQ_DATA_BLOCK;
	ram_2800 = SEQ_DATA_OFFSET;
	if ((SeqData_ReadNextByte() & 0xf0) == 0x90) {
		SeqData_AdvancePosition();
		ram_27fc = SeqData_ReadNextByte();
		SeqData_AdvancePosition();
		ram_2802 = SeqData_ReadNextByte();
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		if (ram_2802 >= lo && ram_2802 <= hi) {
			ram_280c = lo;
			ram_280e = hi;
			SeqData_AdvancePosition();
			SeqData_AdvancePosition();
			v = SeqData_ReadNextByte();
			SeqData_AdvancePosition();
			w = SeqData_ReadNextByte();
			v &= 0x7f;
			w &= 0x7f;
			w *= 0x60;
			w += v;
			ram_2806 = w;
			NoteEditSy_SendWidgetCmdC();
		}
	}
	BmDrEdit_RestoreEditState();
}
