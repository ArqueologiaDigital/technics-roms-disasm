/* Phase 6, lane_p6 helper C, round 17, module 270 (modules_v10.tsv) of v10 storage/fdc_routines.s, form c: three
   new routines from the memory-to-memory pool, the request loops of a floppy read and write and the format loop.
   - FDC_CMD_EXEC (read): retries 1 or 8 by drive detection, then per pass seeks, clamps the start sector, counts
     the sectors left on this track into IZ, submits READ DATA; on success advances the buffer by the bytes done
     and flips the head (next cylinder after head 1); on error re-seeks and retries, 16 when out of retries.
   - FDC_SECTOR_XFER (write): the same loop with WRITE DATA, 8 retries, error 0x2f ends it, 0x20 when out.
   - FDC_MODE_CONFIG (format): checks, sets N and the gap length by drive mode, then formats every track.
   The ROM keeps the error code across FDC_CONFIG_VERIFY sign-extended in IZ: FDC_ERROR_CODE is plain (signed) char
   here.  The moved cells are __near and not volatile (ldw / ld (#16),(#16) in the ROM).  FDC_RETRY_COUNT is
   volatile: the ROM decrements it in memory and reloads it into A to test it, where other cells are compared in
   memory.  FDC_REQ_BUFFER is the request's 32-bit buffer address, advanced by the bytes transferred.
   Form d (p6_C_17m270d.c): FDC_RETRY_COUNT plain and pre-decremented, FDC_REQ_BUFFER a byte pointer. */
/* cc900-module: FDC_CONFIG_VERIFY FDC_CmdRecalibrate FDC_CmdSeek FDC_CmdSenseDriveStatus FDC_DETECT_CHECK FDC_DRIVE_DETECT FDC_FormatOneTrack FDC_INIT FDC_PRE_OP_CHECK FDC_SubmitReadDataCmd FDC_SubmitWriteDataCmd */

extern char __near FDC_ERROR_CODE;
extern volatile unsigned char __near FDC_RETRY_COUNT;
extern unsigned char __near FDC_DRIVE_MODE;
extern unsigned char __near FDC_HEAD;
extern unsigned char __near FDC_PARAM_C;
extern unsigned char __near FDC_PARAM_H;
extern unsigned char __near FDC_PARAM_R;
extern unsigned char __near FDC_PARAM_N;
extern unsigned char __near FDC_TARGET_TRACK;
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned char __near ram_8a12;
extern unsigned char __near ram_8a33;
extern unsigned char __near ram_8a34;
extern unsigned int __near FDC_SECTOR_COUNT;
extern unsigned int __near FDC_SECTOR_SIZE;
extern unsigned int __near FDC_REQ_SECTOR;
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned long __near FDC_REQ_BUFFER;
extern unsigned int __near FDC_SECTOR_LIMIT;
extern unsigned int __near ram_8b08;
extern unsigned int __near ram_8b10;
extern unsigned int __near ram_8b12;

extern void FDC_INIT(void);
extern void FDC_CONFIG_VERIFY(void);
extern int FDC_DETECT_CHECK(void);
extern int FDC_DRIVE_DETECT(void);
extern void FDC_PRE_OP_CHECK(void);
extern void FDC_CmdRecalibrate(void);
extern void FDC_CmdSeek(void);
extern void FDC_SubmitReadDataCmd(void);
extern void FDC_SubmitWriteDataCmd(void);
extern void FDC_FormatOneTrack(void);
extern void FDC_CmdSenseDriveStatus(void);

void FDC_CMD_EXEC(void)
{
    int n;
    if (FDC_DETECT_CHECK() != 0)
        FDC_RETRY_COUNT = 1;
    else if (FDC_DRIVE_DETECT() == 0)
        FDC_RETRY_COUNT = 8;
    else
        FDC_RETRY_COUNT = 1;
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
            FDC_REQ_COUNT = ram_8b12;
            FDC_RETRY_COUNT--;
            if (FDC_RETRY_COUNT == 0) {
                FDC_ERROR_CODE = 16;
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
            FDC_RETRY_COUNT--;
            if (FDC_RETRY_COUNT == 0) {
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
        FDC_PARAM_N = 2;
        ram_8a33 = 0x50;
        break;
    case 3:
        FDC_PARAM_N = 2;
        ram_8a33 = 0x6c;
        break;
    case 2:
        FDC_PARAM_N = 3;
        ram_8a33 = 0x74;
        break;
    }
    FDC_TARGET_TRACK = 0;
    FDC_PARAM_C = 0;
    ram_8a34 = 0xe5;
    FDC_PARAM_H = 0;
    FDC_HEAD = 0;
    while (FDC_TARGET_TRACK <= ram_8b08) {
        ram_8a12 = FDC_TARGET_TRACK;
        FDC_FormatOneTrack();
        if (FDC_ERROR_CODE != 0) break;
        FDC_PARAM_H = FDC_HEAD ^= 1;
        if (FDC_PARAM_H == 0) ram_8a12 = FDC_TARGET_TRACK = ++FDC_PARAM_C;
    }
out:
    if (FDC_ERROR_CODE != 0) FDC_CONFIG_VERIFY();
    FDC_CmdRecalibrate();
    FDC_CURRENT_CYLINDER = 255;
}
