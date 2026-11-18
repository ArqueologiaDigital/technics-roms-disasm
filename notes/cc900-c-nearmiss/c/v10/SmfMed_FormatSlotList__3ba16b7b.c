/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/medley_m269.c (2026-11-18-34-p6-r38-staged)
   sha256 3ba16b7b21d34a3764cea39bb2b4e8fce8f4c5a5c17fa80e9be871e507611b72 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_83e0[];
extern unsigned char __near ram_88a0[];
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
        FormatMedleyNumber(ram_83e0[i].s, ram_88a0[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_83e0[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_83e0[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_83e0[i].s);
    }
}
