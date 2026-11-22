/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/medley_m269.c (2026-11-22-6-p6-r73)
   sha256 cfd84015cd90d560603a33c9f58e9f522d9e91b3081ab5d9b5b0077c43606ca4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_83ec[];
extern unsigned char __near ram_87e8[];
extern long FmmDocFileNameFunc(long, long, long);
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
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
        FormatMedleyNumber(ram_83ec[i].s, ram_87e8[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_83ec[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_83ec[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_83ec[i].s);
    }
}
