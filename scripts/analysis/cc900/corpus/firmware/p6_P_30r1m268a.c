/* lane_p6 helper P, round 30r1, form a: module 268 (demo/file_demo_proc.s), GetFileEntryByIndex /
   FileIO_ByteBlock_DemoProc2.  One-spot retries of helper O's p6_O_29r1m268a (run r78):
   - GetFileEntryByIndex (+18): the ROM loads the first-shown index into WA BEFORE it copies i, `ld wa, (first:24);
     ld bc, iz; sub bc, wa`, where V4.23 subtracted from memory; here the first-shown index is volatile (a volatile
     object is read into a register on its own);
   - FileIO_ByteBlock_DemoProc2 (+16 at Xr; O3Xr agrees up to the bit test): the ROM tests the bit with
     `ldcf 7, (xwa); scc c, l; extz hl`, a one-bit field: bit 7 of byte 0x42 of the record as an unsigned int bit
     field (LSB-first allocation assumed).
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_SearchFile ProcessFileRecord ValidateFileRange */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern char *GetFileEntryByIndex(int i);
extern int FileIO_ByteBlock_DemoProc2(int i);

char *GetFileEntryByIndex(int i)
{
	if (ValidateFileRange(i) != 0)
		return FileIO_EmptyEntryName;
	if (FileIO_SearchFile(ram_25ec0[(unsigned int)(i - ram_271ee)].b, FileIO_EmptyNameKey) == 0)
		ProcessFileRecord(i);
	return ram_25ec0[(unsigned int)(i - ram_271ee)].b;
}

int FileIO_ByteBlock_DemoProc2(int i)
{
	if (ValidateFileRange(i) != 0)
		return -1;
	return ram_25ec0[(unsigned int)i].f7;
}
