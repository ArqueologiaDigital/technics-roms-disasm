/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/bmdredit_routines_m232_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 fdec1c71f6e8bb687ebd30794c967e968cd22dea2767db4d6f4b5b29d88baf19 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern void UI_ChangeTitleByIndex(unsigned int);
extern void SeqVoice_FindSingleActive(void);
extern unsigned char __near ram_2742;
extern unsigned int __near ram_2963;
extern unsigned int __near ram_d4f;
extern unsigned char __near ram_1d58;
extern unsigned char __near PART_SELECT;
void BmDrEdit_SaveSequencerState(void)
{
	unsigned int k;

	if (ram_2742 & 1) k = 0x98;
	else k = 0x95;
	UI_ChangeTitleByIndex(k);
	ram_2963 = ram_d4f;
	SeqVoice_FindSingleActive();
	ram_1d58 = PART_SELECT;
}
