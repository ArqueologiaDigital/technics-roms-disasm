/* Phase 6, lane_p6 helper C, round 18, module 270 (modules_v10.tsv) of v10 storage/fdc_routines.s, form a:
   FDC_MC_EXIT_Code_Helper2 only.  Round 16 form b (volatile parameter cells) differed only in the else arm, where
   V4.23 loaded FDC_PARAM_R into C before the shift and added C; the ROM adds the cell (add A,(mem)).  Round 17's
   non-volatile pointer read made V4.23 compute the store address first (run 118), so here the sum goes through a
   byte local first, read through the non-volatile pointer, and is then stored.
   Forms b and c (p6_C_18m270b.c, p6_C_18m270c.c) try the parameter cells as one struct, without volatile. */
/* no module-local callee (module_calls.py) */

/* __near: the ROM reaches the cell with a 16-bit absolute operand. */
extern volatile unsigned char __near FDC_PARAM_C;
extern volatile unsigned char __near FDC_PARAM_H;
extern volatile unsigned char __near FDC_PARAM_R;
extern volatile unsigned char __near FDC_PARAM_N;
extern unsigned int __near FDC_SECTOR_COUNT;
extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near ram_8b0a;
extern unsigned char __near FDC_FORMAT_IDS[];

void FDC_MC_EXIT_Code_Helper2(void)
{
    unsigned char i, t;
    unsigned int k, half;
    FDC_PARAM_R = 1;
    FDC_SECTOR_COUNT = 0;
    half = ram_8b0a >> 1;
    i = 0;
    k = 0;
    if (k < half) do {
        FDC_FORMAT_IDS[i++] = FDC_PARAM_C;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_H;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_R;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_N;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_C;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_H;
        FDC_SECTOR_COUNT++;
        if (FDC_REQ_TRACK == 0) {
            FDC_PARAM_R++;
            FDC_FORMAT_IDS[i++] = FDC_PARAM_R;
        } else {
            t = (unsigned char)(ram_8b0a >> 1) + *(unsigned char *)&FDC_PARAM_R;
            FDC_FORMAT_IDS[i++] = t;
        }
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_PARAM_N;
        FDC_SECTOR_COUNT++;
        FDC_PARAM_R++;
        k++;
    } while (k < half);
    if (!(ram_8b0a & 1)) return;
    FDC_FORMAT_IDS[i++] = FDC_PARAM_C;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = FDC_PARAM_H;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = ram_8b0a;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = FDC_PARAM_N;
    FDC_SECTOR_COUNT++;
}
