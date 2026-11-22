/* lane_p6 helper O, round 29r1, form a: module 268 (demo/file_demo_proc.s), GetFileEntryByIndex (singletons29_O):
   returns the 82-byte file-list record of entry i (RAM 0x25ec0 + (i - first shown) * 82); FileIO_EmptyEntryName when
   ValidateFileRange rejects i; loads the record (ProcessFileRecord) first when FileIO_SearchFile finds it still
   empty.  Form a: the record as an array of 82-byte structs indexed by the unsigned difference (the ROM's `extz xwa`
   and the C9H_mullu call = Math_Multiply32).
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_SearchFile ProcessFileRecord ValidateFileRange */   /* scripts/analysis/cc900/module_calls.py v10 */

struct FileRec82 {
	char b[82];
};

extern struct FileRec82 ram_25ec0[];
extern int ram_271ee;
extern char FileIO_EmptyEntryName[];
extern char FileIO_EmptyNameKey[];
extern int ValidateFileRange(int i);
extern int FileIO_SearchFile(char *, char *);
extern void ProcessFileRecord(int i);
extern char *GetFileEntryByIndex(int i);

char *GetFileEntryByIndex(int i)
{
	if (ValidateFileRange(i) != 0)
		return FileIO_EmptyEntryName;
	if (FileIO_SearchFile(ram_25ec0[(unsigned int)(i - ram_271ee)].b, FileIO_EmptyNameKey) == 0)
		ProcessFileRecord(i);
	return ram_25ec0[(unsigned int)(i - ram_271ee)].b;
}

/* FileIO_ByteBlock_DemoProc2 (the next function in the same stretch): -1 when ValidateFileRange rejects i, else bit 7
   of byte 0x42 of record i (no first-shown offset here: the ROM multiplies the zero-extended i directly). */
extern int FileIO_ByteBlock_DemoProc2(int i);

int FileIO_ByteBlock_DemoProc2(int i)
{
	if (ValidateFileRange(i) != 0)
		return -1;
	return (ram_25ec0[(unsigned int)i].b[0x42] & 0x80) != 0;
}
