/* lane_p6 helper J, round 27r1, form f: module 268 (demo/file_demo_proc.s), the family of the five file-index
   getters (families27_J, 5 x 22 B): GetCurrentFileIndex, GetFirstPageBase, GetCurrentFileIndexAlt,
   FileIO_GetCurrentFileIndex_Alt, FileIO_GetCurrentWallpaperIndex: the index cell (0x25ea8 / 0x271ea / 0x272c8)
   when its validator returns 0, else -104 (an early `ldw hl; ret`, as in the built GetFirstRecordAndOpen).
   (Forms a-e of this round's m268 hold other families; this file only the getters.)
   Form f: `if (Validate(cell) != 0) return -104; return cell;`.
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
	if (ValidateFileSelectionIndex(ram_25ea8) != 0)
		return -104;
	return ram_25ea8;
}

int GetFirstPageBase(void)
{
	if (ValidateFileRange(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}

int GetCurrentFileIndexAlt(void)
{
	if (ValidateFileRangeType5(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}

int FileIO_GetCurrentFileIndex_Alt(void)
{
	if (ValidateFileRangeAlt(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}

int FileIO_GetCurrentWallpaperIndex(void)
{
	if (FileIO_ValidateModeAndRange(ram_272c8) != 0)
		return -104;
	return ram_272c8;
}
