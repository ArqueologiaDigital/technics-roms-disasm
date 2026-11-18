/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_4m269b.c (2026-11-18-33-p6-r37)
   sha256 81ad941876e2cb6a813b4ca20a93c445939772e662e414e65fa2bcff6d0fc4dc (tar-sha256); compiled at -Xr */
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
    i = 0;
    if (i < n)
        do {
            FormatMedleyNumber(ram_83e0[i].s, ram_88a0[base + i], i);
            ApPostEvent(obj, EVT_PARA_DRAW, ram_83e0[i].s);
        } while (++i < n);
    if (i < 10)
        do {
            FormatMedleyNumber(ram_83e0[i].s, 0xff, i);
            ApPostEvent(obj, EVT_PARA_DRAW, ram_83e0[i].s);
        } while (++i < 10);
}
