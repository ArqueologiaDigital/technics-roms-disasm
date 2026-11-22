/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FmmSmfFileNameFunc FormatMedleyNumber */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_8344[];
extern unsigned char __near ram_8804[];
extern long FmmSmfFileNameFunc(long, long, long);
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
extern void SmfMed_FormatSlotList(long obj, unsigned int total);

void SmfMed_FormatSlotList(long obj, unsigned int total)
{
    unsigned int n;
    unsigned int base;
    unsigned int i;

    base = FmmSmfFileNameFunc(0, EVT_GET_SELECTED_FILE_NUMBER, 0);
    base /= 10;
    base *= 10;
    n = 10;
    if (base + 10 >= total)
        n = total - base;
    for (i = 0; i < n; i++) {
        FormatMedleyNumber(ram_8344[i].s, ram_8804[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8344[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_8344[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8344[i].s);
    }
}

/* cc900-module: FmmDocFileNameFunc FmmPdFileNameFunc */
extern struct mtxt __near ram_8408[];
extern long FmmDocFileNameFunc(long, long, long);
extern void DocMed_FormatSlotList(long obj, unsigned int total);
extern struct mtxt __near ram_83a8[];
extern long FmmPdFileNameFunc(long, long, long);
extern void PdMed_FormatSlotList(long obj, unsigned int total);

void DocMed_FormatSlotList(long obj, unsigned int total)
{
    unsigned int n;
    unsigned int base;
    unsigned int i;

    base = FmmDocFileNameFunc(0, EVT_GET_SELECTED_FILE_NUMBER, 0);
    base /= 10;
    base *= 10;
    n = 10;
    if (base + 10 >= total)
        n = total - base;
    for (i = 0; i < n; i++) {
        FormatMedleyNumber(ram_8408[i].s, ram_8804[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8408[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_8408[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8408[i].s);
    }
}
void PdMed_FormatSlotList(long obj, unsigned int total)
{
    unsigned int n;
    unsigned int base;
    unsigned int i;

    base = FmmPdFileNameFunc(0, EVT_GET_SELECTED_FILE_NUMBER, 0);
    base /= 10;
    base *= 10;
    n = 10;
    if (base + 10 >= total)
        n = total - base;
    for (i = 0; i < n; i++) {
        FormatMedleyNumber(ram_83a8[i].s, ram_8804[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_83a8[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_83a8[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_83a8[i].s);
    }
}

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
