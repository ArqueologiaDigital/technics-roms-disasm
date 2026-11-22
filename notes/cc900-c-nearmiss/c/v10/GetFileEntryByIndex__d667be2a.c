/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_30r1m268a.c (2026-11-22-13-p6-r80)
   sha256 d667be2a804677d84e60609ebb51a685c5ec65e3a0bfbd29d620663ad835bbf5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct FileRec82 {
	char b[0x42];
	unsigned int f0 : 7;
	unsigned int f7 : 1;
	char rest[82 - 0x44];
};
extern struct FileRec82 ram_25ec0[];
extern volatile int ram_271ee;
extern char FileIO_EmptyEntryName[];
extern char FileIO_EmptyNameKey[];
extern int ValidateFileRange(int i);
extern int FileIO_SearchFile(char *, char *);
extern void ProcessFileRecord(int i);
char *GetFileEntryByIndex(int i)
{
	if (ValidateFileRange(i) != 0)
		return FileIO_EmptyEntryName;
	if (FileIO_SearchFile(ram_25ec0[(unsigned int)(i - ram_271ee)].b, FileIO_EmptyNameKey) == 0)
		ProcessFileRecord(i);
	return ram_25ec0[(unsigned int)(i - ram_271ee)].b;
}
