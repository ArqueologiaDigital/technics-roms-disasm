/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_2m240a.c (2026-11-18-28-p6-r36)
   sha256 c24a1d7591adeb59de4d704d2d0c4c65a1bd2e4454efb31bf006c722f3dfca1b (tar-sha256); compiled at -O3 -Xr
   cc900-name: FreeSpace_Str_A=FileIO_ReadFreeSpaceViaFAT_Str_A
   cc900-name: FreeSpace_Str_d=FileIO_ReadFreeSpaceViaFAT_Str_d
   cc900-name: VolLabel_Str_A=FileIO_ReadVolumeLabelEntry_Str_A
   cc900-name: VolLabel_Str_d=FileIO_ReadVolumeLabelEntry_Str_d */
struct file;
extern struct file *__cdecl FileOpen(char *, char *);
extern int __cdecl FileClose(struct file *);
extern unsigned long __cdecl SeqStep_CalcTotalSectors(struct file *);
extern unsigned char FDC_ReadDiskType(void);
extern char VolLabel_Str_d[], VolLabel_Str_A[], FreeSpace_Str_d[], FreeSpace_Str_A[];
int GetDiskFreeSpace(unsigned long *freesz, unsigned long *total)
{
	struct file *fp;

	switch (FDC_ReadDiskType()) {
	case 0:
	case 1:
	case 5:
	case 6:
		return 0;
	case 2:
		*total = 0xb2400;
		break;
	case 3:
		*total = 0x163e00;
		break;
	case 4:
		*total = 737280;
		break;
	}
	fp = FileOpen(FreeSpace_Str_A, FreeSpace_Str_d);
	if (fp == 0)
		return 0;
	*freesz = SeqStep_CalcTotalSectors(fp);
	FileClose(fp);
	return 1;
}
