/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/bmdredit_routines_m232.c (2026-11-16-125-p6-r26-staged)
   sha256 850da7a07f6109e746c7c45fdaf42589c657a939b127fe5580cad682caf60680 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_275e;
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
