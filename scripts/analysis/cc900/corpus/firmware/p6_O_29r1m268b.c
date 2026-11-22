/* lane_p6 helper O, round 29r1, form b: module 268 (demo/file_demo_proc.s), GetFileEntryByIndex (singletons29_O).
   Form a with the record address spelled as byte arithmetic: base + (unsigned long)(unsigned)(i - first) * 82, and
   the index an unsigned int parameter.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_SearchFile ProcessFileRecord ValidateFileRange */   /* scripts/analysis/cc900/module_calls.py v10 */

extern char ram_25ec0[];
extern unsigned int ram_271ee;
extern char FileIO_EmptyEntryName[];
extern char FileIO_EmptyNameKey[];
extern int ValidateFileRange(int i);
extern int FileIO_SearchFile(char *, char *);
extern void ProcessFileRecord(int i);
extern char *GetFileEntryByIndex(unsigned int i);

char *GetFileEntryByIndex(unsigned int i)
{
	if (ValidateFileRange(i) != 0)
		return FileIO_EmptyEntryName;
	if (FileIO_SearchFile(ram_25ec0 + (unsigned long)(i - ram_271ee) * 82, FileIO_EmptyNameKey) == 0)
		ProcessFileRecord(i);
	return ram_25ec0 + (unsigned long)(i - ram_271ee) * 82;
}

/* FileIO_ByteBlock_DemoProc2: bit 7 of byte 0x42 of record i, as a shift. */
extern int FileIO_ByteBlock_DemoProc2(unsigned int i);

int FileIO_ByteBlock_DemoProc2(unsigned int i)
{
	if (ValidateFileRange(i) != 0)
		return -1;
	return (((unsigned char *)ram_25ec0 + (unsigned long)i * 82)[0x42] >> 7) & 1;
}
