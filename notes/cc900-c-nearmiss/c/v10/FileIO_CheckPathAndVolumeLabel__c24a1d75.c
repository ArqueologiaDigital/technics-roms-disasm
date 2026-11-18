/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_J_2m240a.c (2026-11-18-28-p6-r36)
   sha256 c24a1d7591adeb59de4d704d2d0c4c65a1bd2e4454efb31bf006c722f3dfca1b (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper J, round 2, module 240 (sequencer/smf_event_processor.s; the module's matched C is -Xr),
   form a: GetVolumeLabel, GetDiskFreeSpace, FileIO_CheckPathAndVolumeLabel, FileIO_ParsePathComponents.
   File calls are __cdecl (caller pops, string addresses pushed as @hi16 / @lo16 word pairs).  The two disk-type
   switches have their jump tables in widget_descriptors.s (cases 0, 1, 5, 6 = the table base). */
/* cc900-name: VolLabel_Str_d=FileIO_ReadVolumeLabelEntry_Str_d */
/* cc900-name: VolLabel_Str_A=FileIO_ReadVolumeLabelEntry_Str_A */
/* cc900-name: FreeSpace_Str_d=FileIO_ReadFreeSpaceViaFAT_Str_d */
/* cc900-name: FreeSpace_Str_A=FileIO_ReadFreeSpaceViaFAT_Str_A */
/* cc900-name: ParseLoop_Str_Backslash=FileIO_ParseLoop_CheckChar_Str_Backslash */
/* cc900-data: GetVolumeLabel 1 = GetVolumeLabel_CaseTable */
/* cc900-data: GetDiskFreeSpace 1 = GetDiskFreeSpace_CaseTable */
/* cc900-module: FDC_ReadDiskType GetVolumeLabel */   /* scripts/analysis/cc900/module_calls.py v10 */

struct file;
extern struct file *__cdecl FileOpen(char *, char *);
extern int __cdecl FileClose(struct file *);
extern int __cdecl FileRead(char *, int, int, struct file *);
extern char *__cdecl Strcat(char *, char *);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void __cdecl SeqStep_FileSectorComplete(unsigned char *e, unsigned char *raw);
extern unsigned long __cdecl SeqStep_CalcTotalSectors(struct file *);
extern unsigned char FDC_ReadDiskType(void);
extern char *GetVolumeLabel(void);

extern char VolLabel_Str_d[], VolLabel_Str_A[], FreeSpace_Str_d[], FreeSpace_Str_A[];
extern char PathInfo_BuildAndOpen_Str_A[], PathInfo_BuildAndOpen_Str_wb[], ParseLoop_Str_Backslash[];
extern char ram_22720[];

/* The volume label of the disk in the drive (copied to 0x22720), or 0: scan the root directory of "A:\" for the
   entry with attribute bit 3.  d = the decoded entry (name at 0, attributes at 12), ent = the raw 32 bytes. */
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

/* The disk's total size by type (2DD 0xb2400, 2HD 0x163e00, type 4 737280) into *total, the free size counted from
   the FAT into *freesz; 0 for no disk or an unusable one. */
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

/* 1 when name (under "A:\") is a subdirectory, 0 otherwise or when the disk has a volume label.  attr is read
   without being set (the ROM reads the frame word at xsp+4 that nothing writes). */
int FileIO_CheckPathAndVolumeLabel(char *name)
{
	unsigned int attr;
	char path[16];
	struct file *fp;

	if (GetVolumeLabel() != 0)
		return 0;
	path[0] = 0;
	Strcat(path, PathInfo_BuildAndOpen_Str_A);
	Strcat(path, name);
	fp = FileOpen(path, PathInfo_BuildAndOpen_Str_wb);
	if (fp == 0)
		return 0;
	((unsigned char *)fp)[64] = 0x28;
	((unsigned char *)fp)[3] |= 0x80;
	FileClose(fp);
	if ((attr & 8) == 8)
		return 1;
	return 0;
}

/* Append the directory part of the path at *pp to out ("\"-separated, components of at most 12 characters);
   *pp is left at the last component.  -1 when a component is too long. */
int FileIO_ParsePathComponents(char *out, char **pp)
{
	char comp[13];
	int n;
	char *start;

	n = 0;
	*out = 0;
	start = *pp;
	while (**pp != 0) {
		if (**pp == '\\') {
			comp[n] = 0;
			if (*out != 0)
				Strcat(out, ParseLoop_Str_Backslash);
			Strcat(out, comp);
			n = 0;
			start = *pp + 1;
		} else {
			comp[n] = **pp;
			if (++n > 12)
				return -1;
		}
		*pp += 1;
	}
	*pp = start;
	return 0;
}
