/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_18m270a.c (2026-11-16-123-p6-r25)
   sha256 a8a882ee8b30633f3278328c62bb1029255a2c064b12e51b2c40be605e878912 (tar-sha256); compiled at -O3 -Xr */
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
