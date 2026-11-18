/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_1m270a.c (2026-11-18-12-p6-r35)
   sha256 3a287681ab0f1c17e35e798ea64f89201b389d19275ebdba529d153545ec7458 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned char __near FDC_INIT_FLAG;
extern unsigned char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near FDC_DRIVE_MODE;
extern unsigned int __near ram_8a22;
extern unsigned char __near ram_8a6e;
extern void FDC_ClearStatus_InitTimer(void);
extern int FDC_DRIVE_DETECT(void);
extern int FDC_DRIVE_STATUS(void);
extern void FDC_Send_Command(int);
extern void SOME_DELAY(int);
extern int FDC_CMD_DISPATCH_SUB(void);
extern unsigned char FDC_Read_Status(void);
extern void FDC_WriteDataRegister(int);
extern void FDC_Wait_Ready_Timeout(void);
extern unsigned char FDC_ReadDataRegister(void);
extern unsigned char FDC_Exception_Status_Decoder(void);
extern void FDC_CMD_SEND(int);
extern void FDC_RecordDensityCode(int);
extern void FDC_CMD_ENABLE(void);
extern void FDC_CmdRecalibrate(void);
void FDC_CONFIG_VERIFY(void)
{
    unsigned char *p;
    unsigned char s;
    unsigned char d;

    FDC_ClearStatus_InitTimer();
    if (FDC_DRIVE_DETECT() != -1 && FDC_DRIVE_STATUS() != -1)
        FDC_CURRENT_CYLINDER = 255;
    if (FDC_INIT_FLAG == 255)
        return;
    FDC_INIT_FLAG = 255;
    FDC_Send_Command(54);
    SOME_DELAY(2);
    if (FDC_DRIVE_DETECT() != -1 && FDC_DRIVE_STATUS() != -1) {
        FDC_ClearStatus_InitTimer();
        FDC_CMD_DISPATCH_SUB();
        if (FDC_ERROR_CODE != 0) {
            FDC_INIT_FLAG = 0;
            return;
        }
        do {
            do
                ;
            while (!(FDC_Read_Status() & 0x80));
            if (!(FDC_Read_Status() & 0x40)) {
                s = 0;
                while (s != 0x80)
                    s = FDC_Read_Status() & 0xf0;
                FDC_WriteDataRegister(8);
            }
            p = FDC_RESULT + 1;
            do {
                FDC_Wait_Ready_Timeout();
                *p++ = FDC_ReadDataRegister();
                do
                    ;
                while (!(FDC_Read_Status() & 0x80));
            } while (FDC_Read_Status() & 0x40);
            FDC_Exception_Status_Decoder();
        } while (FDC_RESULT[1] != 0x80);
    }
    FDC_CMD_SEND(3);
    if (FDC_ERROR_CODE != 0) {
        FDC_INIT_FLAG = 0;
        return;
    }
    FDC_CMD_SEND(79);
    if (FDC_ERROR_CODE != 0) {
        FDC_INIT_FLAG = 0;
        return;
    }
    switch (ram_8a6e & 15) {
    case 0:
        FDC_DRIVE_MODE = 0;
        ram_8a22 = 0;
        d = 0;
        FDC_RecordDensityCode(2);
        break;
    case 1:
        FDC_DRIVE_MODE = 0;
        ram_8a22 = 0;
        d = 192;
        FDC_RecordDensityCode(2);
        break;
    case 2:
        FDC_DRIVE_MODE = 2;
        ram_8a22 = 0;
        d = 64;
        FDC_RecordDensityCode(0);
        break;
    case 3:
        FDC_DRIVE_MODE = 3;
        ram_8a22 = 0;
        d = 64;
        FDC_RecordDensityCode(0);
        break;
    case 4:
        FDC_DRIVE_MODE = 4;
        ram_8a22 = 0;
        d = 0;
        FDC_RecordDensityCode(2);
        break;
    case 5:
        FDC_DRIVE_MODE = 5;
        ram_8a22 = 0;
        d = 0;
        FDC_RecordDensityCode(2);
        break;
    default:
        FDC_DRIVE_MODE = 0;
        ram_8a22 = 0;
        d = 0;
        FDC_RecordDensityCode(2);
        break;
    }
    FDC_CMD_SEND(d | 11);
    if (FDC_ERROR_CODE != 0) {
        FDC_INIT_FLAG = 0;
        return;
    }
    FDC_CMD_ENABLE();
    if (FDC_ERROR_CODE != 0) {
        FDC_INIT_FLAG = 0;
        return;
    }
    FDC_CmdRecalibrate();
    FDC_INIT_FLAG = 0;
}
