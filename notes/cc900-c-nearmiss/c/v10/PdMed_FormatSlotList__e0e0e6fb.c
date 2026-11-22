/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_26r1m269a.c (2026-11-22-5-p6-r72)
   sha256 e0e0e6fbc97c3b69cc496b5c73a0495d1eb515f46f699e54e2e8d8ee117c070e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_8444[];
extern unsigned char __near ram_88a0[];
extern long FmmPdFileNameFunc(long, long, long);
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
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
