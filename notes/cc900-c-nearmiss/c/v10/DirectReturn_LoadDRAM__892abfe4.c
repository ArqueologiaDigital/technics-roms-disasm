/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_28r1m302b.c (2026-11-22-9-p6-r76)
   sha256 892abfe478a4939b9053f36a0f90bb459d501e4b096acc589bd3ecbbdf307d46 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern void FDC_DrainQueuesAndReset(void);
extern void SndTable_LookupC(void);
extern void FileIO_InitTrackSlots(void);
extern unsigned char __near ram_e9e4;
extern unsigned int __near ram_11f5;
void DirectReturn_LoadDRAM(void)
{
	switch (ram_e9e4) {
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
	default:
		break;
	}
	ram_11f5 = 120;
}
