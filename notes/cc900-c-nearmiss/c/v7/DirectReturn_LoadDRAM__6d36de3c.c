/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m302_xr.c (2026-11-22-10-p6-r77)
   sha256 6d36de3cf8e1ec82f115492e0c46c65630b19864048e6274434aa4b58beeccff (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern void FDC_DrainQueuesAndReset(void);
extern void SndTable_LookupC(void);
extern void FileIO_InitTrackSlots(void);
extern unsigned char __near ram_e91e;
extern unsigned int __near ram_11f5;
void DirectReturn_LoadDRAM(void)
{
	switch (ram_e91e) {
	case 1:
		FDC_DrainQueuesAndReset();
		FileIO_InitTrackSlots();
		break;
	case 2:
	case 3:
		FDC_DrainQueuesAndReset();
		break;
	case 4:
		SndTable_LookupC();
		FileIO_InitTrackSlots();
		break;
	}
	ram_11f5 = 120;
}
