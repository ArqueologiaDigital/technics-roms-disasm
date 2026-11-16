/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FDC_CONFIG_VERIFY FDC_CmdRecalibrate FDC_CmdSeek FDC_CmdSenseDriveStatus FDC_DETECT_CHECK FDC_DRIVE_DETECT FDC_FormatOneTrack FDC_INIT FDC_PRE_OP_CHECK FDC_SubmitReadDataCmd FDC_SubmitWriteDataCmd */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fdcparm { unsigned char head; unsigned char drive; unsigned char c; unsigned char h; unsigned char r;
                 unsigned char n; };
extern struct fdcparm __near FDC_HEAD;
extern unsigned int __near FDC_SECTOR_COUNT;
extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near ram_8b0a;
extern unsigned char __near FDC_FORMAT_IDS[];
extern void FDC_MC_EXIT_Code_Helper2(void);

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
