/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232.c (2026-11-16-125-p6-r26-staged)
   sha256 017edf69f2efe09b667a86707fe731921926ec2ef18bb1a035f47a78d8991cc4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_2744;
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
