/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_5m268e.c (2026-11-19-19-p6-r43)
   sha256 dc15f2759aa14d13dd3090d735b38590d70f5e11ffce0f0ffbe346faf6556d4a (tar-sha256); compiled at -O3 -Xr */
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
		FileIO_CopyString((char *)0x25c6c, (char *)(long)FindFirst_BuildPathLoop_Str_A);
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
