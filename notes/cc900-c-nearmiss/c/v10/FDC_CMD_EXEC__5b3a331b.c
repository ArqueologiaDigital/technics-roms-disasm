/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdc_routines_m270_xr.c (2026-11-17-1-p6-r28-staged)
   sha256 5b3a331bc070e7a563335ae2db485ad94b0105962e5dece36a3718b0f1eeba21 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct fdcparm { unsigned char head; unsigned char drive; unsigned char c; unsigned char h; unsigned char r;
                 unsigned char n; };
struct fdcreq { unsigned int sector; unsigned int count; unsigned char *buffer; };
extern char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_RETRY_COUNT;
extern unsigned char __near FDC_DRIVE_MODE;
extern struct fdcparm __near FDC_HEAD;
extern struct fdcreq __near FDC_REQ_SECTOR;
extern unsigned char __near FDC_TARGET_TRACK;
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned int __near FDC_SECTOR_COUNT;
extern unsigned int __near FDC_SECTOR_SIZE;
extern unsigned int __near FDC_SECTOR_LIMIT;
extern unsigned int __near ram_8b10;
extern unsigned int __near ram_8b12;
extern void FDC_INIT(void);
extern void FDC_CONFIG_VERIFY(void);
extern int FDC_DETECT_CHECK(void);
extern int FDC_DRIVE_DETECT(void);
extern void FDC_CmdSeek(void);
extern void FDC_SubmitReadDataCmd(void);
void FDC_CMD_EXEC(void)
{
    unsigned int n;
    unsigned char t;
    if (FDC_DETECT_CHECK() != 0)
        FDC_RETRY_COUNT = 1;
    else if (FDC_DRIVE_DETECT() == 0)
        FDC_RETRY_COUNT = 8;
    else
        FDC_RETRY_COUNT = 1;
    goto test;
    do {
        FDC_ERROR_CODE = 0;
        FDC_CmdSeek();
        if (FDC_ERROR_CODE != 0) {
            n = FDC_ERROR_CODE;
            FDC_CONFIG_VERIFY();
            FDC_ERROR_CODE = n;
            return;
        }
        if (FDC_REQ_SECTOR.sector > FDC_SECTOR_LIMIT) FDC_REQ_SECTOR.sector = 1;
        ram_8b10 = FDC_REQ_SECTOR.sector;
        FDC_SECTOR_COUNT = 0;
        if (FDC_DRIVE_MODE == 2) FDC_SECTOR_SIZE = 1024;
        else FDC_SECTOR_SIZE = 512;
        ram_8b12 = FDC_REQ_SECTOR.count;
        n = 1;
        for (;;) {
            FDC_SECTOR_COUNT += FDC_SECTOR_SIZE;
            if (--FDC_REQ_SECTOR.count == 0) break;
            if (++FDC_REQ_SECTOR.sector > FDC_SECTOR_LIMIT) break;
            n++;
        }
        FDC_REQ_SECTOR.count = n;
        FDC_REQ_SECTOR.sector = ram_8b10;
        FDC_SubmitReadDataCmd();
        if (FDC_ERROR_CODE != 0) {
            if (FDC_ERROR_CODE == 9) {
                FDC_INIT();
                return;
            }
            if (FDC_DRIVE_DETECT() != -1) {
                FDC_CONFIG_VERIFY();
                FDC_CURRENT_CYLINDER = 255;
                FDC_CmdSeek();
            }
            FDC_REQ_SECTOR.count = ram_8b12;
            if (--FDC_RETRY_COUNT == 0) {
                FDC_ERROR_CODE = 16;
                return;
            }
        } else {
            FDC_REQ_SECTOR.count = ram_8b12 - n;
            if (FDC_REQ_SECTOR.count != 0) {
                FDC_REQ_SECTOR.buffer += FDC_SECTOR_COUNT;
                FDC_REQ_SECTOR.sector = 1;
                FDC_HEAD.r = 1;
                FDC_HEAD.h = FDC_HEAD.head = FDC_HEAD.head ^ 1;
                if (FDC_HEAD.h == 0) {
                    t = ++FDC_HEAD.c;
                    FDC_TARGET_TRACK = t;
                }
            }
        }
test:   ;
    } while (FDC_REQ_SECTOR.count != 0);
}
