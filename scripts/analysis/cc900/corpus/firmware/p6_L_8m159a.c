/* Phase 6, lane_p6 helper L, round 8, form a: module 159.  Retry of FDListDirectory (r51 form b +6: identical but
   for the ROM's dead `ld wa,0` just before the path is loaded into XWA; round 7's int local went to the frame).
   The path argument as a comma expression whose discarded left operand is 0, evaluated into the argument
   register first. */
/* cc900-module: FDTest_PrintDiag */   /* scripts/analysis/cc900/module_calls.py v10 */

struct ffblk { unsigned char attr; char pad; long size; char name[260]; };
extern char FDListDirectory_Str_Star_Dot_Star[];
extern long _findfirst(char *, struct ffblk *);
extern int _findnext(long, struct ffblk *);
extern int _findclose(long);
extern void FDTest_PrintDiag(char *s);
extern int FDListDirectory(void);

int FDListDirectory(void)
{
	struct ffblk f;
	long h;

	if ((h = _findfirst((0, FDListDirectory_Str_Star_Dot_Star), &f)) == -1)
		return -1;
	FDTest_PrintDiag(f.name);
	while (_findnext(h, &f) != -1)
		FDTest_PrintDiag(f.name);
	_findclose(h);
	return 0;
}
