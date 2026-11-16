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
extern unsigned int __near ram_275e;
extern unsigned int __near ram_ce3;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2744;
extern void BmDrEdit_InsertMultiSongSteps(void);
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void NoteEditSy_SendWidgetCmdC(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_SetupScrollRegion(unsigned char *, unsigned char *);
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
extern void BmDrEdit_PrepareSecondaryNoteDisplay(void);

void BmDrEdit_InsertMultiSongSteps(void)
{
	unsigned int a, b;
	unsigned char r;

	ram_ce3 = ram_2772;
	ram_275e = ram_2772;
	for (;;) {
		r = BmDrEdit_ProcessVoiceSection(BmDrEdit_CheckAndSelectChannel(), &a, &b);
		if (ram_2744 == a) goto out;
		if (b != 0) r -= b;
		ram_2772 = r;
		do {
			EditChannel_LoadVoiceParams();
			BmDrEdit_InsertStepEntry();
			if (SEQ_ERROR_CODE != 0) goto out;
			ram_275e++;
		} while (--ram_2772 != 0);
		ram_ce3 = ram_275e;
	}
out:
	;
}

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
			w *= 0x60;
			w += v;
			ram_2820 = w;
			NoteEditSy_SendWidgetCmdC();
		}
	}
	BmDrEdit_RestoreEditState();
}
