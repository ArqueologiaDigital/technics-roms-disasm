/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_15m232.c (2026-11-16-107-p6-r21)
   sha256 240191ef3be2e449886b358a2a734bde597b96c0f0a089bbc370d36c3c959ef3 (tar-sha256); compiled at -O3 -Xr */
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
