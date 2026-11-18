/* Phase 6, lane_p6 helper J, round 2, module 268, form b: HandleFilenameChange with an entry pointer for the
   first test and the flag stores, and the "large file" flag as one conditional expression. */
/* cc900-module: FileIO_CopyString_WriteNull FileIO_Search_SkipEntry ParseFileExtension */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fent { char f0; char f1; char name[6]; char f8; char f9; char big; char f11; };
extern struct fent ram_25db8[];
extern int ParseFileExtension(int, char *);
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern int FileIO_Search_SkipEntry(char *, char *, int);

int HandleFilenameChange(int idx, char *name, unsigned long size)
{
	int r;
	struct fent *e;

	e = &ram_25db8[idx];
	if (e->name[0] == 0) {
		r = ParseFileExtension(idx, name);
		if (r < 0)
			return 0;
		FileIO_CopyString_WriteNull((unsigned char *)ram_25db8[idx].name, (unsigned char *)name + 2, 6);
		e = &ram_25db8[idx];
		e->f8 = 0;
		if (r == 0)
			e->big = size > 5000 ? 1 : 0;
		return 1;
	}
	if (FileIO_Search_SkipEntry(e->name, name + 2, 6) != 0)
		return 0;
	if (ParseFileExtension(idx, name) != 0)
		return 0;
	ram_25db8[idx].big = size > 5000 ? 1 : 0;
	return 0;
}
