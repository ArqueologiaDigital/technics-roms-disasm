/* lane_p6 helper P, round 30r1, form b: module 268 (demo/file_demo_proc.s), GetFileEntryByIndex /
   FileIO_ByteBlock_DemoProc2.  One-spot retries of helper O's p6_O_29r1m268a (run r78):
   - GetFileEntryByIndex (+18): the ROM loads the first-shown index into WA before it copies i, `ld wa, (first:24);
     ld bc, iz; sub bc, wa`; form b reads it into an int local first, j = first, then indexes by i - j;
   - FileIO_ByteBlock_DemoProc2 (+16): the ROM's `ldcf 7, (xwa); scc c, l; extz hl` bit test, here as unsigned
     char bit fields (bit 7 of byte 0x42 in a one-byte unit).
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_SearchFile ProcessFileRecord ValidateFileRange */   /* scripts/analysis/cc900/module_calls.py v10 */

struct FileRec82 {
	char b[0x42];
	unsigned char f0 : 7;
	unsigned char f7 : 1;
	char rest[82 - 0x43];
};

extern struct FileRec82 ram_25ec0[];
extern int ram_271ee;
extern char FileIO_EmptyEntryName[];
extern char FileIO_EmptyNameKey[];
extern int ValidateFileRange(int i);
extern int FileIO_SearchFile(char *, char *);
extern void ProcessFileRecord(int i);
extern char *GetFileEntryByIndex(int i);
extern int FileIO_ByteBlock_DemoProc2(int i);

char *GetFileEntryByIndex(int i)
{
	int j;

	if (ValidateFileRange(i) != 0)
		return FileIO_EmptyEntryName;
	j = ram_271ee;
	if (FileIO_SearchFile(ram_25ec0[(unsigned int)(i - j)].b, FileIO_EmptyNameKey) == 0)
		ProcessFileRecord(i);
	j = ram_271ee;
	return ram_25ec0[(unsigned int)(i - j)].b;
}

int FileIO_ByteBlock_DemoProc2(int i)
{
	if (ValidateFileRange(i) != 0)
		return -1;
	return ram_25ec0[(unsigned int)i].f7;
}
