/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FDC_CMD_DISPATCH_SUB FDC_CMD_ENABLE FDC_CMD_SEND FDC_ClearStatus_InitTimer FDC_CmdRecalibrate FDC_DRIVE_DETECT FDC_DRIVE_STATUS FDC_Exception_Status_Decoder FDC_ReadDataRegister FDC_Read_Status FDC_RecordDensityCode FDC_Send_Command FDC_Wait_Ready_Timeout FDC_WriteDataRegister SOME_DELAY */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned char __near FDC_INIT_FLAG;
extern unsigned char __near FDC_ERROR_CODE;
extern unsigned char __near FDC_RESULT[];
extern unsigned char __near FDC_DRIVE_MODE;
extern unsigned int __near ram_896a;
extern unsigned char __near ram_89b6;
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
extern void FDC_CONFIG_VERIFY(void);

/* cc900-data: FDC_CONFIG_VERIFY 1 = FDC_WaitReady_CaseTable */
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
            p = FDC_RESULT;
            p++;
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
    switch (ram_89b6 & 15) {
    case 0:
        FDC_DRIVE_MODE = 0;
        ram_896a = 0;
        d = 0;
        FDC_RecordDensityCode(2);
        break;
    case 1:
        FDC_DRIVE_MODE = 0;
        ram_896a = 0;
        d = 192;
        FDC_RecordDensityCode(2);
        break;
    case 2:
        FDC_DRIVE_MODE = 2;
        ram_896a = 0;
        d = 64;
        FDC_RecordDensityCode(0);
        break;
    case 3:
        FDC_DRIVE_MODE = 3;
        ram_896a = 0;
        d = 64;
        FDC_RecordDensityCode(0);
        break;
    case 4:
        FDC_DRIVE_MODE = 4;
        ram_896a = 0;
        d = 0;
        FDC_RecordDensityCode(2);
        break;
    case 5:
        FDC_DRIVE_MODE = 5;
        ram_896a = 0;
        d = 0;
        FDC_RecordDensityCode(2);
        break;
    default:
        FDC_DRIVE_MODE = 0;
        ram_896a = 0;
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
