/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m268a.c (2026-11-18-12-p6-r35)
   sha256 6111eea969d4b0e851eb2322d57ac297a826610984fa01854a293d1d344be8b5 (tar-sha256); compiled at -Xr */
struct ffblk { unsigned char attr; char pad; long size; char name[260]; };
extern void FileIO_CopyString(char *, char *);
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
