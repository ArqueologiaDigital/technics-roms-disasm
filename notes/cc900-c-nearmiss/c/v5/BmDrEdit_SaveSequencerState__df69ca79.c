/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 df69ca79d83e456e0bf2462cc7c1965d32226aae7cfa65b0db8390ab220b7795 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern void UI_ChangeTitleByIndex(unsigned int);
extern void SeqVoice_FindSingleActive(void);
extern unsigned char __near ram_2728;
extern unsigned int __near ram_2947;
extern unsigned int __near ram_d4f;
extern unsigned char __near ram_1d54;
extern unsigned char __near PART_SELECT;
void BmDrEdit_SaveSequencerState(void)
{
	unsigned int k;

	if (ram_2728 & 1) k = 0x98;
	else k = 0x95;
	UI_ChangeTitleByIndex(k);
	ram_2947 = ram_d4f;
	SeqVoice_FindSingleActive();
	ram_1d54 = PART_SELECT;
}
