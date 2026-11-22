/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/medley_m269.c (2026-11-22-6-p6-r73)
   sha256 7d3a8c349773f77352e82b5e84de49b8c3a0655c6889ef1a92a74c5f064fa841 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern unsigned char __near ram_8804[];
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
extern struct mtxt __near ram_83a8[];
extern long FmmPdFileNameFunc(long, long, long);
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
