/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FileIO_FindFirstMatch FileIO_FindNextMatch */   /* scripts/analysis/cc900/module_calls.py v10 */

extern long ram_27416;
extern char ram_27414;
extern char ram_27412;
extern int FileIO_FindFirstMatch(char *name, long *size);
extern int FileIO_FindNextMatch(char *name, long *size);
extern int FileIO_SearchStringMatch(char *name, long *size);
extern int FileIO_ReadByte(void);
extern void ReadFieldToBuffer(int len, char *buf);

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

void ReadFieldToBuffer(int len, char *buf)
{
	int lead;
	int i;
	int r;
	char c;
	char *p;

	if (*buf != 0)
		return;
	i = 0;
	if (len <= 64) {
		while (len > 0) {
			r = FileIO_ReadByte();
			if (r < 0)
				r = 0;
			buf[i] = r;
			len--;
			i++;
		}
	} else {
		lead = 1;
		do {
			r = FileIO_ReadByte();
			if (r < 0)
				break;
			c = r;
			p = &buf[i];
			if (lead != 0) {
				if (r == ' ')
					goto skip;
				lead = 0;
			}
			*p = c;
skip:
			len--;
			i++;
		} while (i < 64);
		while (len > 0) {
			FileIO_ReadByte();
			len--;
		}
	}
	buf[i] = 0;
	while (i--, *(p = &buf[i]) == ' ' && i > 0)
		*p = 0;
}
