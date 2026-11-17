/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_17m270d.c (2026-11-16-118-p6-r23)
   sha256 d6f9c762cefb0cb8737cbe2c13b82d202cccd82a6f39e341051966076bd1f37b (tar-sha256); compiled at -Xr */
typedef unsigned char *bytep;
extern char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_RETRY_COUNT;
extern unsigned char __near FDC_DRIVE_MODE;
extern unsigned char __near FDC_HEAD;
extern unsigned char __near FDC_PARAM_C;
extern unsigned char __near FDC_PARAM_H;
extern unsigned char __near FDC_PARAM_R;
extern unsigned char __near FDC_TARGET_TRACK;
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned int __near FDC_SECTOR_COUNT;
extern unsigned int __near FDC_SECTOR_SIZE;
extern unsigned int __near FDC_REQ_SECTOR;
extern unsigned int __near FDC_REQ_COUNT;
extern bytep __near FDC_REQ_BUFFER;
extern unsigned int __near FDC_SECTOR_LIMIT;
extern unsigned int __near ram_8b10;
extern unsigned int __near ram_8b12;
extern void FDC_INIT(void);
extern void FDC_CONFIG_VERIFY(void);
extern void FDC_CmdSeek(void);
extern void FDC_SubmitWriteDataCmd(void);
void FDC_SECTOR_XFER(void)
{
    int n;
    FDC_RETRY_COUNT = 8;
    while (FDC_REQ_COUNT != 0) {
        FDC_ERROR_CODE = 0;
        FDC_CmdSeek();
        if (FDC_ERROR_CODE != 0) {
            n = FDC_ERROR_CODE;
            FDC_CONFIG_VERIFY();
            FDC_ERROR_CODE = n;
            return;
        }
        if (FDC_REQ_SECTOR > FDC_SECTOR_LIMIT) FDC_REQ_SECTOR = 1;
        ram_8b10 = FDC_REQ_SECTOR;
        FDC_SECTOR_COUNT = 0;
        if (FDC_DRIVE_MODE == 2) FDC_SECTOR_SIZE = 1024;
        else FDC_SECTOR_SIZE = 512;
        ram_8b12 = FDC_REQ_COUNT;
        n = 1;
        for (;;) {
            FDC_SECTOR_COUNT += FDC_SECTOR_SIZE;
            if (--FDC_REQ_COUNT == 0) break;
            if (++FDC_REQ_SECTOR > FDC_SECTOR_LIMIT) break;
            n++;
        }
        FDC_REQ_COUNT = n;
        FDC_REQ_SECTOR = ram_8b10;
        FDC_SubmitWriteDataCmd();
        if (FDC_ERROR_CODE != 0) {
            if (FDC_ERROR_CODE == 9) {
                FDC_INIT();
                FDC_CONFIG_VERIFY();
                return;
            }
            if (FDC_ERROR_CODE == 0x2f) return;
            FDC_CONFIG_VERIFY();
            FDC_CURRENT_CYLINDER = 255;
            FDC_CmdSeek();
            FDC_REQ_COUNT = ram_8b12;
            if (--FDC_RETRY_COUNT == 0) {
                FDC_ERROR_CODE = 0x20;
                return;
            }
        } else {
            FDC_REQ_COUNT = ram_8b12 - n;
            if (FDC_REQ_COUNT != 0) {
                FDC_REQ_BUFFER += FDC_SECTOR_COUNT;
                FDC_REQ_SECTOR = 1;
                FDC_PARAM_R = 1;
                FDC_PARAM_H = FDC_HEAD ^= 1;
                if (FDC_PARAM_H == 0) FDC_TARGET_TRACK = ++FDC_PARAM_C;
            }
        }
    }
}
