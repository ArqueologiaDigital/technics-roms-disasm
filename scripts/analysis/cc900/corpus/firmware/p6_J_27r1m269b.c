/* lane_p6 helper J, round 27r1, form b: module 269 (file_io/medley.s), the family NavigatePdList /
   NavigateDocList (families27_J, 2 x 60 B): a step d of +1 or -1 (homed in IZ) moves the current file index of the
   PD / DOC medley list (count 0x8506 / 0x8508) with wrap-around, and selects the new index when it changed
   (V4.23's own `call nz`).
   Form b: early returns for the three guards; the wrap as one if / else if on `(n = i + d) < 0`.
   cc900-options: -O3 -Xr
*/

extern int __near ram_8506;
extern int __near ram_8508;
extern int GetCurrentFileIndexAlt(void);
extern int FileIO_GetCurrentFileIndex_Alt(void);
extern void SetCurrentFileIndex(int);
extern void FileIO_SelectFileByIndex(int);

void NavigateDocList(int d)
{
	int i;
	int n;

	if (d != 1 && d != -1)
		return;
	if (ram_8508 <= 0)
		return;
	i = FileIO_GetCurrentFileIndex_Alt();
	if (i < 0)
		return;
	if ((n = i + d) < 0)
		n = ram_8508 - 1;
	else if (n >= ram_8508)
		n = 0;
	if (i != n)
		FileIO_SelectFileByIndex(n);
}

void NavigatePdList(int d)
{
	int i;
	int n;

	if (d != 1 && d != -1)
		return;
	if (ram_8506 <= 0)
		return;
	i = GetCurrentFileIndexAlt();
	if (i < 0)
		return;
	if ((n = i + d) < 0)
		n = ram_8506 - 1;
	else if (n >= ram_8506)
		n = 0;
	if (i != n)
		SetCurrentFileIndex(n);
}
