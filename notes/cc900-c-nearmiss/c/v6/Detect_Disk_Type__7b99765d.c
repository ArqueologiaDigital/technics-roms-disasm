/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/system_handlers_m5.c (2026-11-18-12-p6-r35)
   sha256 7b99765da7ab35bf614ecb669d93a4614a3aa800e9a4701e002a9da4da529123 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern int __cdecl String_Compare(void *, void *, int);
extern void FDC_ReadSectors(long, int, void *);
extern char FILETYPE_SIG_PROGRAM_1[], FILETYPE_SIG_PROGRAM_2[], FILETYPE_SIG_TABLE_1[], FILETYPE_SIG_TABLE_2[];
extern char FILETYPE_SIG_CMPCUSTOM[], FILETYPE_SIG_HDAE_PRG[], FILETYPE_SIG_PROGRAM_PCK[], FILETYPE_SIG_TABLE_PCK[];
unsigned char Detect_Disk_Type(void)
{
	unsigned char t;
	unsigned char *buf;

	t = 0xff;
	buf = Malloc(0x200);
	FDC_ReadSectors(0x21, 1, buf);
	if (String_Compare(buf, FILETYPE_SIG_PROGRAM_1, 0x26) == 0) t = 1;
	else if (String_Compare(buf, FILETYPE_SIG_PROGRAM_2, 0x26) == 0) t = 2;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_1, 0x26) == 0) t = 3;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_2, 0x26) == 0) t = 4;
	else if (String_Compare(buf, FILETYPE_SIG_CMPCUSTOM, 0x26) == 0) t = 5;
	else if (String_Compare(buf, FILETYPE_SIG_HDAE_PRG, 0x26) == 0) t = 6;
	else if (String_Compare(buf, FILETYPE_SIG_PROGRAM_PCK, 0x26) == 0) t = 7;
	else if (String_Compare(buf, FILETYPE_SIG_TABLE_PCK, 0x26) == 0) t = 8;
	Free(buf);
	return t;
}
