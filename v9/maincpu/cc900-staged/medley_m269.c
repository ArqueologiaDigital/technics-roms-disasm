/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FmmDocFileNameFunc FmmPdFileNameFunc FormatMedleyNumber */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL
struct mtxt { unsigned char s[8]; };
extern struct mtxt __near ram_84a4[];
extern unsigned char __near ram_88a0[];
extern long FmmDocFileNameFunc(long, long, long);
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
extern void DocMed_FormatSlotList(long obj, unsigned int total);
extern struct mtxt __near ram_8444[];
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
        FormatMedleyNumber(ram_84a4[i].s, ram_88a0[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_84a4[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_84a4[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_84a4[i].s);
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
        FormatMedleyNumber(ram_8444[i].s, ram_88a0[base + i], i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8444[i].s);
    }
    for (; i < 10; i++) {
        FormatMedleyNumber(ram_8444[i].s, 0xff, i);
        ApPostEvent(obj, EVT_PARA_DRAW, ram_8444[i].s);
    }
}
