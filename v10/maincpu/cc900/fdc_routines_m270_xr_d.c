/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FDC_CONFIG_VERIFY FDC_CmdRecalibrate FDC_CmdSeek FDC_CmdSenseDriveStatus FDC_DETECT_CHECK FDC_DRIVE_DETECT FDC_FormatOneTrack FDC_INIT FDC_PRE_OP_CHECK FDC_SubmitReadDataCmd FDC_SubmitWriteDataCmd */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void FDC_CMD_EXEC(void);
extern unsigned char __near ram_8a12;
extern unsigned char __near ram_8a33;
extern unsigned char __near ram_8a34;
extern unsigned int __near ram_8b08;
extern void FDC_PRE_OP_CHECK(void);
extern void FDC_CmdRecalibrate(void);
extern void FDC_FormatOneTrack(void);
extern void FDC_CmdSenseDriveStatus(void);
extern void FDC_MODE_CONFIG(void);
extern void FDC_SubmitWriteDataCmd(void);
extern void FDC_SECTOR_XFER(void);

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

void FDC_MODE_CONFIG(void)
{
    FDC_PRE_OP_CHECK();
    if (FDC_ERROR_CODE != 0) goto out;
    FDC_CmdSenseDriveStatus();
    if (FDC_ERROR_CODE != 0) goto out;
    FDC_CmdRecalibrate();
    if (FDC_ERROR_CODE != 0) goto out;
    switch (FDC_DRIVE_MODE) {
    case 0:
    case 4:
    case 5:
        FDC_HEAD.n = 2;
        ram_8a33 = 0x50;
        break;
    case 3:
        FDC_HEAD.n = 2;
        ram_8a33 = 0x6c;
        break;
    case 2:
        FDC_HEAD.n = 3;
        ram_8a33 = 0x74;
        break;
    }
    FDC_TARGET_TRACK = 0;
    FDC_HEAD.c = 0;
    ram_8a34 = 0xe5;
    FDC_HEAD.h = 0;
    FDC_HEAD.head = 0;
    goto test;
    do {
        ram_8a12 = FDC_TARGET_TRACK;
        FDC_FormatOneTrack();
        if (FDC_ERROR_CODE != 0) break;
        FDC_HEAD.h = FDC_HEAD.head = FDC_HEAD.head ^ 1;
        if (FDC_HEAD.h == 0) ram_8a12 = FDC_TARGET_TRACK = ++FDC_HEAD.c;
test:   ;
    } while (FDC_TARGET_TRACK <= ram_8b08);
out:
    if (FDC_ERROR_CODE != 0) FDC_CONFIG_VERIFY();
    FDC_CmdRecalibrate();
    FDC_CURRENT_CYLINDER = 255;
}

void FDC_SECTOR_XFER(void)
{
    unsigned int n;
    unsigned char t;
    FDC_RETRY_COUNT = 8;
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
            FDC_REQ_SECTOR.count = ram_8b12;
            if (--FDC_RETRY_COUNT == 0) {
                FDC_ERROR_CODE = 0x20;
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
