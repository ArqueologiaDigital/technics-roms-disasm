/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_2m240a.c (2026-11-18-28-p6-r36)
   sha256 c24a1d7591adeb59de4d704d2d0c4c65a1bd2e4454efb31bf006c722f3dfca1b (tar-sha256); compiled at -O3 -Xr
   cc900-name: FreeSpace_Str_A=FileIO_ReadFreeSpaceViaFAT_Str_A
   cc900-name: FreeSpace_Str_d=FileIO_ReadFreeSpaceViaFAT_Str_d
   cc900-name: VolLabel_Str_A=FileIO_ReadVolumeLabelEntry_Str_A
   cc900-name: VolLabel_Str_d=FileIO_ReadVolumeLabelEntry_Str_d */
struct file;
extern struct file *__cdecl FileOpen(char *, char *);
extern int __cdecl FileClose(struct file *);
extern int __cdecl FileRead(char *, int, int, struct file *);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void __cdecl SeqStep_FileSectorComplete(unsigned char *e, unsigned char *raw);
extern unsigned char FDC_ReadDiskType(void);
extern char VolLabel_Str_d[], VolLabel_Str_A[], FreeSpace_Str_d[], FreeSpace_Str_A[];
extern char ram_22720[];
char *GetVolumeLabel(void)
{
	unsigned char d[24];
	unsigned char ent[32];
	struct file *fp;

	switch (FDC_ReadDiskType()) {
	case 0:
	case 1:
	case 5:
	case 6:
		return 0;
	case 2:
	case 3:
	case 4:
		break;
	}
	fp = FileOpen(VolLabel_Str_A, VolLabel_Str_d);
	if (fp == 0)
		return 0;
	if (FileRead((char *)ent, 32, 1, fp) == 1)
		do {
			SeqStep_FileSectorComplete(d, ent);
			if (d[12] & 2)
				continue;
			if (d[0] == 0xe5)
				continue;
			if (d[0] == 0)
				break;
			if (!(d[12] & 8))
				continue;
			Mem_Copy(ram_22720, d, 11);
			ram_22720[11] = 0;
			FileClose(fp);
			return ram_22720;
		} while (FileRead((char *)ent, 32, 1, fp) == 1);
	FileClose(fp);
	return 0;
}
