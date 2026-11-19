/* lane_p6 round 5 (2026-11-19): p6_J_4m268a.c (r37: +54, Xr) with the "A:" string passed as a converted pointer: the
   ROM loads it with `ld xbc, imm` after XWA; V4.23 wrote `lda xbc` first (lane_hd's converted-pointer idiom).
   Phase 6, lane_p6 helper J, round 4, module 268 (demo/file_demo_proc.s, -O3 -Xr), form a: FileIO_FindFirstMatch.
   For each search directory i from 0x27414 up to 0x27412 (signed byte cells), build "A:" + the prefixes at
   0x272d2 / 0x272f2 + directory i (32-byte entries at 0x27312) into 0x25c6c and _findfirst it; on a hit copy the
   name, store the size (-1 for a subdirectory), keep the handle (0x27416) and the directory index; else -1. */
/* cc900-module: FileIO_BuildFilePath FileIO_CopyString */   /* scripts/analysis/cc900/module_calls.py v10 */

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
