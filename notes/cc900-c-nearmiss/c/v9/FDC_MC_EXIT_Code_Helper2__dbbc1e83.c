/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdc_routines_m270_xr.c (2026-11-16-125-p6-r26-staged)
   sha256 dbbc1e83ec6030a55cd7959a4cedeba8268fba86ccbfe48f9eb6bc4647b27dce (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct fdcparm { unsigned char head; unsigned char drive; unsigned char c; unsigned char h; unsigned char r;
                 unsigned char n; };
extern struct fdcparm __near FDC_HEAD;
extern unsigned int __near FDC_SECTOR_COUNT;
extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near ram_8b0a;
extern unsigned char __near FDC_FORMAT_IDS[];
void FDC_MC_EXIT_Code_Helper2(void)
{
    unsigned char i;
    unsigned int k, half;
    FDC_HEAD.r = 1;
    FDC_SECTOR_COUNT = 0;
    half = ram_8b0a >> 1;
    i = 0;
    k = 0;
    if (k < half) do {
        FDC_FORMAT_IDS[i++] = FDC_HEAD.c;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_HEAD.h;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_HEAD.r;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_HEAD.n;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_HEAD.c;
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_HEAD.h;
        FDC_SECTOR_COUNT++;
        if (FDC_REQ_TRACK == 0) {
            FDC_HEAD.r++;
            FDC_FORMAT_IDS[i++] = FDC_HEAD.r;
        } else {
            FDC_FORMAT_IDS[i++] = (unsigned char)(ram_8b0a >> 1) + FDC_HEAD.r;
        }
        FDC_SECTOR_COUNT++;
        FDC_FORMAT_IDS[i++] = FDC_HEAD.n;
        FDC_SECTOR_COUNT++;
        FDC_HEAD.r++;
        k++;
    } while (k < half);
    if (!(ram_8b0a & 1)) return;
    FDC_FORMAT_IDS[i++] = FDC_HEAD.c;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = FDC_HEAD.h;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = ram_8b0a;
    FDC_SECTOR_COUNT++;
    FDC_FORMAT_IDS[i++] = FDC_HEAD.n;
    FDC_SECTOR_COUNT++;
}
