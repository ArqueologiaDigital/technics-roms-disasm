/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern int __near ram_846c;
extern int FileIO_GetCurrentFileIndex_Alt(void);
extern void FileIO_SelectFileByIndex(int);
extern void NavigateDocList(int d);
extern int __near ram_846a;
extern int GetCurrentFileIndexAlt(void);
extern void SetCurrentFileIndex(int);
extern void NavigatePdList(int d);

void NavigateDocList(int d)
{
	int i;
	int n;

	if (d == 1 || d == -1) {
		if (ram_846c > 0) {
			i = FileIO_GetCurrentFileIndex_Alt();
			if (i >= 0) {
				n = i + d;
				if (n < 0)
					n = ram_846c - 1;
				else if (n >= ram_846c)
					n = 0;
				if (i != n)
					FileIO_SelectFileByIndex(n);
			}
		}
	}
}

void NavigatePdList(int d)
{
	int i;
	int n;

	if (d == 1 || d == -1) {
		if (ram_846a > 0) {
			i = GetCurrentFileIndexAlt();
			if (i >= 0) {
				n = i + d;
				if (n < 0)
					n = ram_846a - 1;
				else if (n >= ram_846a)
					n = 0;
				if (i != n)
					SetCurrentFileIndex(n);
			}
		}
	}
}
