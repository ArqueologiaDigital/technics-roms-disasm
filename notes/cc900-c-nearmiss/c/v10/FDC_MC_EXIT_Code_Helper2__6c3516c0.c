/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_14m270a.c (2026-11-16-100-p6-r19)
   sha256 6c3516c0efbb2789f143e2893e5a8c5b49201c6553cd44da1bd337cec8c77bdc (tar-sha256); compiled at -O3 -Xr */
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
    unsigned char i;
    unsigned int half;
    unsigned int k;
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
            FDC_FORMAT_IDS[i++] = (unsigned char)(ram_8b0a >> 1) + FDC_PARAM_R;
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
