/* Phase 6, lane_p6 helper L, round 1, form b: module 268, FileIO_SearchStringMatch with early returns and one
   FindFirst call reached by goto (the ROM's shared call). */
/* cc900-module: FileIO_FindFirstMatch FileIO_FindNextMatch */   /* scripts/analysis/cc900/module_calls.py v10 */

extern long ram_27416;
extern char ram_27414;
extern char ram_27412;
extern int FileIO_FindFirstMatch(char *name, long *size);
extern int FileIO_FindNextMatch(char *name, long *size);
extern int FileIO_SearchStringMatch(char *name, long *size);

int FileIO_SearchStringMatch(char *name, long *size)
{
	int r;

	r = -1;
	if (ram_27416 >= 0) {
		if (ram_27414 >= ram_27412)
			return r;
		r = FileIO_FindNextMatch(name, size);
		if (r >= 0)
			return r;
		ram_27414++;
	}
	return FileIO_FindFirstMatch(name, size);
}
