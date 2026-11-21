/* helper Z, round 22r1, module 266 (demo/file_demo_proc.s), form a: FileIO_SaveRegion0_VRAM, one-spot retry of
   helper S's p6_S_20r1m266a.c.  At -O3 -Xr (run r58, +8) only the first size differs: V4.23 computed
   `E - S` in registers and stored it (`sub xwa, xbc; ld (xsp+4), xwa`); the ROM loads E and S, stores E into the
   size's frame slot and subtracts S in memory (`ld (xsp+4), xbc; sub (xsp+4), xwa`); the second size (XIZ)
   already matches.  Here the first size is written as two statements, `n1 = E; n1 -= S;`.  Form b: the same with
   `n1 = n1 - S`.  Everything else is S's form a text.
   cc900-options: -O3 -Xr
*/
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

extern void FileIO_ReadHeader(char *dst, char *src, char type);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern int FileIO_ReturnError(void);
extern int FileIO_OpenDefault(char *);
extern void FileIO_CloseHandle(void);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_WriteByte_Impl(void *, long);
extern void PreLswSave(void);
extern void PostLswSave(int);
extern char SaveRegion0_SpaceOk_Str_wb[];
extern unsigned char __near LIVE_PANEL_BLOCK[];
extern unsigned char __near ram_ffc0[];
extern unsigned char ram_1e7800[];
extern unsigned char ram_1e8000[];
extern int FileIO_SaveRegion0_VRAM(char *src);

int FileIO_SaveRegion0_VRAM(char *src)
{
	long n1;
	char hd[14];
	long n2;
	int r;

	n1 = (long)ram_ffc0;
	n1 -= (long)LIVE_PANEL_BLOCK;
	n2 = (long)ram_1e8000 - (long)ram_1e7800;
	if (FileIO_GetDiskFreeSpace() < n1 + n2)
		return -101;
	FileIO_ReadHeader(hd, src, 0);
	if (FileIO_OpenWithMode(hd, SaveRegion0_SpaceOk_Str_wb) < 0)
		return FileIO_ReturnError();
	PreLswSave();
	FileIO_WriteByte_Impl((void *)0xf980L, n1);
	FileIO_WriteByte_Impl((void *)0x1e7800L, n2);
	r = FileIO_ReturnError();
	PostLswSave(r);
	FileIO_CloseHandle();
	if (r < 0)
		FileIO_OpenDefault(hd);
	return r;
}
