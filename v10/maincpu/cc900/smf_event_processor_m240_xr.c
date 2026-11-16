/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FileIO_ReadNextDirEntry FileIO_ValidateHandle */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void *__cdecl Memset(void *, int, int);
extern int FileIO_MatchWildcard(char *name, char *pat);
extern unsigned int ram_2272c;
extern void FileIO_ReadAllDirEntries(void *h);
extern int FileIO_ReadNextDirEntry(void *h, void *name);
extern void FileIO_ValidateHandle(void *h);
extern void *FindFirst_SndTable(void *unused, void *name);

int FileIO_MatchWildcard(char *name, char *pat)
{
	char buf[12];
	int r;
	int n = 0;

	if (*pat == 0)
		return 0;
	Memset(buf, '?', 11);
	buf[11] = 0;
	{
		char *p;

		p = buf;
		while (*pat != 0) {
			if (*pat == '.') {
				p = buf + 8;
				pat++;
			} else
				*p++ = *pat++;
		}
	}
	{
		int i;

		for (i = 0; i < 8; i++) {
			if (buf[i] == '*')
				for (; i < 8; i++)
					buf[i] = '?';
		}
		for (i = 8; i < 11; i++) {
			if (buf[i] == '*')
				for (; i < 11; i++)
					buf[i] = '?';
		}
	}
	{
		char *s;
		char *p;

		r = 1;
		s = name;
		p = buf;
		while (*s != 0) {
			if (*p != '?' && *s != *p) {
				r = 0;
				break;
			}
			s++;
			p++;
		}
	}
	return r;
}

void *FindFirst_SndTable(void *unused, void *name)
{
    void *h;
    ram_2272c = 0;
    h = &ram_2272c;
    FileIO_ReadAllDirEntries(h);
    if (FileIO_ReadNextDirEntry(h, name) == 0)
        return h;
    FileIO_ValidateHandle(h);
    return (void *)0xffffffffUL;
}
