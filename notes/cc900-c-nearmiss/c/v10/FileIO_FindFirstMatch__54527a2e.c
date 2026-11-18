/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_4m268a.c (2026-11-18-33-p6-r37)
   sha256 54527a2ea04bd6cbe68b1f4908c61d6661e1ba81c96c6eeab236294512b121b4 (tar-sha256); compiled at -O3 -Xr */
struct ffblk { unsigned char attr; unsigned char pad; long size; char name[260]; };
extern long _findfirst(char *, struct ffblk *);
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern signed char ram_27412;
extern signed char ram_27414;
extern long ram_27416;
extern char ram_27312[][32];
extern char FindFirst_BuildPathLoop_Str_A[];
int FileIO_FindFirstMatch(char *name, long *size)
{
	int i;
	struct ffblk ff;
	long h;

	*name = 0;
	*size = 0;
	for (i = ram_27414; i < ram_27412; i++) {
		FileIO_CopyString((char *)0x25c6c, FindFirst_BuildPathLoop_Str_A);
		FileIO_BuildFilePath((char *)0x25c6c, (char *)0x272d2);
		FileIO_BuildFilePath((char *)0x25c6c, (char *)0x272f2);
		FileIO_BuildFilePath((char *)0x25c6c, ram_27312[i]);
		h = _findfirst((char *)0x25c6c, &ff);
		if (h >= 0) {
			FileIO_CopyString(name, ff.name);
			if (ff.attr & 0x10)
				*size = -1;
			else
				*size = ff.size;
			ram_27416 = h;
			ram_27414 = i;
			return 0;
		}
	}
	ram_27416 = -1;
	return -1;
}
