/* Phase 6, lane_p6 helper J, round 2, module 268 (demo/file_demo_proc.s, -O3 -Xr like file_demo_proc_m268.c), form a:
   HandleFilenameChange.  The file table at 0x25db8 holds 12-byte entries {2 bytes, a 6-character name at +2,
   flag at +8, a "large file" flag at +10}; the ROM indexes it with muls 0xc, folding the member offset into the
   base (0x25dba, 0x25dc2) where the index is recomputed. */
/* cc900-module: FileIO_CopyString_WriteNull FileIO_Search_SkipEntry ParseFileExtension */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fent { char f0; char f1; char name[6]; char f8; char f9; char big; char f11; };
extern struct fent ram_25db8[];
extern int ParseFileExtension(int, char *);
extern void FileIO_CopyString_WriteNull(unsigned char *, unsigned char *, int);
extern int FileIO_Search_SkipEntry(char *, char *, int);

int HandleFilenameChange(int idx, char *name, unsigned long size)
{
	int r;

	if (ram_25db8[idx].name[0] == 0) {
		r = ParseFileExtension(idx, name);
		if (r < 0)
			return 0;
		FileIO_CopyString_WriteNull((unsigned char *)ram_25db8[idx].name, (unsigned char *)name + 2, 6);
		ram_25db8[idx].f8 = 0;
		if (r == 0) {
			if (size > 5000)
				ram_25db8[idx].big = 1;
			else
				ram_25db8[idx].big = 0;
		}
		return 1;
	}
	if (FileIO_Search_SkipEntry(ram_25db8[idx].name, name + 2, 6) != 0)
		return 0;
	if (ParseFileExtension(idx, name) != 0)
		return 0;
	if (size > 5000)
		ram_25db8[idx].big = 1;
	else
		ram_25db8[idx].big = 0;
	return 0;
}
