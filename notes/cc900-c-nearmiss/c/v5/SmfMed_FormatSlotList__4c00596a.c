/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/medley_m269.c (2026-11-18-34-p6-r38-staged)
   sha256 4c00596a684b165bbcd4bee3adc3afb907070f1a2d3a37899de4b4aae5f2da24 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_8328[];
extern unsigned char __near ram_87e8[];
extern long FmmSmfFileNameFunc(long, long, long);
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
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
        FormatMedleyNumber(ram_8328[i].s, ram_87e8[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8328[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_8328[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8328[i].s);
    }
}
