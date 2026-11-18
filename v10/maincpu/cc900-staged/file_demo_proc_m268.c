/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_BuildFileIndex FileIO_BuildFilePath FileIO_CopyString FileIO_FindPathSeparator */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_OpenWithBuiltPath(char *name, char *mode);
struct ffblk { unsigned char attr; char pad; long size; char name[260]; };
extern int _findnext(long, struct ffblk *);
extern int _findclose(long);
extern long ram_27416;
extern int FileIO_FindNextMatch(char *name, long *size);

int FileIO_OpenWithBuiltPath(char *name, char *mode)
{
	char path[140];

	FileIO_CopyString(path, (char *)0x272d2);
	FileIO_BuildFilePath(path, (char *)0x272f2);
	FileIO_BuildFilePath(path, name);
	return FileIO_OpenWithMode(path, mode);
}

int FileIO_FindNextMatch(char *name, long *size)
{
	struct ffblk fb;

	if (_findnext(ram_27416, &fb) != 0) {
		*name = 0;
		*size = 0;
		_findclose(ram_27416);
		ram_27416 = -1;
		return -1;
	}
	FileIO_CopyString(name, fb.name);
	if (fb.attr & 0x10)
		*size = -1;
	else
		*size = fb.size;
	return 0;
}
