/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_14m232.c (2026-11-16-100-p6-r19)
   sha256 b5c38cb9e43a3631f9fd76c608f47f2f41b66081cae679390eebe9933612b9ff (tar-sha256); compiled at -O3 -Xr */
extern void UI_ChangeTitleByIndex(unsigned int);
extern void SeqVoice_FindSingleActive(void);
extern unsigned char __near ram_2742;
extern unsigned int __near ram_2963;
extern unsigned int __near ram_d4f;
extern unsigned char __near ram_1d58;
extern unsigned char __near PART_SELECT;
void BmDrEdit_SaveSequencerState(void)
{
	UI_ChangeTitleByIndex((ram_2742 & 1) ? 0x98 : 0x95);
	ram_2963 = ram_d4f;
	SeqVoice_FindSingleActive();
	ram_1d58 = PART_SELECT;
}
