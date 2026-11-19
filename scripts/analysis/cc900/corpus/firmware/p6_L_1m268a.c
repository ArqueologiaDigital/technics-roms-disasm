/* Phase 6, lane_p6 helper L, round 1, form a: module 268 (demo/file_demo_proc.s).
   - FileIO_SearchStringMatch: first search when no find handle (ram_27416 < 0); else, while the match count
     ram_27414 is below ram_27412, the next match, and when that fails the count is bumped and the first search
     redone.  The ROM shares the FindFirst call between both paths (cross-jump); form a writes two calls. */
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
	if (ram_27416 < 0)
		r = FileIO_FindFirstMatch(name, size);
	else if (ram_27414 < ram_27412) {
		r = FileIO_FindNextMatch(name, size);
		if (r < 0) {
			ram_27414++;
			r = FileIO_FindFirstMatch(name, size);
		}
	}
	return r;
}
