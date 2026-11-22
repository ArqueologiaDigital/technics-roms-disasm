/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/medley_m269.c (2026-11-22-6-p6-r73)
   sha256 74d19c245d2cbe09025f09254a034570e1f2535962036e85ddabd90410d215a5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern unsigned char __near ram_88a0[];
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
extern struct mtxt __near ram_8444[];
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
        FormatMedleyNumber(ram_8444[i].s, ram_88a0[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8444[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_8444[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8444[i].s);
    }
}
