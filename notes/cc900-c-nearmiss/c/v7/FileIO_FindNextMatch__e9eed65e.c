/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/file_demo_proc_m268.c (2026-11-18-28-p6-r36)
   sha256 e9eed65ef681a08cce01e360fb726e3f522642687d0c587c0c20dbd4db8730f4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_CopyString(char *, char *);
struct ffblk { unsigned char attr; char pad; long size; char name[260]; };
extern int _findnext(long, struct ffblk *);
extern int _findclose(long);
extern long ram_27416;
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
