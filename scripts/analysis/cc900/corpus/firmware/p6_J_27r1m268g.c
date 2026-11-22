/* lane_p6 helper J, round 27r1, form g: module 268 (demo/file_demo_proc.s), the family of the five file-index
   getters (families27_J, 5 x 22 B): GetCurrentFileIndex, GetFirstPageBase, GetCurrentFileIndexAlt,
   FileIO_GetCurrentFileIndex_Alt, FileIO_GetCurrentWallpaperIndex: the index cell (0x25ea8 / 0x271ea / 0x272c8)
   when its validator returns 0, else -104 (an early `ldw hl; ret`, as in the built GetFirstRecordAndOpen).
   (Forms a-f of this round's m268 hold other families; this file only the getters.)
   Form g: the getter as one conditional expression, `return Validate(cell) == 0 ? cell : -104;`.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_ValidateModeAndRange ValidateFileRange ValidateFileRangeAlt ValidateFileRangeType5 ValidateFileSelectionIndex */

extern int ram_25ea8, ram_271ea, ram_272c8;
extern int ValidateFileSelectionIndex(int i);
extern int ValidateFileRange(int i);
extern int ValidateFileRangeType5(int i);
extern int ValidateFileRangeAlt(int i);
extern int FileIO_ValidateModeAndRange(int i);

int GetCurrentFileIndex(void)
{
	return ValidateFileSelectionIndex(ram_25ea8) == 0 ? ram_25ea8 : -104;
}

int GetFirstPageBase(void)
{
	return ValidateFileRange(ram_271ea) == 0 ? ram_271ea : -104;
}

int GetCurrentFileIndexAlt(void)
{
	return ValidateFileRangeType5(ram_271ea) == 0 ? ram_271ea : -104;
}

int FileIO_GetCurrentFileIndex_Alt(void)
{
	return ValidateFileRangeAlt(ram_271ea) == 0 ? ram_271ea : -104;
}

int FileIO_GetCurrentWallpaperIndex(void)
{
	return FileIO_ValidateModeAndRange(ram_272c8) == 0 ? ram_272c8 : -104;
}
