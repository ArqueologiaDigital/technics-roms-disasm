/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdc_routines_m270_xr.c (2026-11-17-1-p6-r28-staged)
   sha256 5b3a331bc070e7a563335ae2db485ad94b0105962e5dece36a3718b0f1eeba21 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct fdcparm { unsigned char head; unsigned char drive; unsigned char c; unsigned char h; unsigned char r;
                 unsigned char n; };
extern char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_DRIVE_MODE;
extern struct fdcparm __near FDC_HEAD;
extern unsigned char __near FDC_TARGET_TRACK;
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern void FDC_CONFIG_VERIFY(void);
extern unsigned char __near ram_8a12;
extern unsigned char __near ram_8a33;
extern unsigned char __near ram_8a34;
extern unsigned int __near ram_8b08;
extern void FDC_PRE_OP_CHECK(void);
extern void FDC_CmdRecalibrate(void);
extern void FDC_FormatOneTrack(void);
extern void FDC_CmdSenseDriveStatus(void);
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
